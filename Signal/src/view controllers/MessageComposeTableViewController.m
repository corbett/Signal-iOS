//
//  MessageComposeTableViewController.m
//  
//
//  Created by Dylan Bourgeois on 02/11/14.
//
//

#import "MessageComposeTableViewController.h"
#import "Environment.h"
#import "Contact.h"
#import "PhoneNumberUtil.h"
#import "PreferencesUtil.h"
#import "MessagesViewController.h"
#import "SignalsViewController.h"
#import "NotificationManifest.h"
#import "PhoneNumberDirectoryFilterManager.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "ContactTableViewCell.h"
#import "UIColor+OWS.h"
#import "UIUtil.h"

@interface MessageComposeTableViewController () <UISearchBarDelegate, UISearchResultsUpdating, MFMessageComposeViewControllerDelegate>
{
    UIButton* sendTextButton;
    NSString* currentSearchTerm;
    NSArray* contacts;
    NSArray* searchResults;
}

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIBarButtonItem *addGroup;
@property (nonatomic, strong) UIView *loadingBackgroundView;
@property (nonatomic, strong) UIView *emptyBackgroundView;

@end

@implementation MessageComposeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];    
    
    contacts = [[Environment getCurrent] contactsManager].textSecureContacts;
    searchResults = contacts;
    [self initializeSearch];

    self.searchController.searchBar.hidden = NO;
    
    

    self.tableView.backgroundView.opaque = YES;
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void) viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    [self refreshContacts];// todo remove
    if([Environment.preferences getIsRefreshingContactsAllServices]) {
        [self showLoadingBackgroundView:YES];
    }
    else if([contacts count]==0) {
        [self showEmptyBackgroundView:YES];
    }

}

-(void) createLoadingAndBackgroundViews {
    // TODO: tweak this and we will want to add buttons and spinners and stuff
    _loadingBackgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    UIImageView *loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uiEmpty"]];
    [loadingImageView setBackgroundColor:[UIColor whiteColor]];
    [loadingImageView setContentMode:UIViewContentModeCenter];
    [loadingImageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [loadingImageView  setFrame:self.tableView.frame];
    [_loadingBackgroundView addSubview:loadingImageView];
    
    
    _emptyBackgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    UIImageView *emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uiEmpty"]];
    [emptyImageView setBackgroundColor:[UIColor whiteColor]];
    [emptyImageView setContentMode:UIViewContentModeCenter];
    [emptyImageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [emptyImageView  setFrame:self.tableView.frame];
    [_emptyBackgroundView addSubview:loadingImageView];
}

-(void) showLoadingBackgroundView:(BOOL)show {
    if(!show) {
        self.tableView.hidden = NO;
        self.tableView.backgroundView = _loadingBackgroundView;
        self.tableView.backgroundView.opaque = YES;
        // todo animate spinner
    }
    else {
        self.tableView.hidden = YES;
        self.tableView.backgroundView = nil;
    }
}


-(void) showEmptyBackgroundView:(BOOL)show {
    if(!show) {
        self.tableView.hidden = NO;
        self.tableView.backgroundView = _emptyBackgroundView;
        self.tableView.backgroundView.opaque = YES;
    }
    else {
        self.tableView.hidden = YES;
        self.tableView.backgroundView = nil;
    }
}

#pragma mark - Initializers

-(void)initializeSearch
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"Search by name or number";

    sendTextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendTextButton setBackgroundColor:[UIColor ows_materialBlueColor]];
    [sendTextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendTextButton.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y + 44.0, self.searchController.searchBar.frame.size.width, 44.0);
    [self.view addSubview:sendTextButton];
    sendTextButton.hidden = YES;
    
    [sendTextButton addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
    [self initializeObservers];
    [self initializeRefreshControl];
    
}

-(void)initializeObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsDidRefresh) name:NOTIFICATION_DIRECTORY_WAS_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactRefreshFailed) name:NOTIFICATION_DIRECTORY_FAILED object:nil];
}

-(void)initializeRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshContacts) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.tableView addSubview:self.refreshControl];
    
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [self.searchController.searchBar text];
    
    [self filterContentForSearchText:searchString scope:nil];
    
    [self.tableView reloadData];
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    sendTextButton.hidden = YES;
}


#pragma mark - Filter

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // search by contact name or number
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(fullName contains[c] %@) OR (allPhoneNumbers contains[c] %@)", searchText, searchText];
    searchResults = [contacts filteredArrayUsingPredicate:resultPredicate];
    if (!searchResults.count && _searchController.searchBar.text.length == 0) {
        searchResults = contacts;
    }
    NSString *formattedNumber = [PhoneNumber tryParsePhoneNumberFromUserSpecifiedText:searchText].toE164;
    
    // text to a non-signal number if we have no results and a valid phone #
    if (searchResults.count == 0 && searchText.length > 8) {
        NSString *sendTextTo = @"Send SMS to: ";
        sendTextTo = [sendTextTo stringByAppendingString:formattedNumber];
        [sendTextButton setTitle:sendTextTo forState:UIControlStateNormal];
        sendTextButton.hidden = NO;
        currentSearchTerm = formattedNumber;
    } else {
        sendTextButton.hidden = YES;
    }

}


#pragma mark - Send Normal Text to Unknown Contact

- (void)sendText {
    NSString *confirmMessage = @"Would you like to invite the following number to Signal: ";
    confirmMessage = [confirmMessage stringByAppendingString:currentSearchTerm];
    confirmMessage = [confirmMessage stringByAppendingString:@"?"];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Confirm"
                                                           message:confirmMessage
                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           [self.searchController setActive:NO];
                                           
                                           UIDevice *device = [UIDevice currentDevice];
                                           if ([[device model] isEqualToString:@"iPhone"]) {
                                               MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                                               picker.messageComposeDelegate = self;
                                               
                                               picker.recipients = [NSArray arrayWithObject:currentSearchTerm];
                                               picker.body = @"I'm inviting you to install Signal! Here is the link: https://itunes.apple.com/us/app/signal-private-messenger/id874139669?mt=8";
                                               [self presentViewController:picker animated:YES completion:[UIUtil modalCompletionBlock]];
                                            } else {
                                               // TODO: better backup for iPods (just don't support on)
                                               UIAlertView *notPermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                               
                                               [notPermitted show];
                                           }
                                       }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    sendTextButton.hidden = YES;
    self.searchController.searchBar.text = @"";
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:alertController animated:YES completion:[UIUtil modalCompletionBlock]];
}

#pragma mark - SMS Composer Delegate

// called on completion of message screen
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed: {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MessageComposeResultSent: {
            [self dismissViewControllerAnimated:NO completion:^{
                NSLog(@"view controller dismissed");
            }];
            UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You've invited your friend to use Signal!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [successAlert show];
            break;
        }
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([contacts count] == 0) {
        self.tableView.backgroundView.hidden = NO;
        self.searchController.searchBar.hidden = YES;
        _addGroup =  self.navigationItem.rightBarButtonItem!=nil ? _addGroup : self.navigationItem.rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        self.tableView.backgroundView.hidden = YES;
        self.searchController.searchBar.hidden = NO;
        self.navigationItem.rightBarButtonItem =  self.navigationItem.rightBarButtonItem!=nil ? self.navigationItem.rightBarButtonItem : _addGroup;
    }
    
    if (self.searchController.active) {
        return (NSInteger)[searchResults count];
    } else {
        return (NSInteger)[contacts count];
    }
}


- (ContactTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = (ContactTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell"];
    
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactTableViewCell"];
    }

    cell.shouldShowContactButtons = NO;

    [cell configureWithContact:[self contactForIndexPath:indexPath]];
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

#pragma mark - Table View delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Contact *person = [self contactForIndexPath:indexPath];
    return person.isTextSecureContact ? indexPath : nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [[[self contactForIndexPath:indexPath] textSecureIdentifiers] firstObject];
    
    [self dismissViewControllerAnimated:YES completion:^(){
        [Environment messageIdentifier:identifier];
    }];
}
    

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactTableViewCell * cell = (ContactTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

-(Contact*)contactForIndexPath:(NSIndexPath*)indexPath
{
    Contact *contact = nil;
    
    if (self.searchController.active) {
        contact = [searchResults objectAtIndex:(NSUInteger)indexPath.row];
    } else {
        contact = [contacts objectAtIndex:(NSUInteger)indexPath.row];
    }

    return contact;
}

#pragma mark Refresh controls

- (void)contactRefreshFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TIMEOUT message:TIMEOUT_CONTACTS_DETAIL delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [alert show];
    [self updateAfterRefreshTry];
}

- (void)contactsDidRefresh {
    [self updateSearchResultsForSearchController:self.searchController];
    [self.tableView reloadData];
    [self updateAfterRefreshTry];
}

- (void) updateAfterRefreshTry {
    [self.refreshControl endRefreshing];
    
    [self showLoadingBackgroundView:NO];
    if([contacts count]==0) {
        [self showEmptyBackgroundView:YES];
    }
    else {
        [self showEmptyBackgroundView:NO];
    }
}

- (void)refreshContacts {
    Environment *env = [Environment getCurrent];
    PhoneNumberDirectoryFilterManager *manager = [env phoneDirectoryManager];
    [manager forceUpdate];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.searchController.active = NO;
}

-(IBAction)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end

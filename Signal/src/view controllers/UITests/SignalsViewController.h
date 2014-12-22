//
//  SignalsViewController.h
//  Signal
//
//  Created by Dylan Bourgeois on 27/10/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#include "InboxTableViewCell.h"
#import <UIKit/UIKit.h>

#import "Contact.h"
#import "GroupModel.h"

@interface SignalsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TableViewCellDelegate>

@property (nonatomic) NSString   *contactIdentifierFromCompose;
@property (nonatomic) GroupModel *groupFromCompose;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *inboxArchiveSwitch;


@end

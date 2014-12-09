//
//  FingerprintViewController.m
//  Signal
//
//  Created by Dylan Bourgeois on 02/11/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "FingerprintViewController.h"

#import "Cryptography.h"
#import <AxolotlKit/NSData+keyVersionByte.h>
#import <25519/Curve25519.h>
#import "NSData+hexString.h"
#import "DJWActionSheet.h"
#import "TSStorageManager.h"
#import "TSStorageManager+IdentityKeyStore.h"
#import "PresentIdentityQRCodeViewController.h"
#import "ScanIdentityBarcodeViewController.h"
#include "NSData+Base64.h"

@interface FingerprintViewController ()
@property TSContactThread *thread;
@end

@implementation FingerprintViewController

- (void)configWithThread:(TSThread *)thread{
    self.thread = (TSContactThread*)thread;
}

- (NSString*)getFingerprintForDisplay:(NSData*)identityKey {
    // idea here is to insert a space every two characters. there is probably a cleverer/more native way to do this.
    
    identityKey = [identityKey prependKeyType];
    NSString *fingerprint = [identityKey hexadecimalString];
    __block NSString*  formattedFingerprint = @"";
    
    
    [fingerprint enumerateSubstringsInRange:NSMakeRange(0, [fingerprint length])
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         if (substringRange.location % 2 != 0 && substringRange.location != [fingerprint length]-1) {
             substring = [substring stringByAppendingString:@" "];
         }
         formattedFingerprint = [formattedFingerprint stringByAppendingString:substring];
     }];
    return formattedFingerprint;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setAlpha:0];
    
    [self initializeImageViews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.contactFingerprintTitleLabel.text = self.thread.name;
    NSData *identityKey = [self getTheirPublicIdentityKey];
    self.contactFingerprintLabel.text = [self getFingerprintForDisplay:identityKey];
    
    NSData *myPublicKey = [self getMyPublicIdentityKey];
    self.userFingerprintLabel.text = [self getFingerprintForDisplay:myPublicKey];
    
    [UIView animateWithDuration:0.6 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view setAlpha:1];
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSData*) getMyPublicIdentityKey {
    return [[TSStorageManager sharedManager] identityKeyPair].publicKey;
}

-(NSData*) getTheirPublicIdentityKey {
    return [[TSStorageManager sharedManager] identityKeyForRecipientId:self.thread.contactIdentifier];
    
}

#pragma mark - Initializers
- (void)initializeImageViews
{
    _contactImageView.image = [UIImage imageNamed:@"defaultConctact_light"];
    _contactImageView.layer.cornerRadius = 75.f/2;
    _contactImageView.layer.masksToBounds = YES;
    _contactImageView.layer.borderWidth = 2.0f;
    _contactImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _userImageView.image = [UIImage imageNamed:@"defaultConctact_light"];
    _userImageView.layer.cornerRadius = 75.f/2;
    _userImageView.layer.masksToBounds = YES;
    _userImageView.layer.borderWidth = 2.0f;
    _userImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
}

#pragma mark - Action
- (IBAction)closeButtonAction:(id)sender
{
    [UIView animateWithDuration:0.6 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view setAlpha:0];
    } completion:^(BOOL succeeded){
        [self dismissViewControllerAnimated:YES completion:nil];
    }];

}

- (IBAction)shredAndDelete:(id)sender
{
    [DJWActionSheet showInView:self.view withTitle:@"Are you sure wou want to shred all communications with this contact ? This action is irreversible."
             cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Shred all communications & delete contact"]
                      tapBlock:^(DJWActionSheet *actionSheet, NSInteger tappedButtonIndex) {
                          if (tappedButtonIndex == actionSheet.cancelButtonIndex) {
                              NSLog(@"User Cancelled");
                          } else if (tappedButtonIndex == actionSheet.destructiveButtonIndex) {
                              NSLog(@"Destructive button tapped");
                          }else {
                              [self shredAndDelete];
                          }
                      }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"PresentIdentityQRCodeViewSegue"]){
        [segue.destinationViewController setIdentityKey:[[self getMyPublicIdentityKey] prependKeyType]];
    }
    else if([[segue identifier] isEqualToString:@"ScanIdentityBarcodeViewSegue"]){
        [segue.destinationViewController setIdentityKey:[[self getTheirPublicIdentityKey] prependKeyType]];
    }
    
}


- (IBAction)unwindToIdentityKeyWasVerified:(UIStoryboardSegue *)segue{
    // Can later be used to mark identity key as verified if we want step above TOFU in UX
}


- (IBAction)unwindCancel:(UIStoryboardSegue *)segue{
    NSLog(@"action cancelled");
    // Can later be used to mark identity key as verified if we want step above TOFU in UX
}

#pragma mark - Shredding & Deleting

- (void)shredAndDelete {
#warning unimplemented: shredAndDelete
}

@end

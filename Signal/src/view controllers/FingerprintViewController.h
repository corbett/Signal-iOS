//
//  FingerprintViewController.h
//  Signal
//
//  Created by Dylan Bourgeois on 02/11/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSContactThread.h"

@interface FingerprintViewController : UIViewController

- (void)configWithThread:(TSThread*)thread;

@property (nonatomic, strong) IBOutlet UILabel     * presentationLabel;

@property (nonatomic, strong) IBOutlet UIImageView * contactImageView;
@property (nonatomic, strong) IBOutlet UILabel     * contactFingerprintTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel     * contactFingerprintLabel;

@property (nonatomic, strong) IBOutlet UIImageView * userImageView;
@property (nonatomic, strong) IBOutlet UILabel     * userFingerprintTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel     * userFingerprintLabel;

@property (nonatomic, strong) IBOutlet UIButton    * closeButton;
@property (nonatomic, strong) IBOutlet UIButton    * shredMessagesAndContactButton;

// returns my public identity key as NSData
-(NSData*) getMyPublicIdentityKey;
// returns recipient's public identity key as NSData
-(NSData*) getTheirPublicIdentityKey;

// This is called when the recipient's public key is verified. Later can be used to mark as such if we want a step above TOFU in UX.
- (IBAction)unwindToIdentityKeyWasVerified:(UIStoryboardSegue *)segue;
// Just a cancelation of the user's request to verify reciepient fingerprint or have their fingerprint verified by recipient
- (IBAction)unwindCancel:(UIStoryboardSegue *)segue;
@end

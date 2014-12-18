//
//  TSGroup.h
//  TextSecureKit
//
//  Created by Frederic Jacobs on 12/11/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSAttachement.h"

#import "TSYapDatabaseObject.h"

@interface TSGroup : TSYapDatabaseObject
//TODOGROUP UNUSED

@property (nonatomic) NSString      *name;          // Name of the group
@property (nonatomic) TSAttachement *avatar;        // Link to the attachement object (group picture)
@property (nonatomic) NSSet         *members;       // Each member of the discussion is a TSUser

- (NSData*)groupIdentifier;

+ (TSGroup*)groupWithId:(NSData*)id;

- (NSSet*)membersIdentifier;


@end

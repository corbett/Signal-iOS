//
//  GroupModel.h
//  Signal
//
//  Created by Dylan Bourgeois on 13/11/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSYapDatabaseObject.h"

typedef NS_ENUM(NSInteger, TSGroupChange) {
    TSGroupChangeNone,
    TSGroupChangeQuit,
    TSGroupChangeUpdate,
    TSGroupChangeUpdateNew,
};

@interface GroupModel : TSYapDatabaseObject

@property (nonatomic, strong) NSMutableArray *groupMemberIds; //
@property (nonatomic, strong) UIImage *groupImage;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSData* groupId;
@property (nonatomic) TSGroupChange groupChange;

-(instancetype)initWithTitle:(NSString*)title memberIds:(NSMutableArray*)members image:(UIImage*)image groupId:(NSData*)groupId;

@end

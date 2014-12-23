//
//  GroupModel.m
//  Signal
//
//  Created by Dylan Bourgeois on 13/11/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "GroupModel.h"

@implementation GroupModel

-(instancetype)initWithTitle:(NSString*)title memberIds:(NSMutableArray*)memberIds image:(UIImage*)image groupId:(NSData *)groupId{
    //TODOGROUP
    _groupName=title;
    _groupMemberIds = [memberIds copy];
    _groupImage = image;
    _groupId = groupId;
    
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToGroupModel:other];
}

- (BOOL)isEqualToGroupModel:(GroupModel *)other {
    if (self == other)
        return YES;
    if(![_groupId isEqualToData:other.groupId] ) {
        return NO;
    }
    if (![_groupName isEqual:other.groupName]) {
        return NO;
    }
    if( !(_groupImage!=nil && other.groupImage!=nil && [UIImagePNGRepresentation(_groupImage) isEqualToData:UIImagePNGRepresentation(other.groupImage)])) {
        return NO;
    }
    NSMutableArray* compareMyGroupMemberIds = [NSMutableArray arrayWithArray:_groupMemberIds];
    [compareMyGroupMemberIds removeObjectsInArray:other.groupMemberIds];
    if([compareMyGroupMemberIds count] > 0 ) {
        return NO;
    }
    return YES;
}


@end

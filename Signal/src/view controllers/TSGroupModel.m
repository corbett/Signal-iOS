//
//  GroupModel.m
//  Signal
//
//  Created by Frederic Jacobs on 13/11/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "TSGroupModel.h"

NSString * const TSAttachementGroupAvatarFileRelationshipEdge = @"TSAttachementGroupAvatarFileEdge";

@implementation TSGroupModel

-(instancetype)initWithTitle:(NSString*)title memberIds:(NSMutableArray*)memberIds image:(UIImage*)image groupId:(NSData *)groupId associatedAttachmentId:(NSString*)attachmentId {
    _groupName                  = title;
    _groupMemberIds             = [memberIds copy];
    _groupImage                 = image;
    _associatedAttachmentId     = attachmentId;
    _groupId                    = groupId;

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

- (BOOL)isEqualToGroupModel:(TSGroupModel *)other {
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

- (NSString*) getInfoStringAboutUpdateTo:(TSGroupModel*)newModel {
    NSString* updatedGroupInfoString = @"";
    if (self == newModel) {
        return @"Group updated.";
    }
    if (![_groupName isEqual:newModel.groupName]) {
        updatedGroupInfoString = [updatedGroupInfoString stringByAppendingString:[NSString stringWithFormat:@"Title is now '%@'. ",newModel.groupName]];
    }
    if(_groupImage!=nil  && newModel.groupImage!=nil  && !([UIImagePNGRepresentation(_groupImage) isEqualToData:UIImagePNGRepresentation(newModel.groupImage)])) {
        updatedGroupInfoString = [updatedGroupInfoString stringByAppendingString:@"Avatar changed. "];
    }
    if([updatedGroupInfoString length]==0) {
        updatedGroupInfoString = @"Group updated";
    }
    NSSet* oldMembers = [NSSet setWithArray:_groupMemberIds];
    NSSet* newMembers = [NSSet setWithArray:newModel.groupMemberIds];
    
    NSMutableSet *membersWhoJoined = [NSMutableSet setWithSet:newMembers];
    [membersWhoJoined minusSet:oldMembers];
    
    NSMutableSet *membersWhoLeft = [NSMutableSet setWithSet:oldMembers];
    [membersWhoLeft minusSet:newMembers];
    
    
    if([membersWhoLeft count] > 0 ) {
        updatedGroupInfoString = [updatedGroupInfoString stringByAppendingString:[NSString stringWithFormat:@" %@ left the group. ",[[membersWhoLeft allObjects] componentsJoinedByString:@", "]]];
    }
    
    if([membersWhoJoined count] > 0 ) {
        updatedGroupInfoString = [updatedGroupInfoString stringByAppendingString:[NSString stringWithFormat:@" %@ joined the group. ",[[membersWhoJoined allObjects] componentsJoinedByString:@", "]]];
    }
    
    return updatedGroupInfoString;
}

- (NSArray *)yapDatabaseRelationshipEdges {
        if([_associatedAttachmentId length]>0){
            YapDatabaseRelationshipEdge *fileEdge = [[YapDatabaseRelationshipEdge alloc] initWithName:TSAttachementGroupAvatarFileRelationshipEdge
                                                                                   destinationKey:_associatedAttachmentId
                                                                                       collection:[TSAttachment collection]
                                                                                  nodeDeleteRules:YDB_DeleteDestinationIfAllSourcesDeleted];
            return @[fileEdge];
        }
        else {
            return nil;
        }
}

@end

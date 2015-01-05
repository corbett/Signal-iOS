//
//  TSGroupMessageStorageTests.m
//
//  Created by Christine Corbett on 04/01/15.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TSThread.h"
#import "TSContactThread.h"
#import "TSGroupThread.h"

#import "TSStorageManager.h"

#import "TSMessage.h"
#import "TSErrorMessage.h"
#import "TSInfoMessage.h"
#import "TSIncomingMessage.h"
#import "TSCall.h"
#import "TSOutgoingMessage.h"
#import "Cryptography.h"


@interface TSGroupMessageStorageTests : XCTestCase

@property TSGroupThread *thread;
@property NSData* groupId;

@end

@implementation TSGroupMessageStorageTests

- (void)setUp {
    [super setUp];
    
    [[TSStorageManager sharedManager].dbConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        self.groupId = [Cryptography generateRandomBytes:16];
        GroupModel *emptyModelToFillOutId = [[GroupModel alloc] initWithTitle:nil memberIds:nil image:nil groupId:self.groupId];
        self.thread = [TSGroupThread getOrCreateThreadWithGroupModel:emptyModelToFillOutId transaction:transaction];
        
        [self.thread saveWithTransaction:transaction];
    }];
    
    TSStorageManager *manager = [TSStorageManager sharedManager];
    [manager purgeCollection:[TSMessage collection]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testGroupModelDeletedOnThreadDeleted {
    
    [self.thread remove];
    
    [[TSStorageManager sharedManager].dbConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        GroupModel *emptyModelToFillOutId = [[GroupModel alloc] initWithTitle:nil memberIds:nil image:nil groupId:self.groupId];
        [self.thread removeWithTransaction:transaction];

        TSGroupThread *shouldBeNil = [TSGroupThread threadWithGroupModel:emptyModelToFillOutId transaction:transaction];
        XCTAssert(shouldBeNil == nil, @"group thread should be deleted!");
    }];
}

@end

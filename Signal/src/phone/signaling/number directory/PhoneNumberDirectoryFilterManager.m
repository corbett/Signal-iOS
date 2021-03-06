#import "PhoneNumberDirectoryFilterManager.h"

#import "Environment.h"
#import "NotificationManifest.h"
#import "PreferencesUtil.h"
#import "RPServerRequestsManager.h"
#import "SignalUtil.h"
#import "ThreadManager.h"
#import "Util.h"

#define MINUTE (60.0)
#define HOUR (MINUTE*60.0)

#define DIRECTORY_UPDATE_TIMEOUT_PERIOD (1.0*MINUTE)
#define DIRECTORY_UPDATE_RETRY_PERIOD (1.0*HOUR)

@implementation PhoneNumberDirectoryFilterManager {
@private TOCCancelTokenSource* currentUpdateLifetime;
}

-(id) init {
    if (self = [super init]) {
        phoneNumberDirectoryFilter = PhoneNumberDirectoryFilter.phoneNumberDirectoryFilterDefault;
    }
    return self;
}
-(void) startUntilCancelled:(TOCCancelToken*)cancelToken {
    lifetimeToken = cancelToken;
    
    phoneNumberDirectoryFilter = [Environment.preferences tryGetSavedPhoneNumberDirectory];
    if (phoneNumberDirectoryFilter == nil) {
        phoneNumberDirectoryFilter = PhoneNumberDirectoryFilter.phoneNumberDirectoryFilterDefault;
    }
    
    [self scheduleUpdate];
}

-(PhoneNumberDirectoryFilter*) getCurrentFilter {
    @synchronized(self) {
        return phoneNumberDirectoryFilter;
    }
}
-(void)forceUpdate {
    [self scheduleUpdateAt:NSDate.date];
}
-(void) scheduleUpdate {
    return [self scheduleUpdateAt:self.getCurrentFilter.getExpirationDate];
}
-(void) scheduleUpdateAt:(NSDate*)date {
    void(^doUpdate)(void) = ^{
        if (Environment.isRegistered) {
            [self update];
        }
    };
    
    [currentUpdateLifetime cancel];
    currentUpdateLifetime = [TOCCancelTokenSource new];
    [lifetimeToken whenCancelledDo:^{ [currentUpdateLifetime cancel]; }];
    [TimeUtil scheduleRun:doUpdate
                       at:date
                onRunLoop:[ThreadManager normalLatencyThreadRunLoop]
          unlessCancelled:currentUpdateLifetime.token];
}

-(void) update {
    [[RPServerRequestsManager sharedInstance] performRequest:[RPAPICall fetchBloomFilter] success:^(NSURLSessionDataTask *task, NSData *responseObject) {
        PhoneNumberDirectoryFilter *directory = [PhoneNumberDirectoryFilter phoneNumberDirectoryFilterFromURLResponse:(NSHTTPURLResponse*)task.response body:responseObject];
        
        @synchronized(self) {
            phoneNumberDirectoryFilter = directory;
        }
        
        [Environment.preferences setSavedPhoneNumberDirectory:directory];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DIRECTORY_WAS_UPDATED object:nil];
        [self scheduleUpdate];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSString* desc = [NSString stringWithFormat:@"Failed to retrieve directory. Retrying in %f hours.",
                          DIRECTORY_UPDATE_RETRY_PERIOD/HOUR];
        Environment.errorNoter(desc, error, false);
        BloomFilter* filter = [phoneNumberDirectoryFilter bloomFilter];
        NSDate* retryDate = [NSDate dateWithTimeInterval:DIRECTORY_UPDATE_RETRY_PERIOD
                                               sinceDate:[NSDate date]];
        @synchronized(self) {
            phoneNumberDirectoryFilter = [PhoneNumberDirectoryFilter phoneNumberDirectoryFilterWithBloomFilter:filter
                                                                                            andExpirationDate:retryDate];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DIRECTORY_FAILED object:nil];
    }];
}

@end

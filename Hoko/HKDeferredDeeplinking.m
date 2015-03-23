//
//  HKDeferredDeeplinking.m
//  
//
//  Created by Ivan Bruel on 23/03/15.
//
//

#import "HKDeferredDeeplinking.h"

#import "HKUtils.h"
#import "HKLogger.h"
#import "HKDevice.h"
#import "HKNetworking.h"

NSString *const HKDeferredDeeplinkingNotFirstRun = @"isNotFirstRun";
NSString *const HKDeferredDeeplinkingPath = @"deferred_deeplinking";

@interface HKDeferredDeeplinking ()

@property (nonatomic, strong) NSString *token;

@end

@implementation HKDeferredDeeplinking

- (instancetype)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}

- (void)requestDeferredDeeplink:(void (^)(NSString *))handler
{
    BOOL isFirstRun = ![[HKUtils objectForKey:HKDeferredDeeplinkingNotFirstRun] boolValue];
    if (isFirstRun) {
        [HKUtils saveObject:@YES key:HKDeferredDeeplinkingNotFirstRun];
        [HKNetworking postToPath:HKDeferredDeeplinkingPath parameters:self.json token:self.token successBlock:^(id json) {
            NSString *deeplink = json[@"deeplink"];
            if (deeplink && handler) {
                handler(deeplink);
            }
        } failedBlock:^(NSError *error) {
            HKErrorLog(error);
        }];
    }
}

- (id)json
{
    return @{@"os_version": [HKDevice device].systemVersion,
             @"device_type": [HKDevice device].platform,
             @"language": [HKDevice device].systemLanguage.lowercaseString,
             @"screen_size": [HKDevice device].screenSize,
             @"timezone_offset": [HKDevice device].timezoneOffset};
}

@end

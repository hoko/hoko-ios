//
//  HOKDeferredDeeplinking.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKDeferredDeeplinking.h"

#import "HOKUtils.h"
#import "HOKLogger.h"
#import "HOKDevice.h"
#import "HOKNetworking.h"
#import "HOKNetworkOperation.h"
#import "HOKNotificationObserver.h"
#import "HOKObserver.h"

NSString *const HOKDeferredDeeplinkingNotFirstRun = @"isNotFirstRun";
NSString *const HOKDeferredDeeplinkingPath = @"installs/ios";

@interface HOKDeferredDeeplinking ()

@property (nonatomic, strong) NSString *token;

@end

@implementation HOKDeferredDeeplinking

- (instancetype)initWithToken:(NSString *)token {
  self = [super init];
  if (self) {
    _token = token;
  }
  return self;
}

- (void)requestDeferredDeeplink:(void (^)(NSString *))handler {
  BOOL isFirstRun = ![[HOKUtils objectForKey:HOKDeferredDeeplinkingNotFirstRun] boolValue];
  if (isFirstRun) {
    [HOKUtils saveObject:@YES key:HOKDeferredDeeplinkingNotFirstRun];
    [HOKNetworking postToPath:[HOKNetworkOperation urlFromPath:HOKDeferredDeeplinkingPath] parameters:self.json token:self.token successBlock:^(id json) {
      NSString *deeplink = [json objectForKey:@"deeplink"];
      if (deeplink && [deeplink isKindOfClass:[NSString class]] && handler) {
        handler(deeplink);
      }
    } failedBlock:^(NSError *error) {
      HOKErrorLog(error);
    }];
  }
}

- (NSDictionary *)json {
  return @{@"device": @{@"os_version": [HOKUtils jsonValue:[HOKDevice device].systemVersion],
                        @"device_type": [HOKUtils jsonValue:[HOKDevice device].platform],
                        @"language": [HOKUtils jsonValue:[HOKDevice device].systemLanguage.lowercaseString],
                        @"screen_size": [HOKUtils jsonValue:[HOKDevice device].screenSize],
                        @"uid": [HOKUtils jsonValue:[HOKDevice device].uid] }
           };
}

@end

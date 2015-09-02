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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
#import <SafariServices/SafariServices.h>
#endif


NSString *const HOKDeferredDeeplinkingNotFirstRun = @"isNotFirstRun";
NSString *const HOKDeferredDeeplinkingPath = @"installs/ios";
NSString *const HOKFingerprintMatchingPath = @"match?idfa=%@";

@interface HOKDeferredDeeplinking ()
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
<SFSafariViewControllerDelegate>
#endif

@property (nonatomic, strong) NSString *token;
@property (nonatomic, copy) void (^handler)(NSString *deeplink);

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
    self.handler = handler;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
    NSString *fingerprintString = [NSString stringWithFormat:HOKFingerprintMatchingPath, [HOKDevice device].uid];
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[HOKNetworkOperation urlFromPath:fingerprintString]]];
    safariViewController.delegate = self;
#else
    [self hok_requestDeferredDeeplink];
#endif
  }
}

- (void)hok_requestDeferredDeeplink {
  [HOKUtils saveObject:@YES key:HOKDeferredDeeplinkingNotFirstRun];
  [HOKNetworking postToPath:[HOKNetworkOperation urlFromPath:HOKDeferredDeeplinkingPath] parameters:self.json token:self.token successBlock:^(id json) {
    NSString *deeplink = [json objectForKey:@"deeplink"];
    if (deeplink && [deeplink isKindOfClass:[NSString class]] && self.handler) {
      self.handler(deeplink);
    }
  } failedBlock:^(NSError *error) {
    HOKErrorLog(error);
  }];
}

- (NSDictionary *)json {
  return @{@"device": @{@"os_version": [HOKDevice device].systemVersion,
                        @"device_type": [HOKDevice device].platform,
                        @"language": [HOKDevice device].systemLanguage.lowercaseString,
                        @"screen_size": [HOKDevice device].screenSize,
                        
                        /* ADDED NOW */
                        @"uid": [HOKDevice device].uid
                        }
           };
}



#pragma mark - SFSafariViewController delegate method
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
  [self hok_requestDeferredDeeplink];
}
#endif



@end

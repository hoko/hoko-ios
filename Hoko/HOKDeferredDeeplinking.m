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
#import "HOKNavigation.h"

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
#import <SafariServices/SafariServices.h>
#endif


NSString *const HOKDeferredDeeplinkingNotFirstRun = @"isNotFirstRun";
NSString *const HOKDeferredDeeplinkingPath = @"installs/ios";
NSString *const HOKFingerprintMatchingPath = @"fingerprints/match";

@interface HOKDeferredDeeplinking ()
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
<SFSafariViewControllerDelegate>
#endif

@property (nonatomic, strong) NSString *token;
@property (nonatomic, copy) void (^handler)(NSString *deeplink);

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
@property (nonatomic, strong) SFSafariViewController *safariViewController;
#endif

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
    
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    if (HOKSystemVersionGreaterThanOrEqualTo(@"9.0")) {
      NSString *fingerprintURL = [NSString stringWithFormat:@"%@?uid=%@", [HOKNetworkOperation urlFromPath:HOKFingerprintMatchingPath], [HOKDevice device].uid];
      self.safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:fingerprintURL]];
      self.safariViewController.delegate = self;
      
      UIViewController *rootViewController = [[UIViewController alloc] init];
      
      UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectZero];
      window.rootViewController = rootViewController;
      [window makeKeyAndVisible];
      window.alpha = 0;
      
      [rootViewController presentViewController:self.safariViewController animated:NO completion:nil];
    } else {
      [self requestDeferredDeeplink];
    }
#else
    [self requestDeferredDeeplink];
#endif
  }
}

- (void)requestDeferredDeeplink {
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
  return @{@"device": @{@"os_version": [HOKUtils jsonValue:[HOKDevice device].systemVersion],
                        @"device_type": [HOKUtils jsonValue:[HOKDevice device].platform],
                        @"language": [HOKUtils jsonValue:[HOKDevice device].systemLanguage.lowercaseString],
                        @"screen_size": [HOKUtils jsonValue:[HOKDevice device].screenSize],
                        @"uid": [HOKUtils jsonValue:[HOKDevice device].uid] }
           };
}



#pragma mark - SFSafariViewController delegate method
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
  [self.safariViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
  [self requestDeferredDeeplink];
}
#endif

@end

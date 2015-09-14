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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
#import <SafariServices/SafariServices.h>
#endif


NSString *const HOKDeferredDeeplinkingNotFirstRun = @"isNotFirstRun";
NSString *const HOKDeferredDeeplinkingPath = @"installs/ios";
NSString *const HOKFingerprintMatchingPath = @"fingerprints/match";

@interface HOKDeferredDeeplinking ()
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
<SFSafariViewControllerDelegate>
#endif

@property (nonatomic, strong) NSString *token;
@property (nonatomic, copy) void (^handler)(NSString *deeplink);

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
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
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
    NSString *fingerprintURL = [NSString stringWithFormat:@"%@?uid=%@", [HOKNetworkOperation urlFromPath:HOKFingerprintMatchingPath], [HOKDevice device].uid];
    self.safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:fingerprintURL]];
    self.safariViewController.delegate = self;
    self.safariViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.safariViewController.view.alpha = 0;
    self.safariViewController.view.hidden = YES;
    
    [[[UIApplication sharedApplication] windows][0].rootViewController presentViewController:self.safariViewController animated:NO completion:nil];
    
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
  return @{@"device": @{@"os_version": [HOKDevice device].systemVersion,
                        @"device_type": [HOKDevice device].platform,
                        @"language": [HOKDevice device].systemLanguage.lowercaseString,
                        @"screen_size": [HOKDevice device].screenSize,
                        @"uid": [HOKDevice device].uid
                        }
           };
}



#pragma mark - SFSafariViewController delegate method
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
  [self.safariViewController dismissViewControllerAnimated:NO completion:nil];
  [self requestDeferredDeeplink];
}
#endif

@end

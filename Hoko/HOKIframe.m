//
//  HOKNetworking.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKIframe.h"
#import "HOKUtils.h"
#import "HOKNetworking.h"
#import "HOKNetworkOperation.h"
#import "HOKDevice.h"

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
#import <SafariServices/SafariServices.h>
#endif

@interface HOKIframe ()

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
<SFSafariViewControllerDelegate>
#endif

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
@property (nonatomic, strong) SFSafariViewController *safariViewController;
#endif

@end

@implementation HOKIframe

- (void)requestPage:(NSString *)withURL {
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    if (HOKSystemVersionGreaterThanOrEqualTo(@"9.0")) {
      // Create instance of SFViewController to open a URL
      self.safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:withURL]];
      self.safariViewController.delegate = self;
        
      // Create hidden controller
      UIViewController *rootViewController = [[UIViewController alloc] init];
      UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectZero];
      window.rootViewController = rootViewController;
      [window makeKeyAndVisible];
      window.alpha = 0;
        
      // Present controller
      [rootViewController presentViewController:self.safariViewController animated:NO completion:nil];
  }
#endif
}

#pragma mark - SFSafariViewController delegate method
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    [self.safariViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
#endif

@end

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

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000

@implementation HOKIframe

+ (void)requestPageWithURL:(NSString *)url completion:(void (^)(void))completion {
  if (completion) {
    completion();
  }
}

@end

#else

@interface HOKIframe ()

@property (nonatomic, strong) void(^completion)(void);

@end

@implementation HOKIframe

- (instancetype)initWithCompletion:(void(^)(void))completion {
  self = [super init];
  if (self) {
    self.completion = completion;
  }
  return self;
}

+ (void)requestPageWithURL:(NSString *)url completion:(void (^)(void))completion {
  Class SFSafariViewControllerClass = NSClassFromString(@"SFSafariViewController");
  if (SFSafariViewControllerClass) {
    HOKIframe *iframe = [[HOKIframe alloc] initWithCompletion:completion];
    id safariViewController = [[SFSafariViewControllerClass alloc] initWithURL:[NSURL URLWithString:url]];
    [safariViewController setDelegate:(id)iframe];
    
    // Create hidden controller
    UIViewController *rootViewController = [[UIViewController alloc] init];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectZero];
    window.rootViewController = rootViewController;
    [window makeKeyAndVisible];
    window.alpha = 0;
    
    // Present controller
    [rootViewController presentViewController:safariViewController animated:NO completion:nil];
  }
}

#pragma mark - SFSafariViewController delegate method
- (void)safariViewController:(UIViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
  [controller.presentingViewController dismissViewControllerAnimated:NO completion:nil];
  if (self.completion) {
    self.completion();
  }
}

@end

#endif


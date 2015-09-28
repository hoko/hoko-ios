//
//  HOKDeeplinking.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKDeeplinking.h"

#import "HOKURL.h"
#import "HOKError.h"
#import "HOKRouting.h"
#import "HOKObserver.h"
#import "HOKHandling.h"
#import "HOKFiltering.h"
#import "HOKSwizzling.h"
#import "HOKLinkGenerator.h"
#import "HOKRouting.h"
#import "HOKResolver.h"
#import "HOKDeeplink+Private.h"
#import "HOKDeferredDeeplinking.h"
#import "HOKDeeplinking+Private.h"
#import "HOKRouting+Private.h"

@interface HOKDeeplinking ()

@property (nonatomic, strong) NSString *customDomain;
@property (nonatomic, strong) HOKResolver *resolver;
@property (nonatomic, strong) HOKRouting *routing;
@property (nonatomic, strong) HOKHandling *handling;
@property (nonatomic, strong) HOKFiltering *filtering;
@property (nonatomic, strong) HOKLinkGenerator *linkGenerator;
@property (nonatomic, strong) HOKDeferredDeeplinking *deferredDeeplinking;
@property (nonatomic, strong) HOKDeeplink *currentDeeplink;

@end

@implementation HOKDeeplinking

#pragma mark - Initialization
- (instancetype)initWithToken:(NSString *)token customDomain:(NSString *)customDomain debugMode:(BOOL)debugMode {
  self = [super init];
  if (self) {
    _customDomain = customDomain;
    _routing = [[HOKRouting alloc] initWithToken:token debugMode:debugMode];
    _handling = [HOKHandling new];
    _filtering = [HOKFiltering new];
    _linkGenerator = [[HOKLinkGenerator alloc] initWithToken:token];
    _deferredDeeplinking = [[HOKDeferredDeeplinking alloc] initWithToken:token];
    _resolver = [[HOKResolver alloc] initWithToken:token];
    [self triggerDeferredDeeplinking];
  }
  return self;
}

#pragma mark - Current Deeplink
- (BOOL)openCurrentDeeplink {
  if (self.currentDeeplink)
    return [self openDeeplink:self.currentDeeplink];
  else
    return NO;
}

- (BOOL)isLaunchingFromDeeplinkWithOptions:(NSDictionary *)launchOptions
{
  return launchOptions != nil && launchOptions[UIApplicationLaunchOptionsURLKey];
}

#pragma mark - Map Routes
- (void)mapRoute:(NSString *)route toTarget:(void (^)(HOKDeeplink *deeplink))target {
  [self.routing mapRoute:route toTarget:target];
}

- (void)mapDefaultRouteToTarget:(void (^)(HOKDeeplink *deeplink))target {
  [self mapRoute:nil toTarget:target];
}

#pragma mark - Open URL
- (BOOL)handleOpenURL:(NSURL *)url {
  return [self openURL:url sourceApplication:nil annotation:nil];
}

- (BOOL)handleOpenDeferredURL:(NSURL *)url {
  return [self openURL:url sourceApplication:nil annotation:nil deferred:YES];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [self openURL:url sourceApplication:sourceApplication annotation:annotation deferred:NO];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation deferred:(BOOL)isDeferred {
  return [self.routing openURL:url sourceApplication:sourceApplication annotation:annotation deferredDeeplink:isDeferred];
}

- (BOOL)canOpenURL:(NSURL *)url {
  return [self.routing canOpenURL:url];
}

- (BOOL)openDeeplink:(HOKDeeplink *)deeplink {
  return [self.routing openDeeplink:deeplink];
}

- (void)openSmartlink:(NSString *)smartlink {
  [self openSmartlink:smartlink completion:nil];
}

- (void)openSmartlink:(NSString *)smartlink completion:(void (^)(HOKDeeplink *deeplink))completion {
  [self.resolver resolveSmartlink:smartlink completion:^(NSString *deeplink, NSDictionary *metadata, NSError *error) {
    if (deeplink) {
      NSURL *deeplinkURL = [NSURL URLWithString:deeplink];
      
      if ([self.routing openURL:deeplinkURL metadata:metadata]) {
        HOKDeeplink *deeplinkObject = [self.routing deeplinkForURL:deeplinkURL];
        deeplinkObject.metadata = metadata;
        if (completion && deeplinkURL) {
          completion([self.routing deeplinkForURL:deeplinkURL]);
        }
      }
      
    } else if (completion) {
      completion(nil);
    }
  }];
}

- (BOOL)continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
  if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
    NSURL *webpageURL = userActivity.webpageURL;
    if (webpageURL) {
      if ([webpageURL.host rangeOfString:@"hoko.link"].location != NSNotFound || [self.customDomain isEqualToString:webpageURL.host]) {
        [self openSmartlink:webpageURL.absoluteString completion:^(HOKDeeplink *deeplink) {
          if (!deeplink) {
            [self handleOpenURL:nil];
          }
        }];
        return YES;
      } else {
        return [self handleOpenURL:[HOKURL deeplinkifyURL:webpageURL]];
      }
    }
  }
  
  return NO;
}


#pragma mark - Handlers
- (void)addHandler:(id<HOKHandlerProcotol>)handler {
  [self.handling addHandler:handler];
}

- (void)addHandlerBlock:(void (^)(HOKDeeplink *deeplink))handlerBlock {
  [self.handling addHandlerBlock:handlerBlock];
}


#pragma mark - Filter Deep links
- (void)addFilterBlock:(BOOL (^)(HOKDeeplink *deeplink))filterBlock {
  [self.filtering addFilterBlock:filterBlock];
}


#pragma mark - Link Generation
- (void)generateSmartlinkForDeeplink:(HOKDeeplink *)deeplink
                             success:(void (^)(NSString *smartlink))success
                             failure:(void (^)(NSError *error))failure {
  
  [self.linkGenerator generateSmartlinkForDeeplink:deeplink success:success failure:failure];
}

- (NSString *)generateLazySmartlinkForDeeplink:(HOKDeeplink *)deeplink domain:(NSString *)domain
{
  return [self.linkGenerator generateLazySmartlinkForDeeplink:deeplink domain:domain customDomain:self.customDomain];
}

#pragma mark - Deferred Deeplinking
- (void)triggerDeferredDeeplinking {
  __block typeof(self) wself = self;
  __block HOKNotificationObserver *didFinishLaunchingNotificationObserver = [[HOKObserver observer] registerForNotification:UIApplicationDidFinishLaunchingNotification triggered:^(NSNotification *notification) {
    [wself.deferredDeeplinking requestDeferredDeeplink:^(NSString *deeplink) {
      if (!notification.userInfo[UIApplicationLaunchOptionsURLKey]) {
        [wself handleOpenDeferredURL:[NSURL URLWithString:deeplink]];
      }
    }];
    [[HOKObserver observer] removeObserver:didFinishLaunchingNotificationObserver];
  }];
}


#pragma mark - Swizzling
+ (void)load {
  [HOKSwizzling swizzleHOKDeeplinking];
}

@end
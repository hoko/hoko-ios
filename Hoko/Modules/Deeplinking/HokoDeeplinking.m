//
//  HokoAnalytics.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HokoDeeplinking.h"

#import "HKError.h"
#import "HKRouting.h"
#import "HKHandling.h"
#import "HKSwizzling.h"
#import "HKLinkGenerator.h"
#import "HokoDeeplinking+Private.h"

@interface HokoDeeplinking ()

@property (nonatomic, strong) HKRouting *routing;
@property (nonatomic, strong) HKHandling *handling;
@property (nonatomic, strong) HKLinkGenerator *linkGenerator;

@end

@implementation HokoDeeplinking

#pragma mark - Initialization
- (instancetype)initWithToken:(NSString *)token debugMode:(BOOL)debugMode
{
  self = [super init];
  if (self) {
    _routing = [[HKRouting alloc] initWithToken:token
                                      debugMode:debugMode];
    _handling = [HKHandling new];
    _linkGenerator = [[HKLinkGenerator alloc] initWithToken:token];
  }
  return self;
}

#pragma mark - Map Routes
- (void)mapRoute:(NSString *)route toTarget:(HKDeeplinkTarget)target
{
  [self.routing mapRoute:route toTarget:target];
}

- (void)mapDefaultRouteToTarget:(HKDeeplinkTarget)target
{
  [self mapRoute:nil toTarget:target];
}

#pragma mark - Open URL
- (BOOL)handleOpenURL:(NSURL *)url
{
  return [self openURL:url sourceApplication:nil annotation:nil];
}

- (BOOL)handleOpenURLFromForeground:(NSURL *)url
{
  return [self openURL:url sourceApplication:nil annotation:nil fromForeground:YES];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  return [self openURL:url sourceApplication:sourceApplication annotation:annotation fromForeground:NO];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation fromForeground:(BOOL)fromForeground
{
  return [self.routing openURL:url sourceApplication:sourceApplication annotation:annotation fromForeground:fromForeground];
}

- (BOOL)canOpenURL:(NSURL *)url
{
  return [self.routing canOpenURL:url];
}

#pragma mark - Handlers
- (void)addHandler:(id<HKHandlerProcotol>)handler
{
  [self.handling addHandler:handler];
}

- (void)addHandlerBlock:(void (^)(HKDeeplink *deeplink))handlerBlock
{
  [self.handling addHandlerBlock:handlerBlock];
}

#pragma mark - Link Generation
- (void)generateHokolinkForDeeplink:(HKDeeplink *)deeplink success:(void (^)(NSString *hokolink))success failure:(void (^)(NSError *))failure
{
  [self.linkGenerator generateHokolinkForDeeplink:deeplink success:success failure:failure];
}

#pragma mark - Swizzling
+ (void)load
{
  [HKSwizzling swizzleHokoDeeplinking];
}

@end
//
//  HKDeeplinking.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKDeeplinking.h"

#import "HKError.h"
#import "HKRouting.h"
#import "HKHandling.h"
#import "HKSwizzling.h"
#import "HKLinkGenerator.h"
#import "HKDeeplinking+Private.h"

@interface HKDeeplinking ()

@property (nonatomic, strong) HKRouting *routing;
@property (nonatomic, strong) HKHandling *handling;
@property (nonatomic, strong) HKLinkGenerator *linkGenerator;

@end

@implementation HKDeeplinking

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
- (void)mapRoute:(NSString *)route toTarget:(void (^)(HKDeeplink *deeplink))target
{
  [self.routing mapRoute:route toTarget:target];
}

- (void)mapDefaultRouteToTarget:(void (^)(HKDeeplink *deeplink))target
{
  [self mapRoute:nil toTarget:target];
}

#pragma mark - Open URL
- (BOOL)handleOpenURL:(NSURL *)url
{
  return [self openURL:url sourceApplication:nil annotation:nil];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  return [self.routing openURL:url sourceApplication:sourceApplication annotation:annotation];
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
- (void)generateSmartlinkForDeeplink:(HKDeeplink *)deeplink
                             success:(void (^)(NSString *martlink))success
                             failure:(void (^)(NSError *error))failure
{
  [self.linkGenerator generateSmartlinkForDeeplink:deeplink success:success failure:failure];
}

#pragma mark - Swizzling
+ (void)load
{
  [HKSwizzling swizzleHKDeeplinking];
}

@end
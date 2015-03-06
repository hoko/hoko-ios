//
//  HKRouting.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKRouting.h"

#import "HKApp.h"
#import "HKURL.h"
#import "HKError.h"
#import "HKRoute.h"
#import "HKLogger.h"
#import "HKHandling.h"
#import "Hoko+Private.h"
#import "HKNetworkOperation.h"
#import "HKNetworkOperationQueue.h"
#import "HKDeeplinking+Private.h"
#import "HKDeeplink+Private.h"
#import "HKAnalytics+Private.h"

@interface HKRouting ()

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) HKRoute *defaultRoute;

@end

@implementation HKRouting

#pragma mark - Initializer
- (instancetype)initWithToken:(NSString *)token
                    debugMode:(BOOL)debugMode
{
  self = [super init];
  if (self) {
    _debugMode = debugMode;
    _token = token;
    _routes = @[];
  }
  return self;
}

#pragma mark - Route mapping
- (void)mapRoute:(NSString *)route
        toTarget:(void (^)(HKDeeplink *deeplink))target
{
  if([self routeExists:route])
    HKErrorLog([HKError duplicateRouteError:route]);
  else if ([HKApp app].hasURLSchemes)
    [self addNewRoute:[HKRoute routeWithRoute:[HKURL sanitizeURLString:route] target:target]];
  else
    HKErrorLog([HKError noURLSchemesError]);
}

#pragma mark - Open URL
- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  HKURL *hkURL = [[HKURL alloc]initWithURL:url];
  NSDictionary *routeParameters;
  // Search for a match with any given route
  for (HKRoute *route in self.routes) {
    if([hkURL matchesWithRoute:route routeParameters:&routeParameters]) {
      HKDeeplink *deeplink = [HKDeeplink deeplinkWithURLScheme:hkURL.scheme
                                                         route:route.route
                                               routeParameters:routeParameters
                                               queryParameters:hkURL.queryParameters
                                             sourceApplication:sourceApplication];
      
      [[Hoko deeplinking].handling handle:deeplink];
      
      if(route.target) {
        route.target(deeplink);
      }
      
      return YES;
    }
  }
  
  // Default Route
  if(self.defaultRoute) {
    HKDeeplink *deeplink = [HKDeeplink deeplinkWithURLScheme:hkURL.scheme
                                                       route:nil
                                             routeParameters:nil
                                             queryParameters:hkURL.queryParameters
                                           sourceApplication:sourceApplication];
    
    [[Hoko deeplinking].handling handle:deeplink];
    
    if(self.defaultRoute.target) {
      self.defaultRoute.target(deeplink);
    }
    
    return YES;
  }
  return NO;
}


#pragma mark - Add Route
- (void)addNewRoute:(HKRoute *)route
{
  if (!route.route) {
    self.defaultRoute = route;
    return;
  }
  
  self.routes = [self.routes arrayByAddingObject:route];
  
  // POST routes to the backend only in debug mode
  if (self.debugMode)
    [route postWithToken:self.token];
}

#pragma mark - Validations
- (BOOL)routeExists:(NSString *)route
{
  for (HKRoute *routeObj in self.routes) {
    if([routeObj.route isEqualToString:[HKURL sanitizeURLString:route]])
      return YES;
  }
  
  return NO;
}


@end

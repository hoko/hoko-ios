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
        toTarget:(HKDeeplinkTarget)target
{
  if([self routeExists:route])
    HKErrorLog([HKError duplicateRouteError:route]);
  else if ([HKApp app].hasURLSchemes)
    [self addNewRoute:[HKRoute routeWithRoute:[HKURL sanitizeURLString:route] target:target]];
  else
    HKErrorLog([HKError noURLSchemesError]);
}

#pragma mark - Open URL
- (BOOL)openURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
     annotation:(id)annotation
 fromForeground:(BOOL)fromForeground
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
      
      // If deeplink comes from foreground (a.k.a. push notification while in the app) dont open it but rather
      // warn the backend that it was received but won't ever be opened. Otherwise do the handling calls and
      // call the target.
      if (!fromForeground) {
        [[Hoko deeplinking].handling handle:deeplink];
        if(route.target)
          route.target(deeplink);
      } else {
        [deeplink postWithToken:self.token
                           user:[[Hoko analytics] currentUser]
                     statusCode:HKDeeplinkStatusIgnored];
      }
    }
  }
  
  // Default Route
  if(self.defaultRoute) {
    if(self.defaultRoute.target) {
      HKDeeplink *deeplink = [HKDeeplink deeplinkWithURLScheme:hkURL.scheme
                                                         route:nil
                                               routeParameters:nil
                                               queryParameters:hkURL.queryParameters
                                             sourceApplication:sourceApplication];
      
      // Applies the same behavior as a common route.
      if (!fromForeground) {
        [[Hoko deeplinking].handling handle:deeplink];
        self.defaultRoute.target(deeplink);
      } else {
        [deeplink postWithToken:self.token
                           user:[[Hoko analytics] currentUser]
                     statusCode:HKDeeplinkStatusIgnored];
      }
    }
  }
  return [self canOpenURL:url];
}

- (BOOL)canOpenURL:(NSURL *)url
{
  // If a default route exists it can always open the URL
  if(self.defaultRoute) {
    return YES;
  }
  
  // Look for a matching route for this URL
  HKURL *hkURL = [[HKURL alloc] initWithURL:url];
  
  // Search for a match with any given route
  for (HKRoute *route in self.routes) {
    if([hkURL matchesWithRoute:route routeParameters:nil]) {
      return YES;
    }
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

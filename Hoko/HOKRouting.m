//
//  HOKRouting.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKRouting.h"

#import "HOKApp.h"
#import "HOKURL.h"
#import "HOKError.h"
#import "HOKRoute.h"
#import "HOKLogger.h"
#import "HOKRouting.h"
#import "HOKHandling.h"
#import "HOKFiltering.h"
#import "Hoko+Private.h"
#import "HOKNetworkOperation.h"
#import "HOKNetworkOperationQueue.h"
#import "HOKDeeplinking+Private.h"
#import "HOKDeeplink+Private.h"

@interface HOKRouting ()

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) HOKRoute *defaultRoute;

@end

@implementation HOKRouting

#pragma mark - Initializer
- (instancetype)initWithToken:(NSString *)token debugMode:(BOOL)debugMode {
  self = [super init];
  if (self) {
    _debugMode = debugMode;
    _token = token;
    _routes = @[];
  }
  return self;
}

#pragma mark - Route mapping
- (void)mapRoute:(NSString *)route toTarget:(void (^)(HOKDeeplink *deeplink))target {
  
  if ([self routeExists:route]) {
    HOKErrorLog([HOKError duplicateRouteError:route]);
  } else if ([HOKApp app].hasURLSchemes) {
    [self addNewRoute:[HOKRoute routeWithRoute:[HOKURL sanitizeURLString:route] target:target]];
  } else {
    HOKErrorLog([HOKError noURLSchemesError]);
  }
}

- (NSArray *)routes {
  return _routes;
}

#pragma mark - Open URL
- (BOOL)openURL:(NSURL *)url metadata:(NSDictionary *)metadata
{
  return [self openURL:url sourceApplication:nil annotation:nil metadata:metadata deferredDeeplink:NO];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation deferredDeeplink:(BOOL)isDeferred
{
  return [self openURL:url sourceApplication:sourceApplication annotation:annotation metadata:nil deferredDeeplink:isDeferred];
}

- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation metadata:(NSDictionary *)metadata deferredDeeplink:(BOOL)isDeferred
{
  HOKRoute *route;
  HOKDeeplink *deeplink = [self deeplinkForURL:url sourceApplication:sourceApplication annotation:annotation metadata:metadata route:&route deferred:isDeferred];
  if (deeplink.needsMetadata) {
    [deeplink requestMetadataWithToken:self.token completion:^{
      [self openDeeplink:deeplink route:route];
    }];
    return route != nil;
  } else {
    return [self openDeeplink:deeplink route:route];
  }
}

- (BOOL)openDeeplink:(HOKDeeplink *)deeplink {
  for (HOKRoute *hokRoute in self.routes) {
    if ([hokRoute.route isEqualToString:deeplink.route]) {
      return [self openDeeplink:deeplink route:hokRoute];
    }
  }
  
  return NO;
}

- (BOOL)openDeeplink:(HOKDeeplink *)deeplink route:(HOKRoute *)route {
  [Hoko deeplinking].currentDeeplink = deeplink;
  
  [deeplink postWithToken:self.token];
  if (route) {
    if ([[Hoko deeplinking].filtering filter:deeplink]) {
      [[Hoko deeplinking].handling handle:deeplink];
      
      if (route.target) {
        route.target(deeplink);
      }
      
      deeplink.wasOpened = YES;
      
      return YES;
    }
  }
  return NO;
}


- (HOKDeeplink *)deeplinkForURL:(NSURL *)url {
  return [self deeplinkForURL:url sourceApplication:nil annotation:nil metadata:nil route:nil deferred:NO];
}

- (HOKDeeplink *)deeplinkForURL:(NSURL *)url metadata:(NSDictionary *)metadata {
  return [self deeplinkForURL:url sourceApplication:nil annotation:nil metadata:metadata route:nil deferred:NO];
}

- (HOKDeeplink *)deeplinkForURL:(NSURL *)url
              sourceApplication:(NSString *)sourceApplication
                     annotation:(id)annotation
                       metadata:(NSDictionary *)metadata
                          route:(HOKRoute **)route
                       deferred:(BOOL)isDeferred {
  
  HOKURL *hokURL = [[HOKURL alloc] initWithURL:url];
  NSDictionary *routeParameters;
  // Search for a match with any given route
  for (HOKRoute *hokRoute in self.routes) {
    if ([hokURL matchesWithRoute:hokRoute routeParameters:&routeParameters]) {
      HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithURLScheme:hokURL.scheme
                                                           route:hokRoute.route
                                                 routeParameters:routeParameters
                                                 queryParameters:hokURL.queryParameters
                                                        metadata:metadata
                                               sourceApplication:sourceApplication
                                                     deeplinkURL:url.absoluteString
                                                        deferred:isDeferred
                                                          unique:NO];
      if (route) {
        *route = hokRoute;
      }
      return deeplink;
    }
  }
  
  // Default Route
  HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithURLScheme:hokURL.scheme
                                                       route:nil
                                             routeParameters:nil
                                             queryParameters:hokURL.queryParameters
                                                    metadata:metadata
                                           sourceApplication:sourceApplication
                                                 deeplinkURL:url.absoluteString
                                                    deferred:isDeferred
                                                      unique:NO];
  if (self.defaultRoute) {
    *route = self.defaultRoute;
  }
  
  return deeplink;
}

- (BOOL)canOpenURL:(NSURL *)url {
  // If a default route exists it can always open the URL
  if (self.defaultRoute) {
    return YES;
  }
  
  // Look for a matching route for this URL
  HOKURL *hokURL = [[HOKURL alloc] initWithURL:url];
  
  // Search for a match with any given route
  for (HOKRoute *route in self.routes) {
    if ([hokURL matchesWithRoute:route routeParameters:nil]) {
      return YES;
    }
  }
  
  return NO;
}


#pragma mark - Add Route
- (void)addNewRoute:(HOKRoute *)route {
  if (!route.route) {
    self.defaultRoute = route;
    return;
  }
  
  self.routes = [HOKRouting sortedRoutes:[self.routes arrayByAddingObject:route]];
  
  // POST routes to the backend only in debug mode
  if (self.debugMode) {
    [route postWithToken:self.token];
  }
}

#pragma mark - Validations
- (BOOL)routeExists:(NSString *)route {
  for (HOKRoute *routeObj in self.routes) {
    if ([routeObj.route isEqualToString:[HOKURL sanitizeURLString:route]]) {
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Sorting
+ (NSArray *)sortedRoutes:(NSArray *)routes {
  return [routes sortedArrayUsingComparator:^NSComparisonResult(HOKRoute *route1, HOKRoute *route2) {
    // lesser components have higher priority
    if (route1.components.count != route2.components.count) {
      return route1.components.count < route2.components.count ? NSOrderedAscending : NSOrderedDescending;
    }
    
    for (NSInteger index = 0; index < route1.components.count; index ++) {
      NSString *component1 = [route1.components objectAtIndex:index];
      NSString *component2 = [route2.components objectAtIndex:index];
      
      BOOL component1IsParameter = [component1 hasPrefix:@":"];
      BOOL component2IsParameter = [component2 hasPrefix:@":"];
      
      if (component1IsParameter && component2IsParameter) {
        continue;
      }
      
      if (component1IsParameter) {
        return NSOrderedDescending;
      }
      
      if (component2IsParameter) {
        return NSOrderedAscending;
      }
    }
    
    return [route1.route compare:route2.route];
  }];
}

@end

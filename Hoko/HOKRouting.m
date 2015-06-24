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
#import "HOKHandling.h"
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
        toTarget:(void (^)(HOKDeeplink *deeplink))target
{
    if([self routeExists:route])
        HOKErrorLog([HOKError duplicateRouteError:route]);
    else if ([HOKApp app].hasURLSchemes)
        [self addNewRoute:[HOKRoute routeWithRoute:[HOKURL sanitizeURLString:route] target:target]];
    else
        HOKErrorLog([HOKError noURLSchemesError]);
}

#pragma mark - Open URL
- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    HOKURL *hkURL = [[HOKURL alloc]initWithURL:url];
    NSDictionary *routeParameters;
    // Search for a match with any given route
    for (HOKRoute *route in self.routes) {
        if([hkURL matchesWithRoute:route routeParameters:&routeParameters]) {
            HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithURLScheme:hkURL.scheme
                                                               route:route.route
                                                     routeParameters:routeParameters
                                                     queryParameters:hkURL.queryParameters
                                                   sourceApplication:sourceApplication
                                                         deeplinkURL:url.absoluteString];
            [deeplink postWithToken:self.token];
            [[Hoko deeplinking].handling handle:deeplink];
            if(route.target) {
                route.target(deeplink);
            }
            return YES;
        }
    }
    
    // Default Route
    HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithURLScheme:hkURL.scheme
                                                       route:nil
                                             routeParameters:nil
                                             queryParameters:hkURL.queryParameters
                                           sourceApplication:sourceApplication
                                                 deeplinkURL:url.absoluteString];
    [deeplink postWithToken:self.token];
    [[Hoko deeplinking].handling handle:deeplink];
    if(self.defaultRoute && self.defaultRoute.target) {
        self.defaultRoute.target(deeplink);
        return YES;
    }
    
    return NO;
}

- (BOOL)canOpenURL:(NSURL *)url
{
    // If a default route exists it can always open the URL
    if(self.defaultRoute) {
        return YES;
    }
    
    // Look for a matching route for this URL
    HOKURL *hkURL = [[HOKURL alloc] initWithURL:url];
    
    // Search for a match with any given route
    for (HOKRoute *route in self.routes) {
        if([hkURL matchesWithRoute:route routeParameters:nil]) {
            return YES;
        }
    }
    
    return NO;
}


#pragma mark - Add Route
- (void)addNewRoute:(HOKRoute *)route
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
    for (HOKRoute *routeObj in self.routes) {
        if([routeObj.route isEqualToString:[HOKURL sanitizeURLString:route]])
            return YES;
    }
    
    return NO;
}


@end

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
#import "HOKRouting.h"

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
    HOKRoute *route;
    HOKDeeplink *deeplink = [self deeplinkForURL:url sourceApplication:sourceApplication annotation:annotation route:&route];
    [deeplink postWithToken:self.token];
    if (route) {
        if (route.target) {
            route.target(deeplink);
        }
        return YES;
    }
    return NO;
}

- (HOKDeeplink *)deeplinkForURL:(NSURL *)url
{
    return [self deeplinkForURL:url sourceApplication:nil annotation:nil route:nil];
}

- (HOKDeeplink *)deeplinkForURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation route:(HOKRoute **)route
{
    HOKURL *hokURL = [[HOKURL alloc]initWithURL:url];
    NSDictionary *routeParameters;
    // Search for a match with any given route
    for (HOKRoute *hokRoute in self.routes) {
        if([hokURL matchesWithRoute:hokRoute routeParameters:&routeParameters]) {
            HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithURLScheme:hokURL.scheme
                                                                 route:hokRoute.route
                                                       routeParameters:routeParameters
                                                       queryParameters:hokURL.queryParameters
                                                     sourceApplication:sourceApplication
                                                           deeplinkURL:url.absoluteString];
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
                                             sourceApplication:sourceApplication
                                                   deeplinkURL:url.absoluteString];
    if (self.defaultRoute) {
        *route = self.defaultRoute;
    }
    
    return deeplink;
}

- (BOOL)canOpenURL:(NSURL *)url
{
    // If a default route exists it can always open the URL
    if(self.defaultRoute) {
        return YES;
    }
    
    // Look for a matching route for this URL
    HOKURL *hokURL = [[HOKURL alloc] initWithURL:url];
    
    // Search for a match with any given route
    for (HOKRoute *route in self.routes) {
        if([hokURL matchesWithRoute:route routeParameters:nil]) {
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

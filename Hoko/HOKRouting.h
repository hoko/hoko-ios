//
//  HOKRouting.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HOKDeeplink;

@interface HOKRouting : NSObject

- (instancetype)initWithToken:(NSString *)token debugMode:(BOOL)debugMode;

- (void)mapRoute:(NSString *)route toTarget:(void (^)(HOKDeeplink *deeplink))target;
- (BOOL)openURL:(NSURL *)url metadata:(NSDictionary *)metadata;
- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation deferredDeeplink:(BOOL)isDeferred;
- (BOOL)canOpenURL:(NSURL *)url;
- (HOKDeeplink *)deeplinkForURL:(NSURL *)url;
- (HOKDeeplink *)deeplinkForURL:(NSURL *)url metadata:(NSDictionary *)metadata;
- (BOOL)routeExists:(NSString *)route;
- (NSArray *)routes;
@end

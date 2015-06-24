//
//  HOKRouting.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

@class HOKDeeplink;

@interface HOKRouting : NSObject

- (instancetype)initWithToken:(NSString *)token debugMode:(BOOL)debugMode;

- (void)mapRoute:(NSString *)route toTarget:(void (^)(HOKDeeplink *deeplink))target;
- (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (BOOL)canOpenURL:(NSURL *)url;
- (BOOL)routeExists:(NSString *)route;

@end

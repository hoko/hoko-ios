//
//  HOKRoute.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HOKDeeplink;

@interface HOKRoute : NSObject

+ (instancetype)routeWithRoute:(NSString *)route target:(void (^)(HOKDeeplink *deeplink))target;

- (void)postWithToken:(NSString *)token;

@property (nonatomic, strong, readonly) NSString *route;
@property (nonatomic, strong, readonly) NSArray *components;
@property (nonatomic, copy, readonly) void (^target)(HOKDeeplink *deeplink);

@property (nonatomic, strong, readonly) NSDictionary *json;

@end

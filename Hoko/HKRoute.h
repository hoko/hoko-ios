//
//  HKRoute.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

@class HKDeeplink;

@interface HKRoute : NSObject

+ (instancetype)routeWithRoute:(NSString *)route target:(void (^)(HKDeeplink *deeplink))target;

- (void)postWithToken:(NSString *)token;

@property (nonatomic, strong, readonly) NSString *route;
@property (nonatomic, strong, readonly) NSArray *components;
@property (nonatomic, copy, readonly) void (^target)(HKDeeplink *deeplink);

@property (nonatomic, strong, readonly) id json;

@end

//
//  HKDeeplink.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Hoko+Nullability.h"

typedef NS_ENUM(NSUInteger, HKDeeplinkPlatform) {
    HKDeeplinkPlatformiPhone,
    HKDeeplinkPlatformiPad,
    HKDeeplinkPlatformiOSUniversal,
    HKDeeplinkPlatformAndroid,
    HKDeeplinkPlatformWeb,
};

@interface HKDeeplink : NSObject

+ (hk_nonnull instancetype)deeplinkWithRoute:(hk_nullable NSString *)route
                  routeParameters:(hk_nullable NSDictionary *)routeParameters
                  queryParameters:(hk_nullable NSDictionary *)queryParameters;

- (hk_nonnull instancetype)initWithRoute:(hk_nullable NSString *)route
              routeParameters:(hk_nullable NSDictionary *)routeParameters
              queryParameters:(hk_nullable NSDictionary *)queryParameters;

- (void)addURL:(hk_nonnull NSString *)url forPlatform:(HKDeeplinkPlatform)platform;

@property (hk_nullable, nonatomic, strong, readonly) NSString *route;
@property (hk_nullable, nonatomic, strong, readonly) NSDictionary *queryParameters;
@property (hk_nullable, nonatomic, strong, readonly) NSDictionary *routeParameters;
@property (hk_nonnull, nonatomic, strong, readonly) NSDictionary *json;

@end


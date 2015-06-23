//
//  HKDeeplink.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HKDeeplinkPlatform) {
    HKDeeplinkPlatformiPhone,
    HKDeeplinkPlatformiPad,
    HKDeeplinkPlatformiOSUniversal,
    HKDeeplinkPlatformAndroid,
    HKDeeplinkPlatformWeb,
};

@interface HKDeeplink : NSObject

+ (nonnull instancetype)deeplinkWithRoute:(nullable NSString *)route
                  routeParameters:(nullable NSDictionary *)routeParameters
                  queryParameters:(nullable NSDictionary *)queryParameters;

- (nonnull instancetype)initWithRoute:(nullable NSString *)route
              routeParameters:(nullable NSDictionary *)routeParameters
              queryParameters:(nullable NSDictionary *)queryParameters;

- (void)addURL:(nonnull NSString *)url forPlatform:(HKDeeplinkPlatform)platform;

@property (nullable, nonatomic, strong, readonly) NSString *route;
@property (nullable, nonatomic, strong, readonly) NSDictionary *queryParameters;
@property (nullable, nonatomic, strong, readonly) NSDictionary *routeParameters;
@property (nonnull, nonatomic, strong, readonly) NSDictionary *json;

@end


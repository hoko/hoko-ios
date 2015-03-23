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

+ (instancetype)deeplinkWithRoute:(NSString *)route
                  routeParameters:(NSDictionary *)routeParameters
                  queryParameters:(NSDictionary *)queryParameters;

- (instancetype)initWithRoute:(NSString *)route
              routeParameters:(NSDictionary *)routeParameters
              queryParameters:(NSDictionary *)queryParameters;

- (void)addURL:(NSString *)url forPlatform:(HKDeeplinkPlatform)platform;

@property (nonatomic, strong, readonly) NSString *route;
@property (nonatomic, strong, readonly) NSDictionary *queryParameters;
@property (nonatomic, strong, readonly) NSDictionary *routeParameters;

@end


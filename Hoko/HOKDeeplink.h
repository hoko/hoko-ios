//
//  HOKDeeplink.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Hoko+Macros.h"

typedef NS_ENUM(NSUInteger, HOKDeeplinkPlatform) {
    HOKDeeplinkPlatformIPhone,
    HOKDeeplinkPlatformIPad,
    HOKDeeplinkPlatformIOSUniversal,
    HOKDeeplinkPlatformAndroid,
    HOKDeeplinkPlatformWeb,
};

@interface HOKDeeplink : NSObject

+ (hok_nonnull instancetype)deeplink;

+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route;

+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route
                              routeParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)routeParameters;

+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route
                              routeParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)routeParameters
                              queryParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)queryParameters;

+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route
                              routeParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)routeParameters
                              queryParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)queryParameters
                                     metadata:(hok_nullable NSDictionary hok_generic2(NSString *, id) *)metadata;


- (void)addURL:(hok_nonnull NSString *)url forPlatform:(HOKDeeplinkPlatform)platform;

@property (nonatomic, strong, readonly, hok_nullable) NSString *route;
@property (nonatomic, strong, readonly, hok_nullable) NSDictionary hok_generic2(NSString *, NSString *) *queryParameters;
@property (nonatomic, strong, readonly, hok_nullable) NSDictionary hok_generic2(NSString *, NSString *) *routeParameters;
@property (nonatomic, strong, readonly, hok_nullable) NSDictionary hok_generic2(NSString *, id) *metadata;
@property (nonatomic, strong, readonly, hok_nonnull) NSDictionary hok_generic2(NSString *, id) *json;

@end


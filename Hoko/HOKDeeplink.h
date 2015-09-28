//
//  HOKDeeplink.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Hoko+Macros.h"

/**
 * An enum that contains all the possible URL platforms.
 */
typedef NS_ENUM(NSUInteger, HOKDeeplinkPlatform) {
    HOKDeeplinkPlatformIPhone,
    HOKDeeplinkPlatformIPad,
    HOKDeeplinkPlatformIOSUniversal,
    HOKDeeplinkPlatformAndroid,
    HOKDeeplinkPlatformWeb,
};

@interface HOKDeeplink : NSObject

/**
 *  Creates and returns a new HOKDeeplink object with all the parameters set to nil.
 *
 *  @return A new HOKDeeplink instance.
 */
+ (hok_nonnull instancetype)deeplink;

/**
 *  Creates and returns a new HOKDeeplink object with a given route.
 *
 *  @param route A NSString that holds a route (for instance, "product/:product_id").
 *
 *  @return A new HOKDeeplink instance with a given route.
 */
+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route;

/**
 *  Creates and returns a new HOKDeeplink object with a given route and route parameters.
 *
 *  @param route           A NSString that holds a route (for instance, "product/:product_id").
 *  @param routeParameters A NSDictionary that contains the route parameters and their values.
 *
 *  @return A new HOKDeeplink instance with a given route and route parameters.
 */
+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route
                              routeParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)routeParameters;

/**
 *  Creates and returns a new HOKDeeplink object with a given route, route parameters and query parameters.
 *
 *  @param route           A NSString that holds a route (for instance, "product/:product_id").
 *  @param routeParameters A NSDictionary that contains the route parameters and their values.
 *  @param queryParameters A NSDictionary that contains the query parameters and their values.
 *
 *  @return A new HOKDeeplink instance with a given route, route parameters and query parameters.
 */
+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route
                              routeParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)routeParameters
                              queryParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)queryParameters;

/**
 *  Creates and returns a new HOKDeeplink object with a given route, route parameters, query parameters and metadata.
 *
 *  @param route           A NSString that holds a route (for instance, "product/:product_id").
 *  @param routeParameters A NSDictionary that contains the route parameters and their values.
 *  @param queryParameters A NSDictionary that contains the query parameters and their values.
 *  @param metadata        A NSDictionary that contains all the metadata values.
 *
 *  @return A new HOKDeeplink instance with a given route, route parameters, query parameters and metadatas.
 */
+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route
                              routeParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)routeParameters
                              queryParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)queryParameters
                                     metadata:(hok_nullable NSDictionary hok_generic2(NSString *, id) *)metadata;

/**
 *  Creates and returns a new HOKDeeplink object with a given route, route parameters, query parameters and metadata.
 *
 *  @param route           A NSString that holds a route (for instance, "product/:product_id").
 *  @param routeParameters A NSDictionary that contains the route parameters and their values.
 *  @param queryParameters A NSDictionary that contains the query parameters and their values.
 *  @param metadata        A NSDictionary that contains all the metadata values.
 *  @param unique          A BOOL value to reflect if the link should be unique or not.
 *
 *  @return A new HOKDeeplink instance with a given route, route parameters, query parameters and metadatas.
 */
+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route
                              routeParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)routeParameters
                              queryParameters:(hok_nullable NSDictionary hok_generic2(NSString *, NSString *) *)queryParameters
                                     metadata:(hok_nullable NSDictionary hok_generic2(NSString *, id) *)metadata
                                       unique:(BOOL)unique;

/**
 *  Adds a new URL entry that will be opened in a given platform. There can only be one URL for each individual platform.
 *
 *  @param url      A non null NSString that represents which link should be opened for the given platform.
 *  @param platform A platform that will be used to know which URL should be opened.
 */
- (void)addURL:(hok_nonnull NSString *)url forPlatform:(HOKDeeplinkPlatform)platform;

/**
 *  The route of the current HOKDeeplink object, which can be something like "products/:product_id".
 *  If the object does not contain a valid route, it's null instead.
 */
@property (nonatomic, strong, readonly, hok_nullable) NSString *route;

/**
 *  The query parameters of the current HOKDeeplink object. For instace, if the URL is "products/2?referrer=myfriend"
 *  this property will hold a NSDictionary that contains the key "referrer" and the value "myfriend".
 */
@property (nonatomic, strong, readonly, hok_nullable) NSDictionary hok_generic2(NSString *, NSString *) *queryParameters;

/**
 *  The route parameters of the current HOKDeeplink object. For instance, if the route is "products/:product_id"
 *  and the URL is "products/2", this property will hold a NSDictionary that contains the key "product_id" and the value "2".
 */
@property (nonatomic, strong, readonly, hok_nullable) NSDictionary hok_generic2(NSString *, NSString *) *routeParameters;

/**
 *  The metadata of the current HOKDeeplink object. This metadata can be created manually when initalizing a new HOKDeeplink instance
 *  using the static methods above or through http://hokolinks.com (Edit a smart link > Advanced tab). This NSDictionary property contains 
 *  private information that is not accessible through the URL.
 */
@property (nonatomic, strong, readonly, hok_nullable) NSDictionary hok_generic2(NSString *, id) *metadata;

/**
 *  The JSON value of the current HOKDeeplink object.
 */
@property (nonatomic, strong, readonly, hok_nonnull) NSDictionary hok_generic2(NSString *, id) *json;

/**
 *  A boolean parameter that indicates whether this HOKDeeplink object is a deferred deep link,
 *  meaning that the user clicked on a HOKO smart link and it was redirected to the App Store
 *  to download the app because it didn't have it earlier. After that, when the user launches the 
 *  app, HOKO will try to get a deferred link: if it exists, it will try to open.
 */
@property (nonatomic, readonly) BOOL isDeferred;

/**
 *  A boolean parameter that indicates whether this deep link object was already opened or not.
 */
@property (nonatomic, readonly) BOOL wasOpened;

@end


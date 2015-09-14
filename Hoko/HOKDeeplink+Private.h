//
//  HOKDeeplink+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKDeeplinking.h"

#import "HOKDeeplink.h"

extern NSString *const HOKDeeplinkSmartlinkIdentifierKey;

@interface HOKDeeplink (Private)

+ (HOKDeeplink *)deeplinkWithURLScheme:(NSString *)urlScheme
                                 route:(NSString *)route
                       routeParameters:(NSDictionary *)routeParameters
                       queryParameters:(NSDictionary *)queryParameters
                              metadata:(NSDictionary *)metadata
                     sourceApplication:(NSString *)sourceApplication
                           deeplinkURL:(NSString *)deeplinkURL
                              deferred:(BOOL)isDeferred
                                unique:(BOOL)unique;

- (void)setMetadata:(NSDictionary *)metadata;
- (void)postWithToken:(NSString *)token;
- (void)requestMetadataWithToken:(NSString *)token completion:(void (^)(void))completion;

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSString *sourceApplication;
@property (nonatomic, strong, readonly) NSDictionary *generateSmartlinkJSON;

@property (nonatomic, strong, readonly) NSString *smartlinkClickIdentifier;
@property (nonatomic, strong, readonly) NSString *smartlinkIdentifier;

@property (nonatomic, readonly) BOOL isSmartlink;
@property (nonatomic, readonly) BOOL hasURLs;
@property (nonatomic, readonly) BOOL needsMetadata;

@property (nonatomic) BOOL isDeferred;
@property (nonatomic) BOOL wasOpened;
@property (nonatomic, strong, readonly) NSString *url;

@end
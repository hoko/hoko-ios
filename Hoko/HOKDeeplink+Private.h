//
//  HOKDeeplink+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKDeeplink.h"

extern NSString *const HOKDeeplinkSmartlinkIdentifierKey;

@interface HOKDeeplink (Private)

+ (HOKDeeplink *)deeplinkWithURLScheme:(NSString *)urlScheme
                                route:(NSString *)route
                      routeParameters:(NSDictionary *)routeParameters
                      queryParameters:(NSDictionary *)queryParameters
                    sourceApplication:(NSString *)sourceApplication
                          deeplinkURL:(NSString *)deeplinkURL;

- (void)postWithToken:(NSString *)token;

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSString *sourceApplication;
@property (nonatomic, strong, readonly) NSDictionary *generateSmartlinkJSON;

@property (nonatomic, strong, readonly) NSString *smartlinkClickIdentifier;

@property (nonatomic, readonly) BOOL isSmartlink;
@property (nonatomic, readonly) BOOL hasURLs;

@end
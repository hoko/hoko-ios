//
//  HKDeeplink+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKDeeplink.h"

@class HKUser;

extern NSString *const HKDeeplinkSmartlinkIdentifierKey;
extern NSString *const HKDeeplinkOpenIdentifierKey;

typedef NS_ENUM(NSUInteger, HKDeeplinkStatus) {
    HKDeeplinkStatusOpened = 3,
    HKDeeplinkStatusIgnored = 4,
};

@interface HKDeeplink (Private)

+ (HKDeeplink *)deeplinkWithURLScheme:(NSString *)urlScheme
                                route:(NSString *)route
                      routeParameters:(NSDictionary *)routeParameters
                      queryParameters:(NSDictionary *)queryParameters
                    sourceApplication:(NSString *)sourceApplication;

- (void)postWithToken:(NSString *)token statusCode:(HKDeeplinkStatus)statusCode;

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSString *sourceApplication;
@property (nonatomic, strong, readonly) id json;

@property (nonatomic, strong, readonly) NSString *smartlinkIdentifier;
@property (nonatomic, strong, readonly) NSString *openIdentifier;

@property (nonatomic, readonly) BOOL isSmartlink;
@property (nonatomic, readonly) BOOL hasURLs;

@end
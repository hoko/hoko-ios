//
//  HKDeeplink+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKDeeplink.h"

@class HKUser;

extern NSString *const HKDeeplinkHokolinkIdentifierKey;
extern NSString *const HKDeeplinkOpenIdentifierKey;

typedef NS_ENUM(NSUInteger, HKDeeplinkStatus) {
    HKDeeplinkStatusOpened = 3,
    HKDeeplinkStatusIgnored = 4
};

@interface HKDeeplink (Private)

+ (HKDeeplink *)deeplinkWithURLScheme:(NSString *)urlScheme
                                route:(NSString *)route
                      routeParameters:(NSDictionary *)routeParameters
                      queryParameters:(NSDictionary *)queryParameters
                    sourceApplication:(NSString *)sourceApplication;

- (void)postWithToken:(NSString *)token user:(HKUser *)user statusCode:(HKDeeplinkStatus)statusCode;

- (NSDictionary *)notificationJSONWithUser:(HKUser *)user;

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSString *sourceApplication;
@property (nonatomic, strong, readonly) id json;

@property (nonatomic, strong, readonly) NSString *hokolinkIdentifier;
@property (nonatomic, strong, readonly) NSString *openIdentifier;

@property (nonatomic, readonly) BOOL isHokolink;

@end
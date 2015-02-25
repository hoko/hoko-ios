//
//  HokoPushNotifications+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <UIKit/UIApplication.h>

@interface HokoPushNotifications (Private)

+ (instancetype)pushNotificationsWithToken:(NSString *)token;

- (UIApplication *)application;

@property (nonatomic, strong) NSString *token;

@end
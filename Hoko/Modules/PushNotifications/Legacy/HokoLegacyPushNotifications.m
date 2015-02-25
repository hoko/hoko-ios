//
//  HokoLegacyPushNotifications.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HokoLegacyPushNotifications.h"

#import "HKSwizzling.h"
#import "HokoPushNotifications+Private.h"

@implementation HokoLegacyPushNotifications

#pragma mark - Initializer
- (instancetype)initWithToken:(NSString *)token
{
  self = [super init];
  if (self) {
    self.token = token;
  }
  return self;
}

#pragma mark - Push Notifications
- (void)registerForRemoteNotificationTypes:(HKRemoteNotificationType)types
{
  [self.application registerForRemoteNotificationTypes:[self remoteNotificationTypesFromHKRemoteNotificationTypes:types]];
}

#pragma mark - Helpers
- (UIRemoteNotificationType)remoteNotificationTypesFromHKRemoteNotificationTypes:(HKRemoteNotificationType)types
{
  UIRemoteNotificationType userNotificationTypes = 0;
  if (types & HKRemoteNotificationTypeSound) {
    userNotificationTypes = userNotificationTypes | UIRemoteNotificationTypeSound;
  }
  
  if (types & HKRemoteNotificationTypeBadge) {
    userNotificationTypes = userNotificationTypes | UIRemoteNotificationTypeBadge;
  }
  
  if (types & HKRemoteNotificationTypeAlert) {
    userNotificationTypes = userNotificationTypes | UIRemoteNotificationTypeAlert;
  }
  return userNotificationTypes;
}

#pragma mark - Swizzling
+ (void)load
{
  if (!HKSystemVersionGreaterThanOrEqualTo(@"8.0"))
    [HKSwizzling swizzleLegacyPushNotifications];
}

@end

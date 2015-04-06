//
//  HKIOS8PushNotifications.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKIOS8PushNotifications.h"

#import <UIKit/UIUserNotificationSettings.h>

#import "HKUtils.h"
#import "HKSwizzling.h"
#import "HKPushNotifications+Private.h"

@interface HKIOS8PushNotifications ()

@property (nonatomic, strong) NSString *deviceToken;

@end

@implementation HKIOS8PushNotifications

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
  [self.application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:[self userNotificationTypesFromHKRemoteNotificationTypes:types] categories:nil]];
  [self.application registerForRemoteNotifications];
}


#pragma mark - Accessors
- (BOOL)isRegistered
{
  return [[self application] isRegisteredForRemoteNotifications];
}

- (BOOL)badgeAvailable
{
  return [self notificationTypeAvailable:UIUserNotificationTypeBadge];
}

- (BOOL)soundAvailable
{
  return [self notificationTypeAvailable:UIUserNotificationTypeSound];
}

- (BOOL)alertAvailable
{
  return [self notificationTypeAvailable:UIUserNotificationTypeAlert];
}

#pragma mark - Helpers
- (BOOL)notificationTypeAvailable:(UIUserNotificationType)type
{
  return (self.application.currentUserNotificationSettings.types & type) == type;
}

- (UIUserNotificationType)userNotificationTypesFromHKRemoteNotificationTypes:(HKRemoteNotificationType)types
{
  UIUserNotificationType userNotificationTypes = 0;
  if (types & HKRemoteNotificationTypeSound) {
    userNotificationTypes = userNotificationTypes | UIUserNotificationTypeSound;
  }
  
  if (types & HKRemoteNotificationTypeBadge) {
    userNotificationTypes = userNotificationTypes | UIUserNotificationTypeBadge;
  }
  
  if (types & HKRemoteNotificationTypeAlert) {
    userNotificationTypes = userNotificationTypes | UIUserNotificationTypeAlert;
  }
  
  return userNotificationTypes;
}

#pragma mark - Swizzling
+ (void)load
{
  if (HKSystemVersionGreaterThanOrEqualTo(@"8.0"))
    [HKSwizzling swizzleIOS8PushNotifications];
}

@end

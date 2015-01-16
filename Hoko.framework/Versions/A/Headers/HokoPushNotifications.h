//
//  HokoPushNotifications.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2014 Hoko, S.A. All rights reserved.
//

/**
 *  HKRemoteNotificationType is an abstraction of both UIUserNotificationType (iOS >= 8.0)
 *  and UIRemoteNotificationType (iOS < 8.0). These options are to be used on a
 *  registerForRemoteNotificationTypes: call on the HokoPushNotifications module.
 */
typedef NS_OPTIONS(NSInteger, HKRemoteNotificationType) {
  /**
   *  To be used in case the user does not want any type of push notification alerts.
   */
  HKRemoteNotificationTypeNone = 0,
  /**
   *  To be used to display a badge on the application's icon when a push notification
   *  is received.
   */
  HKRemoteNotificationTypeBadge = 1 << 0,
  /**
   *  To be used in case the application should play a sound when a push notification
   *  is received.
   */
  HKRemoteNotificationTypeSound = 1 << 1,
  /**
   *  To be used in case the application should show an alert or banner when a push
   *  notification is received.
   */
  HKRemoteNotificationTypeAlert = 1 << 2,
};

/**
 *  The HokoPushNotifications module provides all the necessary APIs to manage push notifications generated
 *  by the Hoko service. It provides also an abstraction between iOS<8.0 and iOS>=8.0 notification APIs for
 *  easier integration.
 */
@interface HokoPushNotifications : NSObject

/**
 *  In order for the application to receive notifications we first need to register for them.
 *  This function may be called in replacement of native iOS ones as it will abstract you from
 *  which iOS version is running and the different logic behind each version. The HKRemoteNotificationType
 *  mimics the original options in both iOS < and >= 8.0.
 *
 *  <pre>
 *  [[Hoko pushNotifications] registerForRemoteNotificationTypes:HKRemoteNotificationTypeBadge|HKRemoteNotificationTypeSound|HKRemoteNotificationTypeAlert];
 *  </pre>
 *
 *  @param types The types chosen from HKRemoteNotificationType separated by '|'.
 */
- (void)registerForRemoteNotificationTypes:(HKRemoteNotificationType)types;

/**
 *  applicationDidRegisterForRemoteNotificationsWithDeviceToken: is a mimicked method from the 
 *  UIApplicationDelegate protocol. It serves the purpose of receiving the device token after it was
 *  accepted by the application's user. On a common basis this method will be automatically delegated
 *  to the Hoko Push Notifications module through swizzling, but in case you get an error message at 
 *  the start of your application you should manually delegete this method from your AppDelegate to the
 *  Push Notifications module.
 *
 *  @param token The device token encoded as an NSData object.
 */
- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token;

/**
 *  applicationDidReceiveRemoteNotification: is a mimicked method from the UIApplicationDelegate
 *  protocol. It serves the purpose of receiving the remote notification after it was sent from
 *  Apple's Push Notification Service. On a common basis this method will be automatically delegated
 *  to the Hoko Push Notifications module through swizzling, but in case you get an error message
 *  at the start of your application you should manually delegate this method from your AppDelegate
 *  to the Push Notifications module.
 *
 *  @param userInfo The NSDictionary containing the push notification received.
 *
 *  @return Returns YES if the notification was handled by Hoko and NO otherwise.
 */
- (BOOL)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo;


@end

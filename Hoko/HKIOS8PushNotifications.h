//
//  HKIOS8PushNotifications.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKPushNotifications.h"

@interface HKIOS8PushNotifications : HKPushNotifications

- (instancetype)initWithToken:(NSString *)token;

@end

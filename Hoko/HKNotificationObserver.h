//
//  HKNotificationObserver.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HKNotificationTriggeredBlock)(NSNotification *notification);

@interface HKNotificationObserver : NSObject

- (instancetype)initWithNotification:(NSString *)name triggered:(HKNotificationTriggeredBlock)triggered;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) HKNotificationTriggeredBlock triggered;

@end
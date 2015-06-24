//
//  HOKNotificationObserver.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HOKNotificationTriggeredBlock)(NSNotification *notification);

@interface HOKNotificationObserver : NSObject

- (instancetype)initWithNotification:(NSString *)name triggered:(HOKNotificationTriggeredBlock)triggered;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) HOKNotificationTriggeredBlock triggered;

@end
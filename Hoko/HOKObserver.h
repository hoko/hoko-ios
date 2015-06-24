//
//  HOKObserver.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKObjectObserver.h"
#import "HOKNotificationObserver.h"

@interface HOKObserver : NSObject

+ (instancetype)observer;

- (HOKNotificationObserver *)registerForNotification:(NSString *)name triggered:(HOKNotificationTriggeredBlock)triggered;
- (void)observe:(id)object keyPath:(NSString *)keyPath triggered:(HOKObjectObserverTriggered)triggered;

- (void)removeObserver:(id)observer;

@end

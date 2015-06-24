//
//  HOKObjectObserver.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^HOKObjectObserverTriggered)(id object, id oldValue, id newValue);

@interface HOKObjectObserver : NSObject

- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath triggered:(HOKObjectObserverTriggered)triggered;

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, copy) HOKObjectObserverTriggered triggered;

@end
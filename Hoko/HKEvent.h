//
//  HKEvent.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKEvent : NSObject

- (instancetype)initWithName:(NSString *)name amount:(NSNumber *)amount;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSNumber *amount;
@property (nonatomic, strong, readonly) NSDate *createdAt;

@property (nonatomic, strong, readonly) id json;

@end

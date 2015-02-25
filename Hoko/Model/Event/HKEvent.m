//
//  HKEvent.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKEvent.h"

#import "HKUtils.h"

@implementation HKEvent

#pragma mark - Initializer
- (instancetype)initWithName:(NSString *)name amount:(NSNumber *)amount
{
  self = [super init];
  if (self) {
    _name = name;
    _amount = amount;
    _createdAt = [NSDate date];
  }
  return self;
}

#pragma mark - Serializer
- (id)json
{
  return @{@"name": [HKUtils jsonValue:self.name],
           @"amount": [HKUtils jsonValue:self.amount],
           @"created_at": [HKUtils jsonValue:[HKUtils stringFromDate:self.createdAt]]};
}

#pragma mark - Description
- (NSString *)description
{
  return [NSString stringWithFormat:@"<HKEvent> name='%@' amount='%@' createdAt='%@'",self.name, self.amount, [HKUtils stringFromDate:self.createdAt]];
}

@end

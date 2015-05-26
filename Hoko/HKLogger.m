//
//  HKLogger.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKLogger.h"

#import "HKApp.h"

@interface HKLogger ()

@end

@implementation HKLogger

#pragma mark - Public Static Instance
+ (instancetype)logger {
  static HKLogger *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [HKLogger new];
  });
  
  return _sharedInstance;
}

#pragma mark - Logging
- (void)log:(NSString *)string
{
  if(self.verbose)
    NSLog(@"[HOKO] %@",string);
}

- (void)logError:(NSError *)error
{
  [self log:error.description];
}


@end

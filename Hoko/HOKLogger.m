//
//  HOKLogger.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKLogger.h"

#import "HOKApp.h"

@interface HOKLogger ()

@end

@implementation HOKLogger

#pragma mark - Public Static Instance
+ (instancetype)logger {
  static HOKLogger *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [HOKLogger new];
  });
  
  return _sharedInstance;
}

#pragma mark - Logging
- (void)log:(NSString *)string {
  if (self.verbose) {
    NSLog(@"[HOKO] %@",string);
  }
}

- (void)logError:(NSError *)error {
  NSLog(@"[HOKO] %@",error.description);
}


@end

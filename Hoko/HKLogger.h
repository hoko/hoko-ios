//
//  HKLogger.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKLogger : NSObject

+ (instancetype)logger;

- (void)log:(NSString *)string;
- (void)logError:(NSError *)error;

@property (nonatomic, assign) BOOL verbose;

@end

#ifndef HKErrorLog
  #define HKErrorLog(error) [[HKLogger logger] logError:error]
#endif

#ifndef HKLog
  #define HKLog(...) [[HKLogger logger] log:[NSString stringWithFormat:__VA_ARGS__]]
#endif

//
//  HOKLogger.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOKLogger : NSObject

+ (instancetype)logger;

- (void)log:(NSString *)string;
- (void)logError:(NSError *)error;

@property (nonatomic, assign) BOOL verbose;

@end

#ifndef HOKErrorLog
  #define HOKErrorLog(error) [[HOKLogger logger] logError:error]
#endif

#ifndef HOKLog
  #define HOKLog(...) [[HOKLogger logger] log:[NSString stringWithFormat:__VA_ARGS__]]
#endif

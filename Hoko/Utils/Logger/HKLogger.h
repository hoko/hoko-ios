//
//  HKLogger.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

@interface HKLogger : NSObject

+ (instancetype)logger;

- (void)log:(NSString *)string;
- (void)logError:(NSError *)error;

@property (nonatomic, assign) BOOL verbose;

@end

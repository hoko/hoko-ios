//
//  HOKUtils.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOKUtils : NSObject

+ (void)saveObject:(id)object key:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (void)saveObject:(id)object toFile:(NSString *)filename;
+ (id)objectFromFile:(NSString *)filename;

+ (id)jsonValue:(id)object;

+ (NSString *)generateUUID;

+ (NSString *)md5FromString:(NSString *)string;

+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringFromDate:(NSDate *)date dateOnly:(BOOL)dateOnly;

@end

#ifndef HOKSystemVersionGreaterThanOrEqualTo
  #define HOKSystemVersionGreaterThanOrEqualTo(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#endif

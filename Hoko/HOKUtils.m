//
//  HOKUtils.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKUtils.h"

#import <UIKit/UIDevice.h>
#import <CommonCrypto/CommonDigest.h>

NSString *const HOKDomain = @"Hoko";

NSString *const HOKDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
NSString *const HOKDateFormatLegacy = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
NSString *const HOKDateFormatDateOnly = @"yyyy-MM-dd";

@implementation HOKUtils

#pragma mark - NSUserDefaults
+ (void)saveObject:(id)object key:(NSString *)key {
  NSString *hokoKey = [NSString stringWithFormat:@"%@.%@", HOKDomain, key];
  NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
  
  [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:hokoKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)objectForKey:(NSString *)key {
  NSString *hokoKey = [NSString stringWithFormat:@"%@.%@", HOKDomain, key];
  NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:hokoKey];
  
  if (encodedObject) {
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
  } else {
    return nil;
  }
}

#pragma mark - File Management
+ (void)saveObject:(id)object toFile:(NSString *)filename {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *path = [self pathWithFilename:filename];
    if (path) {
      if (object) {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
        [encodedObject writeToFile:path atomically:YES];
        
      } else {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
      }
    }
  });
}

+ (id)objectFromFile:(NSString *)filename {
  NSString *path = [self pathWithFilename:filename];
  if (path) {
    NSData *encodedObject = [NSData dataWithContentsOfFile:path];
    if (encodedObject) {
      @try {
        return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
      }
      @catch (NSException *exception) {
        [self saveObject:nil toFile:filename];
      }
    }
  }
  
  return nil;
}

+ (NSString *)pathWithFilename:(NSString *)filename {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  
  if ([paths count] > 0) {
    NSString *directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:HOKDomain];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
      [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return [directory stringByAppendingPathComponent:filename];
  }
  
  return nil;
}

#pragma mark - Serialization Safety
+ (id)jsonValue:(id)object {
  return object ? object : [NSNull null];
}

#pragma mark - MD5 Generation
+ (NSString *)md5FromString:(NSString *)string {
  const char *cstr = [string UTF8String];
  unsigned char result[16];
  CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
  
  return [NSString stringWithFormat:
          @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
          result[0], result[1], result[2], result[3],
          result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11],
          result[12], result[13], result[14], result[15]];
}

#pragma mark - UUID Generation
+ (NSString *)generateUUID {
  NSString *uuid;
  if (HOKSystemVersionGreaterThanOrEqualTo(@"6.0")) {
    uuid = [[NSUUID UUID] UUIDString];
  } else {
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfuuid = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    uuid = [((__bridge NSString *) cfuuid) copy];
    CFRelease(cfuuid);
  }
  
  return uuid;
}

#pragma mark - Dates
+ (NSDateFormatter *)iso8601DateFormatterWithFormat:(NSString *)format {
  NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateFormatter *formatter = [NSDateFormatter new];
  [formatter setDateFormat:format];
  [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
  [formatter setCalendar:gregorianCalendar];
  [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
  
  return formatter;
}

+ (NSString *)stringFromDate:(NSDate *)date {
  return [self stringFromDate:date dateOnly:NO];
}

+ (NSString *)stringFromDate:(NSDate *)date dateOnly:(BOOL)dateOnly {
  if (dateOnly) {
    NSDateFormatter *formatter = [self iso8601DateFormatterWithFormat:HOKDateFormatDateOnly];
    return [formatter stringFromDate:date];
    
  } else {
    if (HOKSystemVersionGreaterThanOrEqualTo(@"6.0")) {
      NSDateFormatter *formatter = [self iso8601DateFormatterWithFormat:HOKDateFormat];
      return [formatter stringFromDate:date];
      
    } else {
      NSDateFormatter *formatter = [self iso8601DateFormatterWithFormat:HOKDateFormatLegacy];
      NSString *string = [formatter stringFromDate:date];
      NSMutableString *adaptedString = [NSMutableString stringWithString:string];
      
      if ([adaptedString rangeOfString:@"+"].location != NSNotFound) {
        [adaptedString insertString:@":" atIndex:(adaptedString.length - 2)];
      }
      
      return adaptedString;
    }
  }
}


@end

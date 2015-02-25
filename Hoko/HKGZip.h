//
//  HKGZip.h
//  Hoko
//
//  Created by Ivan Bruel on 01/12/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKGZip : NSObject

+ (NSData *)gzippedData:(NSData *)data;
+ (NSData *)gunzippedData:(NSData *)data;

@end

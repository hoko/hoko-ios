//
//  HOKGZip.h
//  Hoko
//
//  Created by Hoko, S.A. on 01/12/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOKGZip : NSObject

+ (NSData *)gzippedData:(NSData *)data;
+ (NSData *)gunzippedData:(NSData *)data;

@end

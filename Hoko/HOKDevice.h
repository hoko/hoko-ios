//
//  HOKDevice.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOKDevice : NSObject

+ (instancetype)device;

- (void)setupReachability;

@property (nonatomic, strong, readonly) NSString *vendor;
@property (nonatomic, strong, readonly) NSString *platform;
@property (nonatomic, strong, readonly) NSString *model;
@property (nonatomic, strong, readonly) NSString *systemVersion;
@property (nonatomic, strong, readonly) NSString *systemLanguage;
@property (nonatomic, strong, readonly) NSString *screenSize;
@property (nonatomic, strong, readonly) NSString *uid;
@property (nonatomic, readonly) BOOL hasInternetConnection;
@property (nonatomic, readonly) BOOL isSimulator;
@property (nonatomic, strong, readonly) NSDictionary *json;

@end

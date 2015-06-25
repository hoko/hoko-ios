//
//  HOKApp.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOKApp : NSObject

+ (instancetype)app;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *bundle;
@property (nonatomic, strong, readonly) NSString *version;
@property (nonatomic, strong, readonly) NSString *build;
@property (nonatomic, strong, readonly) NSArray *urlSchemes;
@property (nonatomic, readonly) BOOL hasURLSchemes;
@property (nonatomic, readonly) BOOL isDebugBuild;
@property (nonatomic, strong, readonly) NSString *environment;
@property (nonatomic, strong, readonly) NSDictionary *json;
@property (nonatomic, strong, readonly) NSString *teamId;


@end

//
//  HKDeeplinking+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

@class HKHandling;
@class HKRouting;

@interface HKDeeplinking (Private)

- (instancetype)initWithToken:(NSString *)token debugMode:(BOOL)debugMode;

- (BOOL)handleOpenURLFromForeground:(NSURL *)url;
- (BOOL)canOpenURL:(NSURL *)url;

@property (nonatomic, strong) HKRouting *routing;
@property (nonatomic, strong) HKHandling *handling;

@end
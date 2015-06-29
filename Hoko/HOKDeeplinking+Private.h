//
//  HOKDeeplinking+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

@class HOKHandling;
@class HOKRouting;

@interface HOKDeeplinking (Private)

- (instancetype)initWithToken:(NSString *)token debugMode:(BOOL)debugMode;

- (BOOL)canOpenURL:(NSURL *)url;

@property (nonatomic, strong) HOKRouting *routing;
@property (nonatomic, strong) HOKHandling *handling;

@end
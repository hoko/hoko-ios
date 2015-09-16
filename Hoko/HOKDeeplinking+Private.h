//
//  HOKDeeplinking+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

@class HOKHandling;
@class HOKRouting;
@class HOKFiltering;

@interface HOKDeeplinking (Private)

- (instancetype)initWithToken:(NSString *)token customDomain:(NSString *)customDomain debugMode:(BOOL)debugMode;

- (BOOL)handleOpenDeferredURL:(NSURL *)url;

- (BOOL)canOpenURL:(NSURL *)url;

- (void)setCurrentDeeplink:(HOKDeeplink *)currentDeeplink;

@property (nonatomic, strong) HOKRouting *routing;
@property (nonatomic, strong) HOKHandling *handling;
@property (nonatomic, strong) HOKFiltering *filtering;

@end
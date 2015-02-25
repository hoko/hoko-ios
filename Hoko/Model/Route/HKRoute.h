//
//  HKRoute.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "Hoko.h"

@interface HKRoute : NSObject

+ (instancetype)routeWithRoute:(NSString *)route target:(HKDeeplinkTarget)target;

- (void)postWithToken:(NSString *)token;

@property (nonatomic, strong, readonly) NSString *route;
@property (nonatomic, strong, readonly) NSArray *components;
@property (nonatomic, copy, readonly) HKDeeplinkTarget target;

@property (nonatomic, strong, readonly) id json;

@end

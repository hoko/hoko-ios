//
//  HOKResolver.h
//  Hoko
//
//  Created by Hoko, S.A. on 18/05/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOKResolver : NSObject

- (instancetype)initWithToken:(NSString *)token;

- (void)resolveSmartlink:(NSString *)smartlink completion:(void (^)(NSString *deeplink, NSDictionary *metadata, NSError *error))completion;

@end

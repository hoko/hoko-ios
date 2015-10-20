//
//  HOKNetworking.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.

#import <Foundation/Foundation.h>

@interface HOKIframe : NSObject

+ (void)requestPageWithURL:(NSString *)url completion:(void(^)(void))completion;

@end

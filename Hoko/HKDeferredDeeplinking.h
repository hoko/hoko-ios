//
//  HKDeferredDeeplinking.h
//  
//
//  Created by Ivan Bruel on 23/03/15.
//
//

#import <Foundation/Foundation.h>

@interface HKDeferredDeeplinking : NSObject

- (instancetype)initWithToken:(NSString *)token;

- (void)requestDeferredDeeplink:(void(^)(NSString *deeplink))handler;

@end

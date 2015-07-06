//
//  HOKResolver.h
//  
//
//  Created by Ivan Bruel on 18/05/15.
//
//

#import <Foundation/Foundation.h>

@interface HOKResolver : NSObject

- (instancetype)initWithToken:(NSString *)token;

- (void)resolveSmartlink:(NSString *)smartlink completion:(void(^)(NSString *deeplink, NSDictionary *metadata, NSError *error))completion;

@end

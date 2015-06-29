//
//  HOKResolver.m
//  
//
//  Created by Ivan Bruel on 18/05/15.
//
//

#import "HOKResolver.h"

#import "HOKLogger.h"
#import "HOKNetworking.h"
#import "HOKNetworkOperation.h"
#import "HOKDevice.h"

NSString *const HOKResolverEndpoint = @"smartlinks/resolve";

@interface HOKResolver ()

@property (nonatomic, strong) NSString *token;

@end

@implementation HOKResolver

- (instancetype)initWithToken:(NSString *)token
{
    if (self = [super init]) {
        _token = token;
    }
    return self;
}

- (void)resolveSmartlink:(NSString *)smartlink completion:(void(^)(NSURL *deeplink, NSError *error))completion
{
    [HOKNetworking postToPath:[HOKNetworkOperation urlFromPath:HOKResolverEndpoint] parameters:[self jsonWithSmartlink:smartlink] token:self.token successBlock:^(id json) {
        NSString *deeplink = [json objectForKey:@"deeplink"];
        if (completion)
            completion([NSURL URLWithString:deeplink], nil);
    } failedBlock:^(NSError *error) {
        HOKErrorLog(error);
        if (completion)
            completion(nil, error);

    }];
}

- (id)jsonWithSmartlink:(NSString *)smartlink
{
    NSString *smartlinkString = smartlink;
    if ([smartlink isKindOfClass:[NSURL class]])
        smartlinkString = [(NSURL *)smartlink absoluteString];
    return @{@"smartlink": smartlinkString,
             @"universal": [HOKDevice device].uid};
}


@end

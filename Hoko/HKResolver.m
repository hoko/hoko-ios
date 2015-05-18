//
//  HKResolver.m
//  
//
//  Created by Ivan Bruel on 18/05/15.
//
//

#import "HKResolver.h"

#import "HKLogger.h"
#import "HKNetworking.h"
#import "HKNetworkOperation.h"

NSString *const HKResolverEndpoint = @"smartlinks/resolve";

@interface HKResolver ()

@property (nonatomic, strong) NSString *token;

@end

@implementation HKResolver

- (instancetype)initWithToken:(NSString *)token
{
    if (self = [super init]) {
        _token = token;
    }
    return self;
}

- (void)resolveSmartlink:(NSString *)smartlink completion:(void(^)(NSURL *deeplink, NSError *error))completion
{
    [HKNetworking postToPath:[HKNetworkOperation urlFromPath:HKResolverEndpoint] parameters:[self jsonWithSmartlink:smartlink] token:self.token successBlock:^(id json) {
        NSString *deeplink = [json objectForKey:@"deeplink"];
        if (completion)
            completion([NSURL URLWithString:deeplink], nil);
    } failedBlock:^(NSError *error) {
        HKErrorLog(error);
        if (completion)
            completion(nil, error);

    }];
}

- (id)jsonWithSmartlink:(NSString *)smartlink
{
    NSString *smartlinkString = smartlink;
    if ([smartlink isKindOfClass:[NSURL class]])
        smartlinkString = [(NSURL *)smartlink absoluteString];
    return @{@"smartlink": smartlinkString};
}

@end

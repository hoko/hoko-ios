//
//  HKURL.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKRoute.h"

@interface HKURL : NSObject

- (instancetype)initWithURL:(NSURL *)url;

- (BOOL)matchesWithRoute:(HKRoute *)route routeParameters:(NSDictionary **)routeParameters;

+ (NSString *)sanitizeURLString:(NSString *)urlString;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSString *scheme;
@property (nonatomic, strong, readonly) NSDictionary *queryParameters;


@end

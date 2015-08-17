//
//  HOKFiltering.m
//  Hoko
//
//  Created by Hoko, S.A. on 04/08/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKFiltering.h"
#import "HOKFilterBlockWrapper.h"

@interface HOKFiltering ()

@property (nonatomic, strong) NSMutableArray *filters;

@end

@implementation HOKFiltering

#pragma mark - Initializer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _filters = [@[] mutableCopy];
    }
    return self;
}

#pragma mark - Add Handlers
- (void)addFilterBlock:(BOOL (^)(HOKDeeplink *deeplink))filterBlock {
    [self.filters addObject:[[HOKFilterBlockWrapper alloc] initWithFilterBlock:filterBlock]];
}

- (BOOL)filter:(HOKDeeplink *)deeplink {
    for (id filter in self.filters) {
        if ([filter isKindOfClass:[HOKFilterBlockWrapper class]]) {
            HOKFilterBlockWrapper *filterBlockWrapper = (HOKFilterBlockWrapper *)filter;
            if (filterBlockWrapper.filterBlock) {
                if (!filterBlockWrapper.filterBlock(deeplink))
                    return NO;
            }
        }
    }
    
    return YES;
}

@end

//
//  HOKFiltering.h
//  Hoko
//
//  Created by Hoko, S.A. on 04/08/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "Hoko.h"

@interface HOKFiltering : NSObject

- (void)addFilterBlock:(BOOL (^)(HOKDeeplink *deeplink))filterBlock;

- (BOOL)filter:(HOKDeeplink *)deeplink;

@end

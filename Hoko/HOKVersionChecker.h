//
//  HOKVersionChecker.h
//  Hoko
//
//  Created by Hoko, S.A. on 22/01/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOKVersionChecker : NSObject

+ (instancetype)versionChecker;

- (void)checkForNewVersion:(NSString *)currentVersion token:(NSString *)token;

@end

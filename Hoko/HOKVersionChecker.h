//
//  HOKVersionChecker.h
//  Hoko
//
//  Created by Ivan Bruel on 22/01/15.
//  Copyright (c) 2015 Faber Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOKVersionChecker : NSObject

+ (instancetype)versionChecker;

- (void)checkForNewVersion:(NSString *)currentVersion;

@end

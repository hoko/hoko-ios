//
//  HKUser.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKAnalytics.h"

@interface HKUser : NSObject <NSCoding>

+ (instancetype)currentUser;

- (instancetype)init;
- (instancetype)initWithIdentifier:(NSString *)identifier
                       accountType:(HKUserAccountType)accountType
                              name:(NSString *)name
                             email:(NSString *)email
                         birthDate:(NSDate *)birthDate
                            gender:(HKUserGender)gender
                previousIdentifier:(NSString *)previousIdentifier;

- (void)postWithToken:(NSString *)token;

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, readonly) BOOL anonymous;
@property (nonatomic, assign) HKUserAccountType accountType;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSDate *birthDate;
@property (nonatomic, readonly) HKUserGender gender;
@property (nonatomic, strong, readonly) NSString *previousIdentifier;
@property (nonatomic, strong, readonly) NSString *timezoneOffset;

@property (nonatomic, strong, readonly) NSDictionary *json;
@property (nonatomic, strong, readonly) NSDictionary *baseJSON;

@end

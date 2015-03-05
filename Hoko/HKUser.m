//
//  HKUser.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKUser.h"

#import "HKApp.h"
#import "HKUtils.h"
#import "HKDevice.h"
#import "HKNetworkOperationQueue.h"

NSString *const HKUserCurrentUserKey = @"currentUser";
NSString *const HKUserPath = @"users";

@implementation HKUser

#pragma mark - Static Method
+ (instancetype)currentUser
{
  return [HKUtils objectForKey:HKUserCurrentUserKey];
}

#pragma mark - Initializers
- (instancetype)init
{
  return [self initWithIdentifier:nil
                      accountType:HKUserAccountTypeNone
                             name:nil
                            email:nil
                        birthDate:nil
                           gender:HKUserGenderUnknown
               previousIdentifier:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                       accountType:(HKUserAccountType)accountType
                              name:(NSString *)name
                             email:(NSString *)email
                         birthDate:(NSDate *)birthDate
                            gender:(HKUserGender)gender
                previousIdentifier:(NSString *)previousIdentifier
{
  self = [super init];
  if (self) {
    if (identifier) {
      _identifier = identifier;
      _anonymous = NO;
      _accountType = accountType;
      _name = name;
      _email = email;
      _birthDate = birthDate;
      _gender = gender;
      _previousIdentifier = previousIdentifier;
    } else {
      _identifier = [HKUtils generateUUID];
      _anonymous = YES;
    }
    _timezoneOffset = [HKUser currentTimezoneOffset];
    [self saveUser];
  }
  return self;
}

#pragma mark - Timezone
+ (NSString *)currentTimezoneOffset
{
  return [NSString stringWithFormat:@"%@",@([[NSTimeZone localTimeZone] secondsFromGMT] / ( 60.0f * 60.0f))];
}

#pragma mark - Serialization
- (NSDictionary *)json
{
  return @{@"user": self.baseJSON};
}

- (NSDictionary *)baseJSON
{
  return @{@"identifier": [HKUtils jsonValue:self.identifier],
           @"timezone_offset": [HKUtils jsonValue:self.timezoneOffset],
           @"timestamp": [HKUtils jsonValue:[HKUtils stringFromDate:[NSDate date]]],
           @"anonymous": @(self.anonymous),
           @"account_type": @(self.accountType),
           @"name": [HKUtils jsonValue:self.name],
           @"email": [HKUtils jsonValue:self.email],
           @"birth_date": [HKUtils jsonValue:[HKUtils stringFromDate:self.birthDate dateOnly:YES]],
           @"gender": @(self.gender),
           @"device": [HKDevice device].json,
           @"previous_identifier": [HKUtils jsonValue:self.previousIdentifier]};
}

#pragma mark - Saving
- (void)saveUser
{
  [HKUtils saveObject:self key:HKUserCurrentUserKey];
}

#pragma mark - Networking
- (void)postWithToken:(NSString *)token
{
  HKNetworkOperation *networkOperation = [[HKNetworkOperation alloc] initWithOperationType:HKNetworkOperationTypePOST
                                                                                      path:HKUserPath
                                                                                     token:token
                                                                                parameters:self.json];
  [[HKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
  [aCoder encodeObject:self.timezoneOffset forKey:NSStringFromSelector(@selector(timezoneOffset))];
  [aCoder encodeBool:self.anonymous forKey:NSStringFromSelector(@selector(anonymous))];
  [aCoder encodeInteger:self.accountType forKey:NSStringFromSelector(@selector(accountType))];
  [aCoder encodeObject:self.name forKey:NSStringFromSelector(@selector(name))];
  [aCoder encodeObject:self.email forKey:NSStringFromSelector(@selector(email))];
  [aCoder encodeObject:self.birthDate forKey:NSStringFromSelector(@selector(birthDate))];
  [aCoder encodeInteger:self.gender forKey:NSStringFromSelector(@selector(gender))];
  [aCoder encodeObject:self.previousIdentifier forKey:NSStringFromSelector(@selector(previousIdentifier))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    _identifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(identifier))];
    _timezoneOffset = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(timezoneOffset))];
    _anonymous = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(anonymous))];
    _accountType = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(accountType))];
    _name = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(name))];
    _email = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(email))];
    _birthDate = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(birthDate))];
    _gender = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(gender))];
    _previousIdentifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(previousIdentifier))];
  }
  return self;
}

@end

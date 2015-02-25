//
//  HKAnalytics.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HKDeeplinking.h"

/**
 *  HKUserAccountType defines a set of different account types the Hoko Service is expecting.
 */
typedef NS_ENUM(NSInteger, HKUserAccountType) {
  /**
   *  If the user is not identified HKUserAccountTypeNone will be used.
   */
  HKUserAccountTypeNone = 0,
  /**
   *  Use this in case the enum does not include the external account type you are looking for.
   */
  HKUserAccountTypeOther = 1,
  /**
   *  Use this if it's a direct login to your own backend (usually with email/username + password combo).
   */
  HKUserAccountTypeDefault = 2,
  /**
   *  Account type when logged in through the Facebook API.
   */
  HKUserAccountTypeFacebook = 3,
  /**
   *  Account type when logged in through the Twitter API.
   */
  HKUserAccountTypeTwitter = 4,
  /**
   *  Account type when logged in through the LinkedIn API.
   */
  HKUserAccountTypeLinkedIn = 5,
  /**
   *  Account type when logged in through the Google API.
   */
  HKUserAccountTypeGoogle = 6,
  /**
   *  Account type when logged in through the Github API.
   */
  HKUserAccountTypeGithub = 7,
  /**
   *  Account type when logged in through the Windows Live API.
   */
  HKUserAccountTypeWindows = 8
};

/**
 *  HKUserGender defines the set of predefined user genders which the Hoko Service is expecting.
 */
typedef NS_ENUM(NSInteger, HKUserGender) {
  /**
   *  In case the user is not identified or the gender is actually unknown.
   */
  HKUserGenderUnknown = 0,
  /**
   *  If the user is male.
   */
  HKUserGenderMale = 1,
  /**
   *  If the user is female.
   */
  HKUserGenderFemale = 2,
};

/**
 *  The HKAnalytics module provides all the necessary APIs to manage user and application behavior.
 *  Users should be identified to this module, as well as key events (e.g. sales, referrals, etc) in order
 *  to track campaign value and allow user segmentation.
 */
@interface HKAnalytics : NSObject <HKHandlerProcotol>

/**
 *  identifyUser should be called if you have no information about the user. (e.g. your app has no
 *  login whatsoever) or if the app's user has logged out of his account.
 *
 *  <pre>
 *  [[Hoko analytics] identifyUser];
 *  </pre>
 *
 */
- (void)identifyUser;

/**
 *  identifyUserWithIdentifier:accountType: should be called when you can identify the user with a 
 *  unique identifier and a given account type. 
 *
 *  <pre> 
 *  [[Hoko analytics] identifyUserWithIdentifier:@"john.doe@email.com" accountType:HKUserAccountTypeDefault];
 *  </pre>
 *
 *  @param identifier   A unique identifier for the user in the scope of your application.
 *  @param accountType  The account type in which the user fits.
 */
- (void)identifyUserWithIdentifier:(NSString *)identifier
                       accountType:(HKUserAccountType)accountType;

/**
 *  identifyUserWithIdentifier:accountType:name:email:birthDate:gender should be called when you
 *  can identify the user with a unique identifier, a given account type, and a few attributes which
 *  help to segment users in the Hoko service.
 *
 *  <pre>
 *  [[Hoko analytics] identifyUserWithIdentifier:@"john.doe" accountType:HKUserAccountTypeGithub name:@"John Doe" email:@"john.doe@email.com" birthDate:[NSDate date] gender:HKUserGenderMale];
 *  </pre>
 *
 *  @param identifier   A unique identifier for the user in the scope of your application.
 *  @param accountType  The account type in which the user fits.
 *  @param name         The user's name.
 *  @param email        The user's email address.
 *  @param birthDate    The user's date of birth.
 *  @param gender       The user's gender (Male/Female/Unknown).
 */
- (void)identifyUserWithIdentifier:(NSString *)identifier
                       accountType:(HKUserAccountType)accountType
                              name:(NSString *)name
                             email:(NSString *)email
                         birthDate:(NSDate *)birthDate
                            gender:(HKUserGender)gender;

/**
 *  trackKeyEvent: unlike common analytics events should be used only on conversion or key metrics
 *  (e.g. in-app purchase, retail sales, referrals, etc). This will lead to better conversion and
 *  engagement tracking of your users through Deeplinking campaigns.
 *
 *  <pre>
 *  [[Hoko analytics] trackKeyEvent:@"purchasedPremium"];
 *  </pre>
 *
 *  @param eventName  A name to identify uniquely the key event that occurred.
 */
- (void)trackKeyEvent:(NSString *)eventName;

/**
 *  trackKeyEvent: unlike common analytics events should be used only on conversion or key metrics
 *  (e.g. in-app purchase, retail sales, referrals, etc). This will lead to better conversion and
 *  engagement tracking of your users through Deeplinking campaigns.
 *
 *  <pre>
 *  [[Hoko analytics] trackKeyEvent:@"purchasedDress" amount:@(29.99)];
 *  </pre>
 *
 *  @param eventName  A name to identify uniquely the key event that occurred.
 *  @param amount     A number that represents a possible sale (e.g. in-app, retail, etc) in currency value.
 */
- (void)trackKeyEvent:(NSString *)eventName amount:(NSNumber *)amount;

@end

#ifndef HKAnalytics
  #define HokoAnalytics [Hoko analytics]
#endif

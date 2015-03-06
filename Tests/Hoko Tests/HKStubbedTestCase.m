//
//  HKStubbedTest.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 05/03/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

#import <Hoko/Hoko+Private.h>
#import <Hoko/HKApp.h>

@interface HKStubbedTestCase : XCTestCase

@end

@implementation HKStubbedTestCase

- (void)setUp
{
  [super setUp];
  id appMock = OCMPartialMock([HKApp app]);
  [[[appMock stub] andReturn:@[@"hoko"]] urlSchemes];
  [Hoko setVerbose:NO];
  [Hoko setupWithToken:@"1234"];
  
}

- (void)tearDown
{
  [super tearDown];
  [OHHTTPStubs removeAllStubs];
  [Hoko reset];
}

@end

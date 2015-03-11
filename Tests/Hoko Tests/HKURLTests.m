//
//  HKURLTests.m
//  Hoko
//
//  Created by Ivan Bruel on 25/02/15.
//  Copyright (c) 2015 Faber Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "HKStubbedTestCase.h"

#import <Hoko/HKURL.h>

@interface HKURLTests : HKStubbedTestCase

@end

@implementation HKURLTests

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testSanitize
{
  NSString *sanitizedURLString = [HKURL sanitizeURLString:@"hoko://///hoko/needs/testing////is/sanitization/ok///"];
  expect(sanitizedURLString).to.equal(@"hoko://hoko/needs/testing/is/sanitization/ok");
}

- (void)testNoNeedForSanitization
{
  NSString *sanitizedURLString = [HKURL sanitizeURLString:@"hoko://hoko/needs/testing/is/sanitization/ok"];
  expect(sanitizedURLString).to.equal(@"hoko://hoko/needs/testing/is/sanitization/ok");
}

- (void)testURL
{
  HKURL *url = [[HKURL alloc] initWithURL:[NSURL URLWithString:@"hoko://param/1/other_param/2?test=1&q_param=2&string=hi+there"]];
  expect(url.url).to.equal([NSURL URLWithString:@"hoko://param/1/other_param/2"]);
}

- (void)testQuery
{
  HKURL *url = [[HKURL alloc] initWithURL:[NSURL URLWithString:@"hoko://param/1/other_param/2?test=1&q_param=2&string=hi+there"]];
  expect(url.queryParameters).to.equal(@{@"test": @"1",
                                         @"q_param": @"2",
                                         @"string": @"hi there"});
}

- (void)testScheme
{
  HKURL *url = [[HKURL alloc] initWithURL:[NSURL URLWithString:@"hoko://param/1/other_param/2?test=1&q_param=2&string=hi+there"]];
  expect(url.scheme).to.equal(@"hoko");
}

- (void)testRouteMatched
{
  HKRoute *route = [HKRoute routeWithRoute:@"param/:param/other_param/:other_param" target:nil];
  HKURL *url = [[HKURL alloc] initWithURL:[NSURL URLWithString:@"hoko://param/1/other_param/2?test=1&q_param=2&string=hi+there"]];
  NSDictionary *routeParameters;
  BOOL matchesRoute = [url matchesWithRoute:route routeParameters:&routeParameters];
  
  expect(matchesRoute).to.beTruthy();
  expect(routeParameters).to.equal(@{@"param": @"1",
                                     @"other_param": @"2"});
}

- (void)testRouteNotMatched
{
  HKRoute *route = [HKRoute routeWithRoute:@"param/:param/other_param/:other_param/something" target:nil];
  HKURL *url = [[HKURL alloc] initWithURL:[NSURL URLWithString:@"hoko://param/1/other_param/2?test=1&q_param=2&string=hi+there"]];
  NSDictionary *routeParameters;
  BOOL matchesRoute = [url matchesWithRoute:route routeParameters:&routeParameters];
  
  expect(matchesRoute).to.beFalsy();
  expect(routeParameters).to.beNil();
}

- (void)testRouteNotMatchedExtraParameter
{
  HKRoute *route = [HKRoute routeWithRoute:@"param/:param/other_param/:other_param" target:nil];
  HKURL *url = [[HKURL alloc] initWithURL:[NSURL URLWithString:@"hoko://param/1/other_param/2/50?test=1&q_param=2&string=hi+there"]];
  NSDictionary *routeParameters;
  BOOL matchesRoute = [url matchesWithRoute:route routeParameters:&routeParameters];
  
  expect(matchesRoute).to.beFalsy();
  expect(routeParameters).to.beNil();
}

@end

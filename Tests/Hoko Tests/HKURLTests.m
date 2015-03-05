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

- (void)testURL
{
  HKURL *url = [[HKURL alloc] initWithURL:[NSURL URLWithString:@"hoko://param/1/other_param/2?test=1&q_param=2"]];
  expect(url.url).to.equal([NSURL URLWithString:@"hoko://param/1/other_param/2"]);
}


@end

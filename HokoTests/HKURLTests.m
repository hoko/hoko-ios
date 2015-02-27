//
//  HKURLTests.m
//  Hoko
//
//  Created by Ivan Bruel on 25/02/15.
//  Copyright (c) 2015 Faber Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "HKURL.h"

@interface HKURLTests : XCTestCase

@end

@implementation HKURLTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSanitize
{
  NSString *sanitizedURLString = [HKURL sanitizeURLString:@"hoko://///hoko/needs/testing////is/sanitization/ok///"];
  NSLog(@"%@",sanitizedURLString);
  XCTAssert([sanitizedURLString isEqualToString:@"hoko://hoko/needs/testing/is/sanitization/ok"], @"String should be sanitized");
}

- (void)testURL
{
  HKURL *url = [[HKURL alloc] initWithURL:[NSURL URLWithString:@"hoko://param/1/other_param/2?test=1&q_param=2"]];
  NSLog(@"%@",url.url.absoluteString);
  XCTAssert([url.url isEqual:[NSURL URLWithString:@"hoko://param/1/other_param/2"]], @"URL should not have query parameters");
}


@end

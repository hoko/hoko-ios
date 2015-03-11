//
//  HKRoutingTests.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 06/03/15.
//
//

#import "HKStubbedTestCase.h"

#import <Hoko/HKDeeplinking+Private.h>
#import <Hoko/HKRouting.h>
#import <Hoko/HKDeeplink+Private.h>

@interface HKRoutingTests : HKStubbedTestCase

@end

@implementation HKRoutingTests

- (void)setUp
{
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testRouteExists
{
  [HokoDeeplinking.routing mapRoute:@"product/:product_id" toTarget:nil];
  BOOL routeExists = [HokoDeeplinking.routing routeExists:@"product/:product_id"];
  expect(routeExists).to.beTruthy();
}

- (void)testRouteDoesNotExist
{
  [HokoDeeplinking.routing mapRoute:@"product/:product_id" toTarget:nil];
  BOOL routeExists = [HokoDeeplinking.routing routeExists:@"product/:product_id/something/else"];
  expect(routeExists).to.beFalsy();
}

- (void)testOpenURLWithMatchingRoute
{
  __block HKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking.routing mapRoute:@"product/:product_id" toTarget:^(HKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  BOOL canOpenURL = [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product/2?query=hi+there"] sourceApplication:@"com.hoko.black" annotation:nil];
  expect(canOpenURL).to.beTruthy();
  expect(blockDeeplink.urlScheme).will.equal(@"hoko");
  expect(blockDeeplink.route).will.equal(@"product/:product_id");
  expect(blockDeeplink.routeParameters).will.equal(@{@"product_id":@"2"});
  expect(blockDeeplink.queryParameters).will.equal(@{@"query": @"hi there"});
  expect(blockDeeplink.sourceApplication).will.equal(@"com.hoko.black");
}

- (void)testOpenURLWithoutMatchingRoute
{
  __block HKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking.routing mapRoute:@"product/:product_id" toTarget:^(HKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  BOOL canOpenURL = [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product?query=hi+there"] sourceApplication:nil annotation:nil];
  expect(canOpenURL).to.beFalsy();
  expect(blockDeeplink).will.beNil();
}

- (void)testOpenURLWithoutMatchingRouteByDefaulting
{
  __block HKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking.routing mapRoute:nil toTarget:^(HKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  BOOL canOpenURL = [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product?query=hi+there"] sourceApplication:@"com.hoko.black" annotation:nil];
  expect(canOpenURL).to.beTruthy();
  expect(blockDeeplink.urlScheme).will.equal(@"hoko");
  expect(blockDeeplink.route).will.beNil();
  expect(blockDeeplink.routeParameters).will.beNil();
  expect(blockDeeplink.queryParameters).will.equal(@{@"query": @"hi there"});
  expect(blockDeeplink.sourceApplication).will.equal(@"com.hoko.black");
}

@end

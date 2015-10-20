//
//  HOKRoutingTests.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 06/03/15.
//
//

#import "HOKStubbedTestCase.h"

#import <Hoko/HOKDeeplinking+Private.h>
#import <Hoko/HOKRouting.h>
#import <Hoko/HOKDeeplink+Private.h>

@interface HOKRoutingTests : HOKStubbedTestCase

@end

@implementation HOKRoutingTests

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
  __block HOKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking.routing mapRoute:@"product/:product_id" toTarget:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  BOOL canOpenURL = [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product/2?query=hi+there"] sourceApplication:@"com.hoko.black" annotation:nil deferredDeeplink:NO];
  expect(canOpenURL).to.beTruthy();
  expect(blockDeeplink.urlScheme).will.equal(@"hoko");
  expect(blockDeeplink.route).will.equal(@"product/:product_id");
  expect(blockDeeplink.routeParameters).will.equal(@{@"product_id":@"2"});
  expect(blockDeeplink.queryParameters).will.equal(@{@"query": @"hi there"});
  expect(blockDeeplink.sourceApplication).will.equal(@"com.hoko.black");
}

- (void)testOpenURLWithoutMatchingRoute
{
  __block HOKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking.routing mapRoute:@"product/:product_id" toTarget:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  BOOL canOpenURL = [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product?query=hi+there"] sourceApplication:nil annotation:nil deferredDeeplink:NO];
  expect(canOpenURL).to.beFalsy();
  expect(blockDeeplink).will.beNil();
}

- (void)testOpenURLWithoutMatchingRouteByDefaulting
{
  __block HOKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking.routing mapRoute:nil toTarget:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  BOOL canOpenURL = [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product?query=hi+there"] sourceApplication:@"com.hoko.black" annotation:nil deferredDeeplink:NO];
  expect(canOpenURL).to.beTruthy();
  expect(blockDeeplink.urlScheme).will.equal(@"hoko");
  expect(blockDeeplink.route).will.beNil();
  expect(blockDeeplink.routeParameters).will.beNil();
  expect(blockDeeplink.queryParameters).will.equal(@{@"query": @"hi there"});
  expect(blockDeeplink.sourceApplication).will.equal(@"com.hoko.black");
}

- (void)testRoutingSort
{
  [HokoDeeplinking.routing mapRoute:@"product/:product_id" toTarget:nil];
  [HokoDeeplinking.routing mapRoute:@"product/xpto/:id" toTarget:nil];
  [HokoDeeplinking.routing mapRoute:@"product/xpto/zzz" toTarget:nil];
  [HokoDeeplinking.routing mapRoute:@"product/xpto" toTarget:nil];
  [HokoDeeplinking.routing mapRoute:@"mkay" toTarget:nil];
  [HokoDeeplinking.routing mapRoute:@"anything" toTarget:nil];
  [HokoDeeplinking.routing mapRoute:@"zoidberg" toTarget:nil];
  NSArray *sortedRoutes = [HokoDeeplinking.routing routes];
  expect([sortedRoutes valueForKeyPath:@"route"]).to.equal(@[@"__banner",@"anything", @"mkay", @"zoidberg", @"product/xpto", @"product/:product_id", @"product/xpto/zzz", @"product/xpto/:id"]);
  
}

@end

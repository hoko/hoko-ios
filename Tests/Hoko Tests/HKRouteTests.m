//
//  HokoRouteTests.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 06/03/15.
//
//

#import "HKStubbedTestCase.h"

#import <Hoko/HKRoute.h>
#import <Hoko/HKApp.h>
#import <Hoko/HKDevice.h>

@interface HKRouteTests : HKStubbedTestCase

@end

@implementation HKRouteTests

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testRoute
{
  HKRoute *route = [HKRoute routeWithRoute:@"product/:product_id/price/:price/open" target:nil];
  expect(route.route).to.equal(@"product/:product_id/price/:price/open");
}

- (void)testComponents
{
  HKRoute *route = [HKRoute routeWithRoute:@"product/:product_id/price/:price/open" target:nil];
  expect(route.components).to.equal(@[@"product", @":product_id", @"price", @":price", @"open"]);
}

- (void)testTarget
{
  void (^target)(HKDeeplink *deeplink) = ^(HKDeeplink *deeplink){
    
  };
  HKRoute *route = [HKRoute routeWithRoute:@"product/:product_id/price/:price/open" target:target];
  expect(route.target).to.equal(target);
}

- (void)testJSON
{
  HKRoute *route = [HKRoute routeWithRoute:@"product/:product_id/price/:price/open" target:nil];
  expect(route.json).to.equal(@{@"route": @{@"path":@"product/:product_id/price/:price/open",
                                            @"version": @"Unknown Version",
                                            @"device": [HKDevice device].platform,
                                            @"url_schemes": @[@"hoko"],
                                            @"build": @"Unknown Build"}});
}


@end

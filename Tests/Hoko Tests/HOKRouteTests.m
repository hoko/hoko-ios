//
//  HOKRouteTests.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 06/03/15.
//
//

#import "HOKStubbedTestCase.h"

#import <Hoko/HOKRoute.h>
#import <Hoko/HOKApp.h>
#import <Hoko/HOKDevice.h>

@interface HOKRouteTests : HOKStubbedTestCase

@end

@implementation HOKRouteTests

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
  HOKRoute *route = [HOKRoute routeWithRoute:@"product/:product_id/price/:price/open" target:nil];
  expect(route.route).to.equal(@"product/:product_id/price/:price/open");
}

- (void)testComponents
{
  HOKRoute *route = [HOKRoute routeWithRoute:@"product/:product_id/price/:price/open" target:nil];
  expect(route.components).to.equal(@[@"product", @":product_id", @"price", @":price", @"open"]);
}

- (void)testTarget
{
  void (^target)(HOKDeeplink *deeplink) = ^(HOKDeeplink *deeplink){
    
  };
  HOKRoute *route = [HOKRoute routeWithRoute:@"product/:product_id/price/:price/open" target:target];
  expect(route.target).to.equal(target);
}

- (void)testJSON
{
  HOKRoute *route = [HOKRoute routeWithRoute:@"product/:product_id/price/:price/open" target:nil];
  expect(route.json).to.equal(@{@"route": @{@"path":@"product/:product_id/price/:price/open",
                                            @"version": @"Unknown Version",
                                            @"device": [HOKDevice device].platform,
                                            @"url_schemes": @[@"hoko"],
                                            @"build": @"Unknown Build"}});
}


@end

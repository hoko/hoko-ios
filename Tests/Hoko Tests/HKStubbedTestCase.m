//
//  HKStubbedTest.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 05/03/15.
//
//

#import "HKStubbedTestCase.h"

#import <Hoko/HKApp.h>
#import <Hoko/HKNetworkOperationQueue+Private.h>

@implementation HKStubbedTestCase

- (void)setUp
{
  [super setUp];
  id appMock = OCMPartialMock([HKApp app]);
  [[[appMock stub] andReturn:@[@"hoko"]] urlSchemes];
  
  id networkOperationQueueMock = OCMPartialMock([HKNetworkOperationQueue sharedQueue]);
  [[[networkOperationQueueMock stub] andDo:nil] saveNetworkOperations];
  
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

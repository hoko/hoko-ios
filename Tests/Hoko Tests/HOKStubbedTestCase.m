//
//  HOKStubbedTest.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 05/03/15.
//
//

#import "HOKStubbedTestCase.h"

#import <Hoko/HOKApp.h>
#import <Hoko/HOKNetworkOperationQueue+Private.h>

@implementation HOKStubbedTestCase

- (void)setUp
{
  [super setUp];
  id appMock = OCMPartialMock([HOKApp app]);
  [[[appMock stub] andReturn:@[@"hoko"]] urlSchemes];
  
  id networkOperationQueueMock = OCMPartialMock([HOKNetworkOperationQueue sharedQueue]);
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

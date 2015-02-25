//
//  HKNetworkOperation.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKNetworkOperation.h"

#import "HKError.h"
#import "HKNetworking.h"
#import "HKNetworkOperationQueue.h"

@interface HKNetworkOperation ()

@property (nonatomic, assign) BOOL hkFinished;
@property (nonatomic, assign) BOOL hkExecuting;

@end

@implementation HKNetworkOperation

#pragma mark - Initialization
- (instancetype)initWithOperation:(HKNetworkOperation *)operation
{
  return [self initWithOperationType:operation.operationType
                                path:operation.path
                               token:operation.token
                          parameters:operation.parameters
                     numberOfRetries:operation.numberOfRetries + 1];
}

- (instancetype)initWithOperationType:(HKNetworkOperationType)operationType
                                 path:(NSString *)path
                                token:(NSString *)token
                           parameters:(id)parameters
{
  return [self initWithOperationType:operationType
                                path:path
                               token:token
                          parameters:parameters
                     numberOfRetries:0];
}

- (instancetype)initWithOperationType:(HKNetworkOperationType)operationType
                                 path:(NSString *)path
                                token:(NSString *)token
                           parameters:(id)parameters
                      numberOfRetries:(NSInteger)numberOfRetries
{
  self = [super init];
  if (self) {
    _operationType = operationType;
    _path = path;
    _token = token;
    _parameters = parameters;
    _numberOfRetries = numberOfRetries;
  }
  return self;
}

#pragma mark - Setters
// Requires manual KVO implementation due to how NSOperations and NSOperationQueues work
- (void)setIsFinished:(BOOL)isFinished
{
  [self willChangeValueForKey:@"isFinished"];
  self.hkFinished = isFinished;
  [self didChangeValueForKey:@"isFinished"];
}

- (void)setIsExecuting:(BOOL)isExecuting
{
  [self willChangeValueForKey:@"isExecuting"];
  self.hkExecuting = isExecuting;
  [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - NSOperation
- (void)start
{
  if (self.isCancelled || self.hkFinished) {
    [self setIsFinished:YES];
    return;
  }
  id successBlock = ^(id json) {
    [self operationCompleted];
  };
  
  id failedBlock = ^(NSError *error) {
    [self operationFailedWithError:error];
  };
  
  if (self.operationType == HKNetworkOperationTypeGET) {
    [self setIsExecuting:YES];
    [HKNetworking requestToPath:[HKNetworkOperation urlFromPath:self.path]
                     parameters:self.parameters
                          token:self.token
                   successBlock:successBlock
                    failedBlock:failedBlock];
    
  } else if (self.operationType == HKNetworkOperationTypePOST) {
    [self setIsExecuting:YES];
    [HKNetworking postToPath:[HKNetworkOperation urlFromPath:self.path]
                  parameters:self.parameters
                       token:self.token
                successBlock:successBlock
                 failedBlock:failedBlock];
  } else if (self.operationType == HKNetworkOperationTypePUT) {
    [self setIsExecuting:YES];
    [HKNetworking putToPath:[HKNetworkOperation urlFromPath:self.path]
                 parameters:self.parameters
                      token:self.token
               successBlock:successBlock
                failedBlock:failedBlock];
  }
}

- (BOOL)isConcurrent
{
  return YES;
}

- (BOOL)isExecuting
{
  return self.hkExecuting;
}

- (BOOL)isFinished
{
  return self.hkFinished;
}

#pragma mark - Operation completion
- (void)operationCompleted
{
  [[HKNetworkOperationQueue sharedQueue] finishedOperation:self];
  [self setIsExecuting:NO];
  [self setIsFinished:YES];
}

- (void)operationFailedWithError:(NSError *)error
{
  [[HKNetworkOperationQueue sharedQueue] failedOperation:self];
  [self setIsExecuting:NO];
  [self setIsFinished:YES];
}

#pragma mark - URL Generator
+ (NSString *)urlFromPath:(NSString *)path
{
  return [NSString stringWithFormat:@"%@/%@/%@.%@", HKNetworkingEndpoint, HKNetworkingVersion, path, HKNetworkingFormat];
}

#pragma mark - NSCoding
// NSCoding to Serialize network operations to storage whenever possible
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    _operationType = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(operationType))];
    _path = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(path))];
    _token = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(token))];
    _parameters = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(parameters))];
    _numberOfRetries = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(numberOfRetries))];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeInteger:self.operationType forKey:NSStringFromSelector(@selector(operationType))];
  [aCoder encodeObject:self.path forKey:NSStringFromSelector(@selector(path))];
  [aCoder encodeObject:self.token forKey:NSStringFromSelector(@selector(token))];
  [aCoder encodeObject:self.parameters forKey:NSStringFromSelector(@selector(parameters))];
  [aCoder encodeInteger:self.numberOfRetries forKey:NSStringFromSelector(@selector(numberOfRetries))];
}


@end

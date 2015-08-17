//
//  HOKNetworkOperation.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKNetworkOperation.h"

#import "HOKError.h"
#import "HOKNetworking.h"
#import "HOKNetworkOperationQueue.h"

@interface HOKNetworkOperation ()

@property (nonatomic, assign) BOOL hokFinished;
@property (nonatomic, assign) BOOL hokExecuting;

@end

@implementation HOKNetworkOperation

#pragma mark - Initialization
- (instancetype)initWithOperation:(HOKNetworkOperation *)operation {
  return [self initWithOperationType:operation.operationType
                                path:operation.path
                               token:operation.token
                          parameters:operation.parameters
                     numberOfRetries:operation.numberOfRetries + 1];
}

- (instancetype)initWithOperationType:(HOKNetworkOperationType)operationType
                                 path:(NSString *)path
                                token:(NSString *)token
                           parameters:(id)parameters {
  
  return [self initWithOperationType:operationType
                                path:path
                               token:token
                          parameters:parameters
                     numberOfRetries:0];
}

- (instancetype)initWithOperationType:(HOKNetworkOperationType)operationType
                                 path:(NSString *)path
                                token:(NSString *)token
                           parameters:(id)parameters
                      numberOfRetries:(NSInteger)numberOfRetries {
  
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
- (void)setIsFinished:(BOOL)isFinished {
  [self willChangeValueForKey:@"isFinished"];
  self.hokFinished = isFinished;
  [self didChangeValueForKey:@"isFinished"];
}

- (void)setIsExecuting:(BOOL)isExecuting {
  [self willChangeValueForKey:@"isExecuting"];
  self.hokExecuting = isExecuting;
  [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - NSOperation
- (void)start {
  if (self.isCancelled || self.hokFinished) {
    [self setIsFinished:YES];
    return;
  }
  
  id successBlock = ^(id json) {
    [self operationCompleted];
  };
  
  id failedBlock = ^(NSError *error) {
    [self operationFailedWithError:error];
  };
  
  if (self.operationType == HOKNetworkOperationTypeGET) {
    [self setIsExecuting:YES];
    [HOKNetworking requestToPath:[HOKNetworkOperation urlFromPath:self.path]
                      parameters:self.parameters
                           token:self.token
                    successBlock:successBlock
                     failedBlock:failedBlock];
    
  } else if (self.operationType == HOKNetworkOperationTypePOST) {
    [self setIsExecuting:YES];
    [HOKNetworking postToPath:[HOKNetworkOperation urlFromPath:self.path]
                   parameters:self.parameters
                        token:self.token
                 successBlock:successBlock
                  failedBlock:failedBlock];
    
  } else if (self.operationType == HOKNetworkOperationTypePUT) {
    [self setIsExecuting:YES];
    [HOKNetworking putToPath:[HOKNetworkOperation urlFromPath:self.path]
                  parameters:self.parameters
                       token:self.token
                successBlock:successBlock
                 failedBlock:failedBlock];
  }
}

- (BOOL)isConcurrent {
  return YES;
}

- (BOOL)isExecuting {
  return self.hokExecuting;
}

- (BOOL)isFinished {
  return self.hokFinished;
}

#pragma mark - Operation completion
- (void)operationCompleted {
  [[HOKNetworkOperationQueue sharedQueue] finishedOperation:self];
  [self setIsExecuting:NO];
  [self setIsFinished:YES];
}

- (void)operationFailedWithError:(NSError *)error {
  [[HOKNetworkOperationQueue sharedQueue] failedOperation:self];
  [self setIsExecuting:NO];
  [self setIsFinished:YES];
}

#pragma mark - URL Generator
+ (NSString *)urlFromPath:(NSString *)path {
  return [NSString stringWithFormat:@"%@/%@/%@.%@", HOKNetworkingEndpoint, HOKNetworkingVersion, path, HOKNetworkingFormat];
}

#pragma mark - NSCoding
// NSCoding to Serialize network operations to storage whenever possible
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    _operationType = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(operationType))]integerValue];
    _path = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(path))];
    _token = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(token))];
    _parameters = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(parameters))];
    _numberOfRetries = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(numberOfRetries))]integerValue];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:@(self.operationType) forKey:NSStringFromSelector(@selector(operationType))];
  [aCoder encodeObject:self.path forKey:NSStringFromSelector(@selector(path))];
  [aCoder encodeObject:self.token forKey:NSStringFromSelector(@selector(token))];
  [aCoder encodeObject:self.parameters forKey:NSStringFromSelector(@selector(parameters))];
  [aCoder encodeObject:@(self.numberOfRetries) forKey:NSStringFromSelector(@selector(numberOfRetries))];
}


@end

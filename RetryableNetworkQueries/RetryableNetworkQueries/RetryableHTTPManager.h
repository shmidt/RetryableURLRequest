//
//  RetryableHTTPManager.h
//  RetryableNetworkQueries
//
//  Created by Dmitry Shmidt on 7/25/15.
//  Copyright (c) 2015 Dmitry Shmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface RetryableHTTPManager : NSObject
@property AFHTTPRequestOperationManager *httpManager;

+ (void)sendRequest: (NSURLRequest *)request numberOfTries:(NSUInteger)numberOfTries interval: (NSTimeInterval)interval successBlock: (void (^)(AFHTTPRequestOperation *operation, id responseObject))successBlock failureBlock: (void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;
+ (void)sendRequest: (NSURLRequest *)request successBlock: (void (^)(AFHTTPRequestOperation *operation, id responseObject))successBlock failureBlock: (void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;
@end

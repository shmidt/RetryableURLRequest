//
//  RetryableHTTPManager.m
//  RetryableNetworkQueries
//
//  Created by Dmitry Shmidt on 7/25/15.
//  Copyright (c) 2015 Dmitry Shmidt. All rights reserved.
//

#import "RetryableHTTPManager.h"


@implementation RetryableHTTPManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.httpManager = [[AFHTTPRequestOperationManager alloc]init];
    }
    
    return self;
}

+ (void)sendRequest: (NSURLRequest *)request numberOfTries:(NSUInteger)numberOfTries interval: (NSTimeInterval)interval successBlock: (void (^)(AFHTTPRequestOperation *operation, id responseObject))successBlock failureBlock: (void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
    
    __block NSUInteger numberOfRetries = numberOfTries;
    __block __weak void (^weakSendRequestBlock)(void);
    
    void (^sendRequestBlock)(void);
    
    weakSendRequestBlock = sendRequestBlock = ^{
        __strong typeof (weakSendRequestBlock)strongSendRequestBlock = weakSendRequestBlock;
        numberOfRetries--;
        
        AFHTTPRequestOperation *operation = [RetryableHTTPManager.sharedInstance.httpManager HTTPRequestOperationWithRequest:request success:successBlock failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSInteger statusCode = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];

            /*
            500 Internal Server Error
            A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
            502 Bad Gateway
            The server was acting as a gateway or proxy and received an invalid response from the upstream server.
            503 Service Unavailable
            The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state.
            */
            NSLog(@"tries left: %lu", (unsigned long)numberOfRetries);
            
            if (numberOfRetries > 0 && (statusCode == 500 || statusCode == 502 || statusCode == 503 || statusCode == 0)) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    strongSendRequestBlock();
                });
            } else {
                if (failureBlock) {
                    failureBlock(operation, error);
                }
            }
        }];
        
        [RetryableHTTPManager.sharedInstance.httpManager.operationQueue addOperation:operation];
    };
    
    sendRequestBlock();
}

+ (void)sendRequest: (NSURLRequest *)request successBlock: (void (^)(AFHTTPRequestOperation *operation, id responseObject))successBlock failureBlock: (void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock{
    
    NSString *method = request.HTTPMethod;
    
    NSUInteger numberOfTries;
    NSTimeInterval interval;
    
    if ([method isEqualToString:@"POST"]) {
        numberOfTries = 2;
        interval = 7;
    } else if ([method isEqualToString:@"GET"]) {
        numberOfTries = 5;
        interval = 2;
    }
    
    [RetryableHTTPManager sendRequest: request numberOfTries: numberOfTries interval:interval successBlock:successBlock failureBlock:failureBlock];
}

@end

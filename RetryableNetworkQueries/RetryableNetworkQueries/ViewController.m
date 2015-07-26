//
//  ViewController.m
//  RetryableNetworkQueries
//
//  Created by Dmitry Shmidt on 7/25/15.
//  Copyright (c) 2015 Dmitry Shmidt. All rights reserved.
//

#import "ViewController.h"
#import "RetryableHTTPManager.h"
@interface ViewController ()

@end

@implementation ViewController
NSURL *baseURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    baseURL = [NSURL URLWithString:@"https://test.flaunt.peekabuy.com/api/"];
    // Do any additional setup after loading the view, typically from a nib.
    [self retryableGETRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

//MARK: - Example of request
- (void)retryableGETRequest {

    NSURL *url = [NSURL URLWithString:@"v2/get_boards/?username=xi-liu1&requester_username=xi-liu1" relativeToURL:baseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue: @"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod: @"GET"];
    
    [RetryableHTTPManager sendRequest: request.copy successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", operation.description);
        NSLog(@"Success: %@", responseObject);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

@end

//
//  AppDelegate.m
//  RCSystemLogMonitor
//
//  Created by Robin on 5/30/16.
//  Copyright © 2016 Robin. All rights reserved.
//

#import "AppDelegate.h"
#import "SystemLogTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SystemLogTableViewController *viewController = [[SystemLogTableViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = nav;
    
    
    NSLog(@"%s", __func__);
    
    [self networkRequestExample];
    
    [self.window makeKeyAndVisible];
    return YES;
}



- (void)networkRequestExample {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *nsurl = [NSURL URLWithString:@"https://apple.com"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:nsurl];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response: %@", response);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"error: %@", error);
    }];
    [dataTask resume];
}


@end

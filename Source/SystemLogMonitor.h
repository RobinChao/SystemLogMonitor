//
//  SystemLogMonitor.h
//  RCSystemLogMonitor
//
//  Created by Robin on 5/30/16.
//  Copyright © 2016 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>
 

@interface SystemLogMonitor : NSObject

@property (nonatomic, copy) void (^LogMessagesBlock)(NSArray *messages);

+ (instancetype)sharedInstance;

- (void)startMonitorSystemLog;

- (void)stopMonitorSystemLog;

@end

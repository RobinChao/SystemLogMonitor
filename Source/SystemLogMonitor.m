//
//  SystemLogMonitor.m
//  RCSystemLogMonitor
//
//  Created by Robin on 5/30/16.
//  Copyright © 2016 Robin. All rights reserved.
//

#import "SystemLogMonitor.h"
#import "SystemLogMessage.h"
#import <asl.h>

NSTimer *logUpdateTimer;

@implementation SystemLogMonitor

+ (instancetype)sharedInstance{
    static SystemLogMonitor *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[SystemLogMonitor alloc] init];
    });
    return monitor;
}

- (void)startMonitorSystemLog{
    
    NSTimeInterval updateInterval = 1.0;
    
#if TARGET_IPHONE_SIMULATOR
    // Querrying the ASL is much slower in the simulator. We need a longer polling interval to keep things repsonsive.
    updateInterval = 5.0;
#endif
    
    logUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(updateLogMessages) userInfo:nil repeats:YES];
}

- (void)stopMonitorSystemLog{
    [logUpdateTimer invalidate];
    logUpdateTimer = nil;
}

- (void)updateLogMessages {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *logMessage = [self.class allLogMessagesForCurrentProcess];
        if (self.LogMessagesBlock) {
            self.LogMessagesBlock(logMessage);
        }
    });
}


+ (NSArray *)allLogMessagesForCurrentProcess{
    asl_object_t query = asl_new(ASL_TYPE_QUERY);
    
    // Filter for messages form the current process
    NSString *pidString = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
    asl_set_query(query, ASL_KEY_PID, [pidString UTF8String], ASL_QUERY_OP_EQUAL);
    
    aslresponse response = asl_search(NULL, query);
    aslmsg aslMessage = NULL;
    
    NSMutableArray *logMessages = [NSMutableArray array];
    while ((aslMessage = asl_next(response))) {
        [logMessages addObject:[SystemLogMessage logMessageFromASLMessage:aslMessage]];
    }
    asl_release(response);
    
    return logMessages;
}

@end

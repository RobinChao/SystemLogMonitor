//
//  SystemLogMessage.h
//  RCSystemLogMonitor
//
//  Created by Robin on 5/30/16.
//  Copyright © 2016 Robin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <asl.h>

@interface SystemLogMessage : NSObject

+ (instancetype) logMessageFromASLMessage:(aslmsg)aslMessage;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, assign) long long messageID;


@end

//
//  SystemLogTableViewCell.h
//  RCSystemLogMonitor
//
//  Created by Robin on 5/30/16.
//  Copyright © 2016 Robin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SystemLogMessage;

extern NSString *const kSystemLogTableViewCellIdentifier;

@interface SystemLogTableViewCell : UITableViewCell

@property (nonatomic, strong) SystemLogMessage *logMessage;
@property (nonatomic, copy)  NSString *highlightedText;

+ (NSString *)displayedTextForLogMessage:(SystemLogMessage *)logMessage;
+ (CGFloat)preferredHeightForLogMessage:(SystemLogMessage *)logMessage inWidth:(CGFloat)width;

@end

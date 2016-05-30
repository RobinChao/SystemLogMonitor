//
//  ViewController.m
//  RCSystemLogMonitor
//
//  Created by Robin on 5/30/16.
//  Copyright © 2016 Robin. All rights reserved.
//

#import "SystemLogTableViewController.h"
#import "SystemLogTableViewCell.h"
#import "SystemLogMessage.h"
#import "SystemLogMonitor.h"

@interface SystemLogTableViewController ()<UISearchResultsUpdating, UISearchControllerDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSArray *logMessages;
@property (nonatomic, copy) NSArray *filteredLogMessages;

@end

@implementation SystemLogTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[SystemLogTableViewCell class] forCellReuseIdentifier:kSystemLogTableViewCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"Loading...";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" ⬇︎ " style:UIBarButtonItemStylePlain target:self action:@selector(scrollToLastRow)];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    
    [[SystemLogMonitor sharedInstance] startMonitorSystemLog];
    [SystemLogMonitor sharedInstance].LogMessagesBlock = ^(NSArray *logMessages) {
        self.logMessages = logMessages;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = @"System logs";
            // "Follow" the log as new messages stream in if we were previously near the bottom.
            BOOL wasNearBottom = self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height - 100.0;
            [self.tableView reloadData];
            if (wasNearBottom) {
                [self scrollToLastRow];
            }
        }); 
    };
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[SystemLogMonitor sharedInstance] stopMonitorSystemLog];
}

- (void)scrollToLastRow{
    NSInteger numberRows = [self.tableView numberOfRowsInSection:0];
    if (numberRows > 0) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:numberRows - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchController.isActive ? [self.filteredLogMessages count] : [self.logMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SystemLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSystemLogTableViewCellIdentifier forIndexPath:indexPath];
    cell.logMessage = [self logMessageAtIndexPath:indexPath];
    cell.highlightedText = self.searchController.searchBar.text;
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    } 
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SystemLogMessage *logMessage = [self logMessageAtIndexPath:indexPath];
    return [SystemLogTableViewCell preferredHeightForLogMessage:logMessage inWidth:self.tableView.bounds.size.width];
}

#pragma mark - Copy on long press

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        SystemLogMessage *logMessage = [self logMessageAtIndexPath:indexPath];
        NSString *stringToCopy = [SystemLogTableViewCell displayedTextForLogMessage:logMessage] ?: @"";
        [[UIPasteboard generalPasteboard] setString:stringToCopy];
    }
}

- (SystemLogMessage *)logMessageAtIndexPath:(NSIndexPath *)indexPath
{
    return self.searchController.isActive ? self.filteredLogMessages[indexPath.row] : self.logMessages[indexPath.row];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *filteredLogMessages = [self.logMessages filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SystemLogMessage *logMessage, NSDictionary *bindings) {
            NSString *displayedText = [SystemLogTableViewCell displayedTextForLogMessage:logMessage];
            return [displayedText rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0;
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([searchController.searchBar.text isEqual:searchString]) {
                self.filteredLogMessages = filteredLogMessages;
                [self.tableView reloadData];
            }
        });
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  HistoryViewController.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 6/1/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()
@property (nonatomic, strong) UIManagedDocument *historyDoc;
@property (nonatomic, strong) PRAppDelegate *delegate;

@end

@implementation HistoryViewController

@synthesize historyDoc = _historyDoc;
@synthesize delegate = _delegate;

- (void)setHistoryDoc:(UIManagedDocument *)historyDoc
{
    if (_historyDoc != historyDoc) {
        _historyDoc = historyDoc;
        //[self useDocument];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.historyDoc = self.delegate.historyDocument;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = (PRAppDelegate*)[[UIApplication sharedApplication]delegate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}

@end

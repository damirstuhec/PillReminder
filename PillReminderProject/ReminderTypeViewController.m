//
//  ReminderTypeViewController.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/16/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "ReminderTypeViewController.h"

@interface ReminderTypeViewController ()
@property (nonatomic) NSInteger selectedType;
@end

@implementation ReminderTypeViewController

@synthesize reminder = _reminder;
@synthesize editedFieldName = _editedFieldName;
@synthesize editedFieldKey = _editedFieldKey;
@synthesize selectedType = _selectedType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.reminder.reminder_type == nil) {
        self.selectedType = 1;
        NSIndexPath *secondRow = [NSIndexPath indexPathForRow:self.selectedType inSection:0];
        [self.tableView selectRowAtIndexPath:secondRow animated:NO scrollPosition:UITableViewScrollPositionNone];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:secondRow];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    } else {
        self.selectedType = [self.reminder.reminder_type integerValue];
        NSIndexPath *row = [NSIndexPath indexPathForRow:self.selectedType inSection:0];
        [self.tableView selectRowAtIndexPath:row animated:NO scrollPosition:UITableViewScrollPositionNone];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:row];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger newIndex = self.selectedType;
    if (newIndex == indexPath.row) {
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedType = indexPath.row;
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.reminder.reminder_type = [NSNumber numberWithInt:self.selectedType];
}

@end

//
//  WeekdaysViewController.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/17/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "WeekdaysViewController.h"

@interface WeekdaysViewController ()
@property (nonatomic, strong) NSMutableArray *mutableWeekdays;
@end

@implementation WeekdaysViewController

@synthesize weekdays = _weekdays;
@synthesize mutableWeekdays = _mutableWeekdays;

@synthesize delegate = _delegate;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mutableWeekdays = [self.weekdays mutableCopy];
    
    UITableViewCell *cell = nil;
    NSIndexPath *indexPath = nil;
    
    for (int i=0; i<self.weekdays.count; i++) {
        if ([self.weekdays objectAtIndex:i] == [NSNumber numberWithInt:1]) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - Done action

- (IBAction)done:(id)sender
{
    self.weekdays = [self.mutableWeekdays copy];
    
    [self.delegate weekdaysViewController:self didFinishSelectingWeekdays:self.weekdays];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *key = nil;
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([[self.mutableWeekdays objectAtIndex:indexPath.row] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        key = [NSNumber numberWithInt:1];
        [self.mutableWeekdays replaceObjectAtIndex:indexPath.row withObject:key];
    
    } else {
        key = [NSNumber numberWithInt:0];
        [self.mutableWeekdays replaceObjectAtIndex:indexPath.row withObject:key];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    } else cell.accessoryType = UITableViewCellAccessoryNone;
}

@end

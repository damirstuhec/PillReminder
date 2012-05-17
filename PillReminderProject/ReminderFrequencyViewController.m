//
//  ReminderFrequencyViewController.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/17/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "ReminderFrequencyViewController.h"


@interface ReminderFrequencyViewController ()
@property (nonatomic) NSInteger selectedSimpleFrequency;
@end

@implementation ReminderFrequencyViewController

@synthesize reminder = _reminder;
@synthesize weekdays = _weekdays;

@synthesize selectedSimpleFrequency = _selectedSimpleFrequency;


#define SIMPLE_SECTION 0
#define SPECIAL_SECTION 1

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)weekdays {
    if (_weekdays == nil) {
        _weekdays = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                                     [NSNumber numberWithInt:0], 
                                                     [NSNumber numberWithInt:0],
                                                     [NSNumber numberWithInt:0],
                                                     [NSNumber numberWithInt:0],
                                                     [NSNumber numberWithInt:0], 
                                                     [NSNumber numberWithInt:0], nil];
    }
    return _weekdays;
}
- (void)setWeekdays:(NSArray *)weekdays {
    _weekdays = weekdays;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.reminder.frequency != nil) {
        self.selectedSimpleFrequency = [self.reminder.frequency integerValue];
        NSIndexPath *row = [NSIndexPath indexPathForRow:self.selectedSimpleFrequency inSection:0];
        [self.tableView selectRowAtIndexPath:row animated:NO scrollPosition:UITableViewScrollPositionNone];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:row];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    } else self.selectedSimpleFrequency = -1;
    
    NSIndexPath *indexPath = nil;
    UITableViewCell *cell = nil;
    
    if (self.reminder.weekdays != nil) {
        self.weekdays = self.reminder.weekdays;
        indexPath = [NSIndexPath indexPathForRow:0 inSection:SPECIAL_SECTION];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    } else if (self.reminder.special_monthday != nil) {
        // TODO
        indexPath = [NSIndexPath indexPathForRow:1 inSection:SPECIAL_SECTION];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    } else if (self.reminder.interval != nil) {
        // TODO
        indexPath = [NSIndexPath indexPathForRow:2 inSection:SPECIAL_SECTION];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    } else if (self.reminder.periodicity != nil) {
        // TODO
        indexPath = [NSIndexPath indexPathForRow:3 inSection:SPECIAL_SECTION];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - Save action

- (IBAction)save:(id)sender
{
    if (self.selectedSimpleFrequency != -1) {
        self.reminder.frequency = [NSNumber numberWithInteger:self.selectedSimpleFrequency];
        self.reminder.weekdays = nil;
        self.reminder.special_monthday = nil;
        self.reminder.interval = nil;
        self.reminder.periodicity = nil;
        
    } else if (self.weekdays != nil) {
        self.reminder.frequency = nil;
        self.reminder.weekdays = self.weekdays;
        self.reminder.special_monthday = nil;
        self.reminder.interval = nil;
        self.reminder.periodicity = nil;
    
    } else {
        // TODO ostale izbire
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SIMPLE_SECTION) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSInteger newIndex = self.selectedSimpleFrequency;
        if (newIndex == indexPath.row) {
            return;
        }
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
        
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        if (newCell.accessoryType == UITableViewCellAccessoryNone) {
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedSimpleFrequency = indexPath.row;
        }
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        self.reminder.weekdays = nil;
        self.reminder.special_monthday = nil;
        self.reminder.interval = nil;
        self.reminder.periodicity = nil;
    
    } else if (indexPath.section == SPECIAL_SECTION) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"SetWeekdays" sender:self];
        
        } else [self performSegueWithIdentifier:@"SetSpecialReminder" sender:self];
    }
}


#pragma mark -
#pragma mark Segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if ([[segue identifier] isEqualToString:@"SetWeekdays"]) {
        WeekdaysViewController *weekdaysViewController = (WeekdaysViewController *)[segue destinationViewController];
        
        weekdaysViewController.delegate = self;
        weekdaysViewController.weekdays = self.weekdays;
    
    } else if ([[segue identifier] isEqualToString:@"SetSpecialReminder"]) {
        SpecialRemindersViewController *specialRemindersViewController = (SpecialRemindersViewController *)[segue destinationViewController];
        
        if (indexPath.row == 1) {
            // TODO
        
        } else if (indexPath.row == 2) {
            // TODO
            
        } else if (indexPath.row == 3) {
            // TODO
        }
    }
}

- (void)weekdaysViewController:(WeekdaysViewController *)controller didFinishSelectingWeekdays:(NSArray *)weekdays
{
    self.selectedSimpleFrequency = -1;
    self.reminder.frequency = nil;
    
    self.weekdays = weekdays;
    self.reminder.special_monthday = nil;
    self.reminder.interval = nil;
    self.reminder.periodicity = nil;
    
    [self.tableView reloadData];
}

@end

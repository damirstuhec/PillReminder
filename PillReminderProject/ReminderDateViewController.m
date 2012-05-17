//
//  ReminderDateViewController.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/11/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "ReminderDateViewController.h"

@interface ReminderDateViewController()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) NSDate *selectedDate;
@end


@implementation ReminderDateViewController

@synthesize reminder = _reminder;
@synthesize editedFieldName = _editedFieldName;
@synthesize mainTableView = _mainTableView;
@synthesize editedFieldKey = _editedFieldKey;

@synthesize datePicker = _datePicker;
@synthesize selectedDate = _selectedDate;


- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return dateFormatter;
}

- (NSDateFormatter *)timeFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return dateFormatter;
}

- (void)sortArray {
    self.reminder.hours = [self.reminder.hours sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *first = obj1;
        NSDate *second = obj2;
        return [first compare:second];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.editedFieldKey isEqualToString:@"start_date"]) {
        self.title = @"Date";
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    
    } else if ([self.editedFieldKey isEqualToString:@"end_date"]) {
        self.title = @"Date";
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    
    } else if ([self.editedFieldKey isEqualToString:@"hours"]) {
        self.title = @"Time";
        [self.datePicker setDatePickerMode:UIDatePickerModeTime];
    }
    
    if ([self.reminder.hours count] != 0) {
        NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.mainTableView selectRowAtIndexPath:firstCellIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    [self sortArray];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self sortArray];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    if ([self.editedFieldKey isEqualToString:@"hours"]) {
        self.mainTableView.editing = YES;
    }
}

#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save:(id)sender
{
    // Set the action name for the undo operation.
    NSUndoManager * undoManager = [[self.reminder managedObjectContext] undoManager];
    [undoManager setActionName:[NSString stringWithFormat:@"Setting reminder date and hours"]];
    
    if ([self.editedFieldKey isEqualToString:@"start_date"] || [self.editedFieldKey isEqualToString:@"end_date"]) {
        [self.reminder setValue:self.datePicker.date forKey:self.editedFieldKey];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender
{
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidUnload {
    [self setDatePicker:nil];
    [self setMainTableView:nil];
    [super viewDidUnload];
}

- (IBAction)datePickerValueChanged:(id)sender
{
    NSIndexPath *selectedPath = [self.mainTableView indexPathForSelectedRow];
    
    if ([self.reminder.hours count] != 0 && selectedPath.row != [self.reminder.hours count]) {
        NSMutableArray *mutHours = [self.reminder.hours mutableCopy];
        [mutHours replaceObjectAtIndex:selectedPath.row withObject:self.datePicker.date];
        self.reminder.hours = [mutHours copy];
    }
    [self.mainTableView reloadData];
    [self.mainTableView selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.editedFieldKey isEqualToString:@"hours"]) {
        return ([self.reminder.hours count]+1);
    
    } else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Reminder Date or Time Cell";
    static NSString *AddHourCellIdentifier = @"Add Reminder Hour Cell";
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([self.editedFieldKey isEqualToString:@"start_date"]) {
        cell.textLabel.text = @"Start";
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
        
    } else if ([self.editedFieldKey isEqualToString:@"end_date"]) {
        cell.textLabel.text = @"End";
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
        
    } else {
        if ([self.reminder.hours count] == 0 || indexPath.row == [self.reminder.hours count]) {
            cell = [tableView dequeueReusableCellWithIdentifier:AddHourCellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddHourCellIdentifier];
            }
        
        } else {
            NSDate *date = [self.reminder.hours objectAtIndex:[indexPath row]];
        
            cell.textLabel.text = [NSString stringWithFormat:@"%d. Time", ([indexPath row]+1)];
            cell.detailTextLabel.text = [self.timeFormatter stringFromDate:date];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.reminder.hours count] == 0 || indexPath.row == [self.reminder.hours count]) {
        NSArray *newHourInsertionIndex = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        
        NSMutableArray *mutHours = [self.reminder.hours mutableCopy];
        [mutHours addObject:[NSDate date]];
        self.reminder.hours = [mutHours copy];
        [self.datePicker setDate:[NSDate date] animated:YES];
         
        [self.mainTableView insertRowsAtIndexPaths:newHourInsertionIndex withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.mainTableView reloadData];
        [self.mainTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    } else {
        NSDate *chosenHour = [self.reminder.hours objectAtIndex:[indexPath row]];
        [self.datePicker setDate:chosenHour animated:YES];
    }
}


#pragma mark -
#pragma mark Editing rows

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.reminder.hours count] == 0 || indexPath.row == [self.reminder.hours count]) {
        return UITableViewCellEditingStyleInsert;
    
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *mutHours = [self.reminder.hours mutableCopy];
        [mutHours removeObjectAtIndex:[indexPath row]];
        self.reminder.hours = [mutHours copy];
    
        [self.mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end

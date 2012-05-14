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

@end


@implementation ReminderDateViewController

@synthesize reminder = _reminder;
@synthesize editedFieldName = _editedFieldName;
@synthesize editedFieldKey = _editedFieldKey;

@synthesize datePicker = _datePicker;


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
}


#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save:(id)sender
{
    // Set the action name for the undo operation.
    NSUndoManager * undoManager = [[self.reminder managedObjectContext] undoManager];
    [undoManager setActionName:[NSString stringWithFormat:@"Setting reminder date and hours"]];
    
    if ([self.editedFieldKey isEqualToString:@"hours"]) {
        [self.reminder.hours addObject:self.datePicker.date];
    
    } else {
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
    [super viewDidUnload];
}

- (IBAction)datePickerValueChanged:(id)sender
{
    /*
    if ([self.editedFieldKey isEqualToString:@"start_date"] || [self.editedFieldKey isEqualToString:@"end_date"]) {
        self.textField.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    
    } else if ([self.editedFieldKey isEqualToString:@"hours"]) {
        self.textField.text = [self.timeFormatter stringFromDate:self.datePicker.date];
    }
    */
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.editedFieldKey isEqualToString:@"hours"]) {
        return [self.reminder.hours count];
    
    } else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Reminder Date or Time Cell";
    
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
        NSDate *date = [self.reminder.hours objectAtIndex:[indexPath row]];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%d. Time", ([indexPath row]+1)];
        cell.detailTextLabel.text = [self.timeFormatter stringFromDate:date];
    }
    return cell;
}

@end

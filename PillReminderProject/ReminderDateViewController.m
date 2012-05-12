//
//  ReminderDateViewController.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/11/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "ReminderDateViewController.h"

@interface ReminderDateViewController()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *textFieldLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end


@implementation ReminderDateViewController

@synthesize reminder = _reminder;
@synthesize editedFieldName = _editedFieldName;
@synthesize editedFieldKey = _editedFieldKey;

@synthesize textField = _textField;
@synthesize textFieldLabel = _textFieldLabel;
@synthesize datePicker = _datePicker;


#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save:(id)sender
{
    // Set the action name for the undo operation.
    NSUndoManager * undoManager = [[self.reminder managedObjectContext] undoManager];
    [undoManager setActionName:[NSString stringWithFormat:@"Setting reminder date"]];
    
    [self.reminder setValue:self.datePicker.date forKey:self.editedFieldKey];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender
{
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidUnload {
    [self setDatePicker:nil];
    [self setTextField:nil];
    [self setTextFieldLabel:nil];
    [super viewDidUnload];
}
@end

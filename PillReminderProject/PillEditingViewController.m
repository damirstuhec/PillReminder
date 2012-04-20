//
//  PillEditingViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillEditingViewController.h"

@interface PillEditingViewController ()
@property (nonatomic, weak) IBOutlet UITextField *textField;
@end


@implementation PillEditingViewController

@synthesize textField = _textField, editedPill=_editedPill, editedFieldKey=_editedFieldKey, editedFieldName=_editedFieldName;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    // Set the title to the user-visible name of the field.
    self.title = self.editedFieldName;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure the user interface according to state.
    /*if (self.editingDate) {
        
        self.textField.hidden = YES;
        self.datePicker.hidden = NO;
        NSDate *date = [self.editedObject valueForKey:self.editedFieldKey];
        if (date == nil) {
            date = [NSDate date];
        }
        self.datePicker.date = date;
    }
    else {
    */    
        self.textField.hidden = NO;
        //self.datePicker.hidden = YES;
        self.textField.text = [NSString stringWithFormat:@"%@", [self.editedPill valueForKey:self.editedFieldKey]];
        self.textField.placeholder = self.title;
        [self.textField becomeFirstResponder];
    //}
}

#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save:(id)sender
{
    // Set the action name for the undo operation.
    NSUndoManager * undoManager = [[self.editedPill managedObjectContext] undoManager];
    [undoManager setActionName:[NSString stringWithFormat:@"%@", self.editedFieldName]];
    
    // Pass current value to the edited object, then pop.
    //if (self.editingDate) {
    //    [self.editedObject setValue:self.datePicker.date forKey:self.editedFieldKey];
    //}
    //else {
        [self.editedPill setValue:self.textField.text forKey:self.editedFieldKey];
    //}
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender
{
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}

@end

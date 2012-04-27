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
@property (nonatomic, retain) NSArray *wheelPickerItemsArray;
@property (weak, nonatomic) IBOutlet UIPickerView *wheelPicker;
@end


@implementation PillEditingViewController

@synthesize textField = _textField, editedPill=_editedPill, editedFieldKey=_editedFieldKey, editedFieldName=_editedFieldName, wheelPicker = _wheelPicker, wheelPickerItemsArray = _wheelPickerItemsArray;


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
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:1007];
    [temp addObject:@"0.25"]; [temp addObject:@"0.50"]; [temp addObject:@"0.75"]; [temp addObject:@"1.0"]; 
    [temp addObject:@"2.0"]; [temp addObject:@"3.0"]; [temp addObject:@"4.0"];
    
    for (int i=5; i<1001; ) {
        [temp addObject:[NSString stringWithFormat:@"%d.0", i]];
        i+=5;
    }
    
    self.wheelPickerItemsArray = [temp copy];
    self.wheelPicker.hidden = NO;
    self.textField.enabled = NO;
    
    // this view controller is the data source and delegate for wheelPicker
	self.wheelPicker.delegate = self;
	self.wheelPicker.dataSource = self;

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
        self.textField.text = [NSString stringWithFormat:@"%@", [self.editedPill valueForKey:self.editedFieldKey]];
        self.textField.placeholder = self.title;
        //[self.textField becomeFirstResponder];
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

- (void)viewDidUnload {
    [self setWheelPicker:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.textField.text = [NSString stringWithFormat:@"%@ mg", [self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:0]]];
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
	returnStr = [self.wheelPickerItemsArray objectAtIndex:row];

	return returnStr;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.wheelPickerItemsArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

@end

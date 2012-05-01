//
//  PillEditingViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillEditingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PillEditingViewController ()
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, retain) NSArray *wheelPickerItemsArray;
@property (nonatomic, weak) IBOutlet UIPickerView *wheelPicker;
@property (nonatomic, readonly, getter=isEditingPillWeight) BOOL editingPillWeight;
@property (nonatomic) BOOL editingTextField;
@property (nonatomic) BOOL editingTextView;
@end


@implementation PillEditingViewController
{
    BOOL hasDeterminedWhetherEditingPillWeight;
}

@synthesize textField = _textField, editedPill=_editedPill, editedFieldKey=_editedFieldKey, editedFieldName=_editedFieldName, wheelPicker = _wheelPicker, wheelPickerItemsArray = _wheelPickerItemsArray, editingPillWeight = _editingPillWeight, textView = _textView, editingTextField = _editingTextField, editingTextView = _editingTextView;

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
    if (self.editingPillWeight) {
        
        NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:1007];
        [temp addObject:@"0.25"]; [temp addObject:@"0.50"]; [temp addObject:@"0.75"]; [temp addObject:@"1.0"]; 
        [temp addObject:@"2.0"]; [temp addObject:@"3.0"]; [temp addObject:@"4.0"];
        
        for (int i=5; i<1001; ) {
            [temp addObject:[NSString stringWithFormat:@"%d.0", i]];
            i+=5;
        }
        
        self.wheelPickerItemsArray = [temp copy];
        self.wheelPicker.hidden = NO;
        self.textView.hidden = YES;
        self.textField.hidden = NO;
        self.textField.enabled = NO;
        self.wheelPicker.delegate = self;
        self.wheelPicker.dataSource = self;
    
    }else if ([self.editedFieldKey isEqualToString:@"name"]) {
        self.wheelPicker.hidden = YES;
        self.textView.hidden = YES;
        self.textField.hidden = NO;
        self.textField.enabled = YES;
        self.textField.text = [NSString stringWithFormat:@"%@", [self.editedPill valueForKey:self.editedFieldKey]];
        self.textField.placeholder = self.title;
        [self.textView resignFirstResponder];
        [self.textField becomeFirstResponder];
        self.editingTextField = YES;
    
    }else if ([self.editedFieldKey isEqualToString:@"warnings"] || [self.editedFieldKey isEqualToString:@"side_effects"] || [self.editedFieldKey isEqualToString:@"storage"] || [self.editedFieldKey isEqualToString:@"extra"]) {
        self.wheelPicker.hidden = YES;
        self.textField.hidden = YES;
        self.textView.hidden = NO;
        self.textView.text = [NSString stringWithFormat:@"%@", [self.editedPill valueForKey:self.editedFieldKey]];
        self.textView.clipsToBounds = YES;
        self.textView.layer.cornerRadius = 8.0f;
        self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
        self.textView.layer.borderWidth = 1.4f;
        [self.textField resignFirstResponder];
        [self.textView becomeFirstResponder];
        self.editingTextView = YES;
    }
}

#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save:(id)sender
{
    // Set the action name for the undo operation.
    NSUndoManager * undoManager = [[self.editedPill managedObjectContext] undoManager];
    [undoManager setActionName:[NSString stringWithFormat:@"%@", self.editedFieldName]];
    
    if (self.editingPillWeight) {
        NSNumber *pillWeight = [NSNumber numberWithInt:[self.textField.text integerValue]];
        [self.editedPill setValue:pillWeight forKey:self.editedFieldKey];
    
    }else if (self.editingTextField) {
        [self.editedPill setValue:self.textField.text forKey:self.editedFieldKey];
    
    }else if (self.editingTextView) {
        [self.editedPill setValue:self.textView.text forKey:self.editedFieldKey];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender
{
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setWheelPicker:nil];
    [self setTextView:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Manage whether editing a date

- (void)setEditedFieldKey:(NSString *)editedFieldKey
{
    if (![_editedFieldKey isEqualToString:editedFieldKey]) {
        hasDeterminedWhetherEditingPillWeight = NO;
        self.editingTextField = NO;
        self.editingTextView = NO;
        
        _editedFieldKey = editedFieldKey;
    }
}


- (BOOL)isEditingPillWeight
{
    if (hasDeterminedWhetherEditingPillWeight == YES) {
        return _editingPillWeight;
    }
    
    NSEntityDescription *entity = [self.editedPill entity];
    NSAttributeDescription *attribute = [[entity attributesByName] objectForKey:self.editedFieldKey];
    NSString *attributeClassName = [attribute attributeValueClassName];
    
    NSLog(@"%@", attributeClassName);
    if ([attributeClassName isEqualToString:@"NSNumber"]) {
        _editingPillWeight = YES;
    }
    else {
        _editingPillWeight = NO;
    }
    
    hasDeterminedWhetherEditingPillWeight = YES;
    return _editingPillWeight;
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.textField.text = [NSString stringWithFormat:@"%@", [self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:0]]];
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
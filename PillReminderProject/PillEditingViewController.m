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
@property (nonatomic, weak) IBOutlet UILabel *textFieldLabel;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIPickerView *wheelPicker;

@property (nonatomic, readonly, getter=isEditingPillStrength) BOOL editingPillStrength;
@property (nonatomic, readonly, getter=isEditingPillsPerDose) BOOL editingPillsPerDose;
@property (nonatomic, strong) NSString *pillStrength;
@property (nonatomic, strong) NSNumber *pillsDosage;
@property (nonatomic, retain) NSArray *wheelPickerItemsArray;
@property (nonatomic, retain) NSArray *wheelPickerItemsArrayUnits;
@property (nonatomic) BOOL editingTextField;
@property (nonatomic) BOOL editingTextView;
@end


@implementation PillEditingViewController
{
    BOOL hasDeterminedWhetherEditingPillStrength;
    BOOL hasDeterminedWhetherEditingPillsPerDose;
}

@synthesize editedPill = _editedPill;
@synthesize editedFieldKey = _editedFieldKey;
@synthesize editedFieldName = _editedFieldName;

@synthesize textField = _textField;
@synthesize textFieldLabel = _textFieldLabel;
@synthesize textView = _textView;
@synthesize wheelPicker = _wheelPicker;

@synthesize editingPillStrength = _editingPillStrength;
@synthesize editingPillsPerDose = _editingPillsPerDose;
@synthesize pillStrength = _pillStrength;
@synthesize pillsDosage = _pillsDosage;
@synthesize wheelPickerItemsArray = _wheelPickerItemsArray;
@synthesize wheelPickerItemsArrayUnits = _wheelPickerItemsArrayUnits;
@synthesize editingTextField = _editingTextField;
@synthesize editingTextView = _editingTextView;

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
    
    if (self.editingPillStrength) {
        self.textFieldLabel.text = @"Pill strength";
        NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:10];
        for (int i=0; i<10; i++) {
            [temp addObject:[NSString stringWithFormat:@"%d", i]];
        }
        
        NSMutableArray *temp2 = [[NSMutableArray alloc] initWithCapacity:4];
        [temp2 addObject:@"g"];
        [temp2 addObject:@"mg"];
        [temp2 addObject:@"mcg"];
        [temp2 addObject:@"units"];
        
        self.wheelPickerItemsArray = [temp copy];
        self.wheelPickerItemsArrayUnits = [temp2 copy];
        self.wheelPicker.hidden = NO;
        self.textView.hidden = YES;
        self.textField.hidden = NO;
        self.textField.enabled = NO;
        self.textFieldLabel.hidden = NO;
        self.wheelPicker.delegate = self;
        self.wheelPicker.dataSource = self;
        self.textField.text = [NSString stringWithFormat:@"%@", [self.editedPill valueForKey:self.editedFieldKey]];
    
    }else if (self.editingPillsPerDose) {
        self.textFieldLabel.text = @"Pills per dose";
        NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:99];
        for (int i=1; i<100; i++) {
            [temp addObject:[NSString stringWithFormat:@"%d", i]];
        }
        
        self.wheelPickerItemsArray = [temp copy];
        self.wheelPicker.hidden = NO;
        self.textView.hidden = YES;
        self.textField.hidden = NO;
        self.textField.enabled = NO;
        self.textFieldLabel.hidden = NO;
        self.wheelPicker.delegate = self;
        self.wheelPicker.dataSource = self;
        self.textField.text = [NSString stringWithFormat:@"%d", [[self.editedPill valueForKey:self.editedFieldKey] integerValue]];
        
    }else if ([self.editedFieldKey isEqualToString:@"name"]) {
        self.textFieldLabel.text = @"";
        self.wheelPicker.hidden = YES;
        self.textView.hidden = YES;
        self.textField.hidden = NO;
        self.textField.enabled = YES;
        self.textFieldLabel.hidden = YES;
        self.textField.text = [NSString stringWithFormat:@"%@", [self.editedPill valueForKey:self.editedFieldKey]];
        self.textField.placeholder = self.title;
        [self.textView resignFirstResponder];
        [self.textField becomeFirstResponder];
        self.editingTextField = YES;
    
    }else if ([self.editedFieldKey isEqualToString:@"warnings"] || [self.editedFieldKey isEqualToString:@"side_effects"] || [self.editedFieldKey isEqualToString:@"storage"] || [self.editedFieldKey isEqualToString:@"extra"]) {
        self.wheelPicker.hidden = YES;
        self.textField.hidden = YES;
        self.textFieldLabel.hidden = YES;
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
    
    if (self.editingPillStrength) {
        [self.editedPill setValue:self.pillStrength forKey:self.editedFieldKey];
    
    } else if (self.editingPillsPerDose) {
        [self.editedPill setValue:self.pillsDosage forKey:self.editedFieldKey];
        
    } else if (self.editingTextField) {
        [self.editedPill setValue:self.textField.text forKey:self.editedFieldKey];
    
    } else if (self.editingTextView) {
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
    [self setTextFieldLabel:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma mark Manage whether editing a date

- (void)setEditedFieldKey:(NSString *)editedFieldKey
{
    if (![_editedFieldKey isEqualToString:editedFieldKey]) {
        hasDeterminedWhetherEditingPillStrength = NO;
        hasDeterminedWhetherEditingPillsPerDose = NO;
        self.editingTextField = NO;
        self.editingTextView = NO;
        
        _editedFieldKey = editedFieldKey;
    }
}


- (BOOL)isEditingPillStrength
{
    if (hasDeterminedWhetherEditingPillStrength == YES) {
        return _editingPillStrength;
    }

    if ([self.editedFieldKey isEqualToString:@"strength"]) {
        _editingPillStrength = YES;
    }
    else {
        _editingPillStrength = NO;
    }
    
    hasDeterminedWhetherEditingPillStrength = YES;
    return _editingPillStrength;
}

- (BOOL)isEditingPillsPerDose
{
    if (hasDeterminedWhetherEditingPillsPerDose == YES) {
        return _editingPillsPerDose;
    }
    
    if ([self.editedFieldKey isEqualToString:@"per_dose"]) {
        _editingPillsPerDose = YES;
    }
    else {
        _editingPillsPerDose = NO;
    }
    
    hasDeterminedWhetherEditingPillsPerDose = YES;
    return _editingPillsPerDose;
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.editingPillStrength) {
        float temp = 
        ([[self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:0]]
          integerValue] * 1000) + 
        ([[self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:1]]
          integerValue] * 100) +
        ([[self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:2]]
          integerValue] * 10) + 
        [[self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:3]]
         integerValue] + 
        ([[self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:5]] 
          integerValue] * 0.1) + 
        ([[self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:6]] 
          integerValue] * 0.01);
        
        self.pillStrength = [NSString stringWithFormat:@"%.2f %@", temp,
                             [self.wheelPickerItemsArrayUnits objectAtIndex:[self.wheelPicker selectedRowInComponent:7]]];
        
        self.textField.text = self.pillStrength;
    
    } else if (self.editingPillsPerDose) {
        self.pillsDosage = [NSNumber numberWithInteger:[[self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:0]] integerValue]];
        self.textField.text = [NSString stringWithFormat:@"%d", [self.pillsDosage integerValue]];
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (self.editingPillStrength) {
        if (component < 4 || component == 5 || component == 6) {
            return 33.0;
            
        } else if (component == 4) {
            return 19.0;
            
        } else {
            return 50;
        }
    } else { return 80; }
}


- (UIView *)pickerView:(UIPickerView *)pickerView 
            viewForRow:(NSInteger)row 
          forComponent:(NSInteger)component 
           reusingView:(UIView *)view {
    
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width,
                                                                      [pickerView rowSizeForComponent:component].height)];
        retval.backgroundColor = [UIColor clearColor];
    }
    retval.textAlignment = UITextAlignmentCenter;
    retval.font = [UIFont boldSystemFontOfSize:18];
    
    if (self.editingPillStrength) {
        if (component < 4 || component == 5 || component == 6) {
            retval.text = [self.wheelPickerItemsArray objectAtIndex:row];
            
        } else if (component == 4) {
            retval.text = @" .";
            
        } else {
            retval.text = [self.wheelPickerItemsArrayUnits objectAtIndex:row];
            retval.textColor = [UIColor darkGrayColor];
            retval.font = [UIFont boldSystemFontOfSize:14];
        }
    
    } else if (self.editingPillsPerDose) { retval.text = [self.wheelPickerItemsArray objectAtIndex:row]; }

    return retval;
}


#pragma mark -
#pragma mark UIPickerViewDataSource

/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnStr = @"";
    
    if (component < 4 || component == 5 || component == 6) {
        returnStr = [self.wheelPickerItemsArray objectAtIndex:row];
        return returnStr;
        
    } else if (component == 4) {
        return @".";
        
    } else {
        returnStr = [self.wheelPickerItemsArrayUnits objectAtIndex:row];
        return returnStr;
    }
}
*/
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.editingPillStrength) {
        if (component < 4 || component == 5 || component == 6) {
            return [self.wheelPickerItemsArray count];
            
        } else if (component == 7) { 
            return [self.wheelPickerItemsArrayUnits count];
            
        } else {
            return 1;
        }
    
    } else {
        return [self.wheelPickerItemsArray count];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.editingPillStrength) {
        return 8;
    
    } else return 1;
}

@end
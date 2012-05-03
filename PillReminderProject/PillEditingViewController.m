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
@property (nonatomic, strong) NSNumber *pillDosage;
@property (nonatomic, strong) NSString *pillDosageUnit;

@property (nonatomic, retain) NSArray *wheelPickerItemsArray;
@property (nonatomic, retain) NSArray *wheelPickerItemsArrayUnits;
@property (nonatomic, weak) IBOutlet UIPickerView *wheelPicker;
@property (nonatomic, readonly, getter=isEditingPillWeight) BOOL editingPillWeight;
@property (nonatomic) BOOL editingTextField;
@property (nonatomic) BOOL editingTextView;
@property (nonatomic) BOOL isPillDosageChanged;
@end


@implementation PillEditingViewController
{
    BOOL hasDeterminedWhetherEditingPillWeight;
}

@synthesize textField = _textField;
@synthesize editedPill = _editedPill;
@synthesize editedFieldKey = _editedFieldKey;
@synthesize editedFieldName = _editedFieldName;
@synthesize wheelPicker = _wheelPicker;
@synthesize wheelPickerItemsArray = _wheelPickerItemsArray;
@synthesize wheelPickerItemsArrayUnits = _wheelPickerItemsArrayUnits;
@synthesize editingPillWeight = _editingPillWeight;
@synthesize textView = _textView;
@synthesize editingTextField = _editingTextField;
@synthesize editingTextView = _editingTextView;
@synthesize pillDosage = _pillDosage;
@synthesize pillDosageUnit = _pillDosageUnit;
@synthesize isPillDosageChanged = _isPillDosageChanged;

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
    self.isPillDosageChanged = NO;
    
    if (self.editingPillWeight) {
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
        self.wheelPicker.delegate = self;
        self.wheelPicker.dataSource = self;
        self.textField.text = [NSString stringWithFormat:@"%d mg", [self.editedPill valueForKey:self.editedFieldKey]];
    
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
        [self.editedPill setValue:self.pillDosage forKey:self.editedFieldKey];
    
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
    float temp = ([[self.wheelPickerItemsArray objectAtIndex:[self.wheelPicker selectedRowInComponent:0]]
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
    
    self.pillDosage = [NSNumber numberWithFloat:temp];
    self.pillDosageUnit = [self.wheelPickerItemsArrayUnits objectAtIndex:[self.wheelPicker 
                                                           selectedRowInComponent:7]];
    
    self.textField.text = [NSString stringWithFormat:@"%.2f %@", temp, self.pillDosageUnit];
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component < 4 || component == 5 || component == 6) {
        return 33.0;
    
    } else if (component == 4) {
        return 19.0;
    
    } else {
        return 50;
    }
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width,
                                                                      [pickerView rowSizeForComponent:component].height)];
        retval.backgroundColor = [UIColor clearColor];
    }
    retval.textAlignment = UITextAlignmentCenter;
    retval.font = [UIFont boldSystemFontOfSize:18];
    
    if (component < 4 || component == 5 || component == 6) {
        retval.text = [self.wheelPickerItemsArray objectAtIndex:row];
        
    } else if (component == 4) {
        retval.text = @" .";
        
    } else {
        retval.text = [self.wheelPickerItemsArrayUnits objectAtIndex:row];
        retval.textColor = [UIColor purpleColor];
        retval.font = [UIFont boldSystemFontOfSize:14];
    }

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
    if (component < 4 || component == 5 || component == 6) {
        return [self.wheelPickerItemsArray count];
        
    } else if (component == 7) { 
        return [self.wheelPickerItemsArrayUnits count];
    
    } else {
        return 1;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 8;
}

@end
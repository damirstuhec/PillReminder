//
//  SpecialRemindersViewController.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/17/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "SpecialRemindersViewController.h"


@interface SpecialRemindersViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property (nonatomic, strong) NSArray *pickerComponentOne;
@property (nonatomic, strong) NSArray *pickerComponentTwo;

@property (nonatomic, strong) NSMutableArray *mutableHelperArray;
@end


@implementation SpecialRemindersViewController
@synthesize delegate = _delegate;

@synthesize monthday = _monthday;
@synthesize interval = _interval;
@synthesize periodicity = _periodicity;

@synthesize editedFieldKey = _editedFieldKey;
@synthesize editedFieldName = _editedFieldName;
@synthesize pickerView = _pickerView;
@synthesize mainTableView = _mainTableView;

@synthesize pickerComponentOne = _pickerComponentOne;
@synthesize pickerComponentTwo = _pickerComponentTwo;

@synthesize mutableHelperArray = _mutableHelperArray;


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setPickerView:nil];
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSMutableArray *component1 = nil;
    NSMutableArray *component2 = nil;
    
    if ([self.editedFieldKey isEqualToString:@"special_monthday"]) {
        // TODO
        self.title = @"Month day";
        component1 = [[NSMutableArray alloc] initWithObjects:@"1st", @"2nd", @"3rd", @"4th", @"Last", nil];
        component2 = [[NSMutableArray alloc] initWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", nil];
        
        self.pickerComponentOne = [component1 copy];
        self.pickerComponentTwo = [component2 copy];
        self.mutableHelperArray = [self.monthday mutableCopy];
        
    } else if ([self.editedFieldKey isEqualToString:@"interval"]) {
        // TODO
        self.title = @"Interval";
        
    } else if ([self.editedFieldKey isEqualToString:@"periodicity"]) {
        
        self.title = @"Periodicity";
        component1 = [[NSMutableArray alloc] initWithCapacity:60];
        component2 = [[NSMutableArray alloc] initWithCapacity:60];
        
        for (int i=0; i<60; i++) {
            [component1 addObject:[NSNumber numberWithInt:(i+1)]];
            [component2 addObject:[NSNumber numberWithInt:(i+1)]];
        }
        self.pickerComponentOne = [component1 copy];
        self.pickerComponentTwo = [component2 copy];
        self.mutableHelperArray = [self.periodicity mutableCopy];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([self.editedFieldKey isEqualToString:@"special_monthday"]) {
        cell.textLabel.text = @"Month day";
        
        if (self.monthday != nil) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [self.mutableHelperArray objectAtIndex:0], [self.mutableHelperArray objectAtIndex:1]];
        } else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [self.pickerComponentOne objectAtIndex:0], [self.pickerComponentTwo objectAtIndex:0]];
        
    } else if ([self.editedFieldKey isEqualToString:@"periodicity"]) {
        cell.textLabel.text = @"Periodicity";
        
        if (self.periodicity != nil) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d days ON / %d days OFF", [[self.mutableHelperArray objectAtIndex:0] integerValue], [[self.mutableHelperArray objectAtIndex:1] integerValue]];
        
        } else cell.detailTextLabel.text = @"0 days ON / 0 days OFF";
        
    }
    return cell;
}


- (IBAction)done:(id)sender
{
    if ([self.editedFieldKey isEqualToString:@"special_monthday"]) {
        // TODO
        self.monthday = [self.mutableHelperArray copy];
        [self.delegate specialRemindersViewControllerDelegate:self didFinishSelectingMonthday:self.monthday];
        
    } else if ([self.editedFieldKey isEqualToString:@"interval"]) {
        // TODO
        [self.delegate specialRemindersViewControllerDelegate:self didFinishSelectingInterval:self.interval];
        
    } else if ([self.editedFieldKey isEqualToString:@"periodicity"]) {
        // TODO
        self.periodicity = [self.mutableHelperArray copy];
        [self.delegate specialRemindersViewControllerDelegate:self didFinishSelectingPeriodicity:self.periodicity];
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.editedFieldKey isEqualToString:@"special_monthday"]) {
        if (component == 0) [self.mutableHelperArray replaceObjectAtIndex:component withObject:[self.pickerComponentOne objectAtIndex:row]];
        else [self.mutableHelperArray replaceObjectAtIndex:component withObject:[self.pickerComponentTwo objectAtIndex:row]];
        
    } else if ([self.editedFieldKey isEqualToString:@"periodicity"]) {
        [self.mutableHelperArray replaceObjectAtIndex:component withObject:[NSNumber numberWithInt:(row+1)]];
    }

    [self.mainTableView reloadData];
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if ([self.editedFieldKey isEqualToString:@"special_monthday"]) {
        if (component == 0) return 70;
        else return 120;
        
    } else return 70;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([self.editedFieldKey isEqualToString:@"special_monthday"]) {
        if (component == 0) return [NSString stringWithFormat:@"%@", [self.pickerComponentOne objectAtIndex:row]];
        else return [NSString stringWithFormat:@"%@", [self.pickerComponentTwo objectAtIndex:row]];
        
    } else if ([self.editedFieldKey isEqualToString:@"periodicity"]) {
        if (component == 0) return [NSString stringWithFormat:@"%d", [[self.pickerComponentOne objectAtIndex:row] integerValue]];
        else return [NSString stringWithFormat:@"%d", [[self.pickerComponentTwo objectAtIndex:row] integerValue]];
    
    } else return @"empty";
}


#pragma mark -
#pragma mark UIPickerViewDataSource


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) return [self.pickerComponentOne count];
    else return [self.pickerComponentTwo count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

@end

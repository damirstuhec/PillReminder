//
//  PillDetailsViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillDetailsViewController.h"
#import "PillEditingViewController.h"
#import "PillNotesList.h"
#import "RemindMeCell.h"
#import "ReminderDateViewController.h"
#import "ReminderTypeViewController.h"
#import "ReminderSoundViewController.h"
#import "ReminderFrequencyViewController.h"


@interface PillDetailsViewController()

@property (nonatomic) BOOL hasInsertedAddNoteRow;
@property (nonatomic) BOOL hasInsertedDeletePillSection;

@property (nonatomic, strong) NSUndoManager *undoManager;
@property (nonatomic, strong) NSArray *pillNotes;

- (IBAction)remindMeSwitched:(id)sender;

- (void)updateRightBarButtonItemState;

@end


@implementation PillDetailsViewController

@synthesize hasInsertedAddNoteRow = _hasInsertedAddNoteRow;
@synthesize hasInsertedDeletePillSection = hasInsertedDeletePillSection;

@synthesize undoManager = _undoManager;
@synthesize pillNotes = _pillNotes;
@synthesize detailsDelegate = _detailsDelegate;

@synthesize pill = _pill;

#define PILL_SECTION 0
#define DOSAGE_SECTION 1
#define NOTES_SECTION 2
#define REMINDER_SECTION 3
#define REMIND_ME_SECTION 4
#define DELETE_PILL_SECTION 5


- (void)deleteAllNotificationsForThatPill
{
    self.pill.whoRemindFor.notifications = nil;
}

- (void)cancellAllNotificationsForThatPill
{
    UILocalNotification *localNotif = nil;
    
    for (int i=0; i<self.pill.whoRemindFor.notifications.count; i++) {
        localNotif = [self.pill.whoRemindFor.notifications objectAtIndex:i];
        [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
    }
}

- (UILocalNotification *)setLocalNotification:(UILocalNotification *)localNotification withFireDate:(NSDate *)fireDate andEndDate:(NSDate *)endDate
{
    localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"- Take pill(s) -\nName: %@\nStrength: %@\nIntake: %d pill(s)", nil), 
                                   self.pill.name, self.pill.strength, [self.pill.per_dose integerValue]];
    localNotification.alertAction = NSLocalizedString(@"TAKE", nil);
    localNotification.soundName = [NSString stringWithFormat:@"%@.caf", self.pill.whoRemindFor.alarm_sound];
    localNotification.applicationIconBadgeNumber = 1;
    NSDictionary *userInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.pill.name, @"pill.name", self.pill.strength, @"pill.strength", [NSString stringWithFormat:@"%d", [self.pill.per_dose integerValue]], @"pill.per_dose", endDate, @"pill.end_date", nil];
    localNotification.userInfo = userInfoDictionary;
    
    return localNotification;
}

- (void)scheduleNotifications
{
    [self cancellAllNotificationsForThatPill];
    [self deleteAllNotificationsForThatPill];
    
    UILocalNotification *localNotification = nil;

    if (self.pill.whoRemindFor.notifications != nil || self.pill.whoRemindFor.notifications.count != 0) {
        for (int i=0; i<self.pill.whoRemindFor.notifications.count; i++) {
            localNotification = [self.pill.whoRemindFor.notifications objectAtIndex:i];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        
    } else {
        NSDate *notificationFireDate = nil;
        NSDate *notificationEndDate = nil;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setTimeZone:[NSTimeZone defaultTimeZone]];
        
        NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit 
                                                       fromDate:self.pill.whoRemindFor.start_date];
        [dateComponents setTimeZone:[NSTimeZone defaultTimeZone]];
        
        NSDateComponents *endDateComponents = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit 
                                                       fromDate:self.pill.whoRemindFor.end_date];
        [endDateComponents setTimeZone:[NSTimeZone defaultTimeZone]];
        
        NSDateComponents *timeComponents = nil;
        [timeComponents setTimeZone:[NSTimeZone defaultTimeZone]];
        
        [components setDay:[dateComponents day]];
        [components setMonth:[dateComponents month]];
        [components setYear:[dateComponents year]];
        
        if (self.pill.whoRemindFor.frequency != nil) {
            
            for (int i=0; i<self.pill.whoRemindFor.hours.count; i++) {
                timeComponents = [calendar components:NSMinuteCalendarUnit | NSHourCalendarUnit fromDate:[self.pill.whoRemindFor.hours objectAtIndex:i]];
                [components setHour:[timeComponents hour]];
                [components setMinute:[timeComponents minute]];
                
                [endDateComponents setHour:[timeComponents hour]];
                [endDateComponents setMinute:[timeComponents minute]];
                
                notificationFireDate = [calendar dateFromComponents:components];
                notificationEndDate = [calendar dateFromComponents:endDateComponents];
                
                localNotification = [self setLocalNotification:localNotification withFireDate:notificationFireDate andEndDate:notificationEndDate];
                                
                switch ([self.pill.whoRemindFor.frequency integerValue]) {
                    case 0:
                        NSLog(@"Just once");
                        break;
                    case 1:
                        NSLog(@"Daily");
                        localNotification.repeatInterval = NSDayCalendarUnit;
                        break;
                    case 2:
                        NSLog(@"Weekly");
                        localNotification.repeatInterval = NSWeekCalendarUnit;
                        break;
                    case 3:
                        NSLog(@"Monthly");
                        localNotification.repeatInterval = NSMonthCalendarUnit;
                        break;
                }
                
                localNotification.repeatCalendar = calendar;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        
        } else if (self.pill.whoRemindFor.weekdays != nil) {
            int weekday = 0;
            int weekdayOrdinal = 1;
            
            NSDate *start = [calendar dateFromComponents:components];
            NSDateComponents *fireComponents = [[NSDateComponents alloc] init];
            
            for (int i=0; i<7; i++) {
                
                if ([[self.pill.whoRemindFor.weekdays objectAtIndex:i] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                    if (i<6) weekday = i+2;
                    else weekday = 1;
                    weekdayOrdinal = 1;
                    
                    fireComponents = [calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:start];
                    [fireComponents setTimeZone:[NSTimeZone defaultTimeZone]];
                    [fireComponents setWeekday:weekday];
                    [fireComponents setWeekdayOrdinal:weekdayOrdinal];
                    
                    NSDate *fire = [calendar dateFromComponents:fireComponents];
                    
                    while ([fire compare:start] == NSOrderedAscending) {
                        weekdayOrdinal++;
                        [fireComponents setWeekdayOrdinal:weekdayOrdinal];
                        fire = [calendar dateFromComponents:fireComponents];
                    }
                    
                    for (int j=0; j<self.pill.whoRemindFor.hours.count; j++) {
                        timeComponents = [calendar components:NSMinuteCalendarUnit | NSHourCalendarUnit fromDate:[self.pill.whoRemindFor.hours objectAtIndex:j]];
                        
                        [fireComponents setHour:[timeComponents hour]];
                        [fireComponents setMinute:[timeComponents minute]];
                        
                        [endDateComponents setHour:[timeComponents hour]];
                        [endDateComponents setMinute:[timeComponents minute]];
                        
                        notificationFireDate = [calendar dateFromComponents:fireComponents];
                        notificationEndDate = [calendar dateFromComponents:endDateComponents];
                        
                        localNotification = [self setLocalNotification:localNotification withFireDate:notificationFireDate andEndDate:notificationEndDate];
                        
                        localNotification.repeatInterval = NSWeekCalendarUnit;
                        localNotification.repeatCalendar = calendar;
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    }
                }
            }
        
        } else if (self.pill.whoRemindFor.periodicity != nil) {
            
            
        }
        
        
        /*
         NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
         NSTimeZone *UTC = [NSTimeZone defaultTimeZone]; //timeZoneWithName:@"UTC"];
         
         NSDateComponents *startComponents = [gregorian components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
         [startComponents setTimeZone:UTC];
         [startComponents setDay:29];
         [startComponents setMonth:5];
         [startComponents setYear:2012];
         
         NSDate *start = [gregorian dateFromComponents:startComponents];
         NSLog(@"DATUM start: %@", start);
         
         NSDateComponents *fireComponents = [gregorian components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:start];
         [fireComponents setTimeZone:UTC];
         [fireComponents setWeekday:2]; // Monday
         int weekdayOrdinal = 1;
         [fireComponents setWeekdayOrdinal:weekdayOrdinal];
         
         NSDate *fire = [gregorian dateFromComponents:fireComponents];
         
         while ([fire compare:start] == NSOrderedAscending) {
         weekdayOrdinal++;
         [fireComponents setWeekdayOrdinal:weekdayOrdinal];
         fire = [gregorian dateFromComponents:fireComponents];
         }
         NSLog(@"DATUM fire: %@", fire);
         */
        
        
        
        
        

        
        /*
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSDateComponents *dateComps = [[NSDateComponents alloc] init];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
        NSDateComponents *hours = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit | NSHourCalendarUnit fromDate:[self.pill.whoRemindFor.hours objectAtIndex:0]];
        
        [dateComps setDay:[components day]];
        [dateComps setMonth:[components month]];
        [dateComps setYear:[components year]];
        [dateComps setHour:[hours hour]];
        [dateComps setMinute:[hours minute]];
        NSDate *itemDate = [calendar dateFromComponents:dateComps];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = itemDate;
        localNotif.
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"Take pill(s)\nName: %@\nStrength: %@\nIntake: %d pill(s)", nil),
                                self.pill.name, self.pill.strength, [self.pill.per_dose integerValue]];
        localNotif.alertAction = NSLocalizedString(@"TAKE", nil);
        
        localNotif.soundName = [NSString stringWithFormat:@"%@.caf", self.pill.whoRemindFor.alarm_sound]; //UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1;
        
        //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
        //localNotif.userInfo = infoDict;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];*/
    }
}

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

#pragma mark -
#pragma mark Getters and setters

- (NSArray *)pillNotes
{
    if (_pillNotes == nil) {
        
        NSString *warnings = @"";
        if (self.pill.warnings != nil) warnings = self.pill.warnings;
        
        NSString *side_effects = @"";
        if (self.pill.side_effects != nil) side_effects = self.pill.side_effects;
        
        NSString *storage = @"";
        if (self.pill.storage != nil) storage = self.pill.storage;
        
        NSString *extra = @"";
        if (self.pill.extra != nil) extra = self.pill.extra;
        
        _pillNotes = [[NSArray alloc] initWithObjects:warnings, side_effects, storage, extra, nil];
    }
    return _pillNotes;
}


- (void)setPillNotes:(NSArray *)pillNotes
{
    _pillNotes = pillNotes;
}


- (IBAction)remindMeSwitched:(id)sender {
    UISwitch *rmSwitch = (UISwitch *) sender;
    
    if (rmSwitch.on && (self.pill.whoRemindFor.hours == nil || self.pill.whoRemindFor.hours.count == 0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please set Time of day"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.tableView reloadData];
    } else {
        self.pill.whoRemindFor.remind_me = rmSwitch.on;
    
        if (self.pill.whoRemindFor.remind_me == YES) {
            [self scheduleNotifications];
        }
    }
}

- (void)updateRightBarButtonItemState
{
    // Conditionally enable the right bar button item -- it should only be enabled if the pill is in a valid state for saving.
    self.navigationItem.rightBarButtonItem.enabled = [self.pill validateForUpdate:NULL];
}   


- (NSUInteger)calculateNumberOfNonNilProperties
{    
    // Calculate number of required rows in pill section
    NSUInteger numberOfNonNilProperties = 4;
    
    for (int i=0; i<4; i++) {
        if (![self.pillNotes objectAtIndex:i] || [[self.pillNotes objectAtIndex:i] isEqualToString:@""]) numberOfNonNilProperties--;
    }
    return numberOfNonNilProperties;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasInsertedAddNoteRow = NO;
    self.hasInsertedDeletePillSection = NO;
    
    if ([self class] == [PillDetailsViewController class]) {
        self.title = [NSString stringWithFormat:@"%@", self.pill.name];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    self.tableView.allowsSelection = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableArray *temp = [self.pillNotes mutableCopy];
    [temp replaceObjectAtIndex:0 withObject:self.pill.warnings];
    [temp replaceObjectAtIndex:1 withObject:self.pill.side_effects];
    [temp replaceObjectAtIndex:2 withObject:self.pill.storage];
    [temp replaceObjectAtIndex:3 withObject:self.pill.extra];
    self.pillNotes = [temp copy];
    
	// Update pill on return.
    [self.tableView reloadData];
    [self updateRightBarButtonItemState];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}


#pragma mark -
#pragma mark Editing state

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing == NO) {
        [self.detailsDelegate pillDetailsViewController:self didFinishWithSave:YES];
        NSLog(@"halo");
    }
    
    // Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];
    
    NSUInteger numberOfNonNilProperties = [self calculateNumberOfNonNilProperties];
    NSArray *pillPropertiesInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:numberOfNonNilProperties inSection:NOTES_SECTION]];
    
    NSIndexSet *deletePillSectionIndex = [[NSIndexSet alloc] initWithIndex:DELETE_PILL_SECTION];
    
    [self.tableView beginUpdates];
    NSIndexSet *notesSection = [[NSIndexSet alloc] initWithIndex:NOTES_SECTION];
    [self.tableView reloadSections:notesSection withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (self.editing) {
        [self setUpUndoManager];
        
        [self.tableView insertSections:deletePillSectionIndex withRowAnimation:UITableViewRowAnimationAutomatic];
        self.hasInsertedDeletePillSection = YES;
        
    } else {
        [self.tableView deleteSections:deletePillSectionIndex withRowAnimation:UITableViewRowAnimationAutomatic];
        self.hasInsertedDeletePillSection = NO;
    }
    
    if (self.editing && numberOfNonNilProperties < 4) {
        [self.tableView insertRowsAtIndexPaths:pillPropertiesInsertIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];    
        self.hasInsertedAddNoteRow = YES;
        
    } else if (numberOfNonNilProperties < 4){
        [self.tableView deleteRowsAtIndexPaths:pillPropertiesInsertIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView endUpdates];
    
    if (!self.editing) {
        [self cleanUpUndoManager];
    }
}

#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.hasInsertedDeletePillSection) return 6;
    else return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    switch (section) {
        case PILL_SECTION:
            rows = 2;
            break;
        case DOSAGE_SECTION:
            rows = 1;
            break;
        case NOTES_SECTION:
            rows = [self calculateNumberOfNonNilProperties];
            if (self.hasInsertedAddNoteRow && self.editing && rows < 4)
                rows++;
            break;
        case REMINDER_SECTION:
            rows = 6;
            break;
        case REMIND_ME_SECTION:
            rows = 1;
            break;
        case DELETE_PILL_SECTION:
            rows = 1;
            break;
		default:
            break;
    }
    return rows;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section) {
        case PILL_SECTION:
            title = @"Pill";
            break;
        case DOSAGE_SECTION:
            title = @"Dosage";
            break;
        case NOTES_SECTION:
            title = @"Notes";
            break;
        case REMINDER_SECTION:
            title = @"Reminder";
            break;
        default:
            break;
    }
    return title;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footer = @"";
    
    if (!self.editing && section == NOTES_SECTION) {
        footer = @"To add more notes, touch the Edit button in the upper right corner.";
    }
    
    return footer;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        return indexPath;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfNonNilProperties = [self calculateNumberOfNonNilProperties];
    
    if ((self.editing && indexPath.section == PILL_SECTION) || (self.editing && indexPath.section == DOSAGE_SECTION) ||
        (self.editing && indexPath.section == NOTES_SECTION && indexPath.row < numberOfNonNilProperties)) {
        
        NSLog(@"%@", [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text);
        [self performSegueWithIdentifier:@"EditPillData" sender:self];
        
    } else if (self.editing && indexPath.section == NOTES_SECTION) {
        [self performSegueWithIdentifier:@"AddPillNote" sender:self];
    
    } else if (self.editing && indexPath.section == REMINDER_SECTION && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"SetReminderFrequency" sender:self];
    
    } else if (self.editing && indexPath.section == REMINDER_SECTION && (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3)) {
        [self performSegueWithIdentifier:@"SetReminderDate" sender:self];
    
    } else if (self.editing && indexPath.section == REMINDER_SECTION && indexPath.row == 4) {
        [self performSegueWithIdentifier:@"SetReminderType" sender:self];
    
    } else if (self.editing && indexPath.section == REMINDER_SECTION && indexPath.row == 5) {
        [self performSegueWithIdentifier:@"SetReminderSound" sender:self];
        
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSUInteger numberOfNonNilProperties = [self calculateNumberOfNonNilProperties];
    static NSString *PillDetailsCellIdentifier = @"Details Cell";
    static NSString *DosageNotesReminderCellIdentifier = @"DosageNotesReminder Cell";
    
    if (indexPath.section == PILL_SECTION) {
        cell = [tableView dequeueReusableCellWithIdentifier:PillDetailsCellIdentifier];
        
        if (cell == nil) {
            // Create a cell to display pill property.
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PillDetailsCellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.pill.name;
            
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Strength";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.pill.strength];
        }
    
    } else if (indexPath.section == DOSAGE_SECTION) {
        cell = [tableView dequeueReusableCellWithIdentifier:DosageNotesReminderCellIdentifier];
        
        if (cell == nil) {
            // Create a cell to display pill property.
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DosageNotesReminderCellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.text = @"Pills per intake";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.pill.per_dose integerValue]];
    
    } else if (indexPath.section == NOTES_SECTION) {
        
        if (indexPath.row < numberOfNonNilProperties) {
            cell = [tableView dequeueReusableCellWithIdentifier:DosageNotesReminderCellIdentifier];
            
            if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DosageNotesReminderCellIdentifier];
			}
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            int j=-1, i=0;
            while (j != indexPath.row) {
                if ([[self.pillNotes objectAtIndex:i] length] > 0) {
                    j++; i++;
                
                } else { i++; }
            }
            i--;
            
            if (i == 0) {
                cell.textLabel.text = @"Warnings";
                cell.detailTextLabel.text = self.pill.warnings;
                
            } else if (i == 1) {
                cell.textLabel.text = @"Side effects";
                cell.detailTextLabel.text = self.pill.side_effects;
                
            } else if (i == 2) {
                cell.textLabel.text = @"Storage";
                cell.detailTextLabel.text = self.pill.storage;
                
            } else if (i == 3) {
                cell.textLabel.text = @"Extra";
                cell.detailTextLabel.text = self.pill.extra;
            }
            
        } else {
            // If the row is outside the range, it's the row that was added to allow insertion (see tableView:numberOfRowsInSection:) so give it an appropriate label.
			static NSString *AddPillPropertyCellIdentifier = @"Add Pill Property Cell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:AddPillPropertyCellIdentifier];
			if (cell == nil) {
                // Create a cell to display "Add note".
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddPillPropertyCellIdentifier];
			}
        }
    
    } else if (indexPath.section == REMINDER_SECTION) {
        cell = [tableView dequeueReusableCellWithIdentifier:DosageNotesReminderCellIdentifier];
        
        if (cell == nil) {
            // Create a cell to display pill property.
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DosageNotesReminderCellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Frequency";
            
            if (self.pill.whoRemindFor.frequency != nil) {
                switch ([self.pill.whoRemindFor.frequency integerValue]) {
                    case 0:
                        cell.detailTextLabel.text = @"Once";
                        break;
                    case 1:
                        cell.detailTextLabel.text = @"Daily";
                        break;
                    case 2:
                        cell.detailTextLabel.text = @"Weekly";
                        break;
                    case 3:
                        cell.detailTextLabel.text = @"Monthly";
                        break;
                }
            
            } else if (self.pill.whoRemindFor.weekdays != nil) {
                NSString *weekdaysString = @"";
                for (int i=0; i<7; i++) {
                    if ([[self.pill.whoRemindFor.weekdays objectAtIndex:i] isEqualToNumber:[NSNumber numberWithInt:i]]) {
                        switch (i) {
                            case 0:
                                weekdaysString = [weekdaysString stringByAppendingString:@"Mon/"];
                                break;
                            case 1:
                                weekdaysString = [weekdaysString stringByAppendingString:@"Tue/"];
                                break;
                            case 2:
                                weekdaysString = [weekdaysString stringByAppendingString:@"Wed/"];
                                break;
                            case 3:
                                weekdaysString = [weekdaysString stringByAppendingString:@"Thu/"];
                                break;
                            case 4:
                                weekdaysString = [weekdaysString stringByAppendingString:@"Fri/"];
                                break;
                            case 5:
                                weekdaysString = [weekdaysString stringByAppendingString:@"Sat/"];
                                break;
                            case 6:
                                weekdaysString = [weekdaysString stringByAppendingString:@"Sun/"];
                                break;
                        }
                    }
                }
                cell.detailTextLabel.text = weekdaysString;
            
            } else if (self.pill.whoRemindFor.special_monthday != nil) {
                NSString *monthdayString = @"";
                monthdayString = [monthdayString stringByAppendingFormat:@"%@ ", [self.pill.whoRemindFor.special_monthday objectAtIndex:0]];
                monthdayString = [monthdayString stringByAppendingString:[self.pill.whoRemindFor.special_monthday objectAtIndex:1]];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Every %@", monthdayString];
            
            } else if (self.pill.whoRemindFor.interval != nil) {
                // TODO
            
            } else if (self.pill.whoRemindFor.periodicity != nil) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d days ON, %d days OFF", [[self.pill.whoRemindFor.periodicity objectAtIndex:0] integerValue], [[self.pill.whoRemindFor.periodicity objectAtIndex:1] integerValue]];
                
            } else cell.detailTextLabel.text = @"- please set -";
            
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Start date";
            if (!self.pill.whoRemindFor.start_date) {
                cell.detailTextLabel.text = @"- please set -";
            } else {
                cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.pill.whoRemindFor.start_date];
            }
        
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"End date";
            if (!self.pill.whoRemindFor.end_date) {
                cell.detailTextLabel.text = @"- set or leave empty -";
            } else {
                cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.pill.whoRemindFor.end_date];
            }
            
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Time of Day";
            if (!self.pill.whoRemindFor.hours) {
                self.pill.whoRemindFor.hours = [[NSArray alloc] init];
                cell.detailTextLabel.text = @"- please set -";
            
            } else if ([self.pill.whoRemindFor.hours count] == 0) {
                cell.detailTextLabel.text = @"- please set -";
            
            } else {
                NSString *reminderHours = [[NSString alloc] init];
                for (NSDate *date in self.pill.whoRemindFor.hours) {
                    reminderHours = [reminderHours stringByAppendingString:[self.timeFormatter stringFromDate:date]];
                    reminderHours = [reminderHours stringByAppendingString:@", "];
                }
                cell.detailTextLabel.text = reminderHours;
            }
        
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"Reminder Type";
            if (self.pill.whoRemindFor.reminder_type == nil) {
                cell.detailTextLabel.text = @"- please set -";
                
            } else {
                if ([self.pill.whoRemindFor.reminder_type integerValue] == 0) {
                    cell.detailTextLabel.text = @"Text";
                } else cell.detailTextLabel.text = @"Text + Sound";
            }
            
        } else if (indexPath.row == 5) {
            cell.textLabel.text = @"Sound";
            if (self.pill.whoRemindFor.alarm_sound == nil) {
                cell.detailTextLabel.text = @"- please set -";
            
            } else {
                cell.detailTextLabel.text = [self.pill.whoRemindFor.alarm_sound capitalizedString];
            }
        }
        
    
    } else if (indexPath.section == REMIND_ME_SECTION) {
        RemindMeCell *remindMeCell = [tableView dequeueReusableCellWithIdentifier:@"Remind Me Cell"];
        
        if (remindMeCell == nil) {
            // Create a cell to display pill property.
            remindMeCell = [[RemindMeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Remind Me Cell"];
            remindMeCell.accessoryType = UITableViewCellAccessoryNone;
        }
        remindMeCell.remindMeSwitch.on = self.pill.whoRemindFor.remind_me;
        remindMeCell.remindMeSwitch.onTintColor = [UIColor colorWithRed:(43./255.) green:(78./255.) blue:(105./255.) alpha:1.0];
        return remindMeCell;
    
    } else if (indexPath.section == DELETE_PILL_SECTION) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Delete Pill Cell"];
        
        if (cell == nil) {
            // Create a cell to display pill property.
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Delete Pill Cell"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        UIButton *sampleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sampleButton setFrame:[cell.contentView frame]];
        [sampleButton setTitle:@"Delete Pill" forState:UIControlStateNormal];
        [sampleButton setFrame:CGRectMake(10, 0, cell.bounds.size.width-20, 44)];
        [sampleButton setBackgroundImage:[UIImage imageNamed:@"redButton.png"] forState:UIControlStateNormal];
        [cell addSubview:sampleButton];
    }
    
    if ([cell.detailTextLabel.text isEqualToString:@"- please set -"] || [cell.detailTextLabel.text isEqualToString:@"- set or leave empty -"]) {
        [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
        
    } else { [cell.detailTextLabel setTextColor:[UIColor blackColor]]; }
    
    return cell;
}


#pragma mark -
#pragma mark Editing rows

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    
    if (indexPath.section == NOTES_SECTION) {
        if (indexPath.row == [self calculateNumberOfNonNilProperties]) {
            style = UITableViewCellEditingStyleInsert;
        
        } else {
            style = UITableViewCellEditingStyleDelete;
        }
    }
    return style;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    // Only allow deletion, and only in the NOTES_SECTION
    if ((editingStyle == UITableViewCellEditingStyleDelete) && (indexPath.section == NOTES_SECTION)) {
         UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        // Set the action name for the undo operation.
        NSUndoManager * undoManager = [[self.pill managedObjectContext] undoManager];
        [undoManager setActionName:@"Deleting Pill Note"];
        
        NSMutableArray *temp = [self.pillNotes mutableCopy];
        
        // Pass current value to the edited object
        if ([cell.textLabel.text isEqualToString:@"Warnings"]) {
            [temp replaceObjectAtIndex:0 withObject:@""];
            [self.pill setValue:@"" forKey:@"warnings"];
            
        } else if ([cell.textLabel.text isEqualToString:@"Side effects"]) {
            [temp replaceObjectAtIndex:1 withObject:@""];
            [self.pill setValue:@"" forKey:@"side_effects"];
            
        } else if ([cell.textLabel.text isEqualToString:@"Storage"]) {
            [temp replaceObjectAtIndex:2 withObject:@""];
            [self.pill setValue:@"" forKey:@"storage"];
            
        } else if ([cell.textLabel.text isEqualToString:@"Extra"]) {
            [temp replaceObjectAtIndex:3 withObject:@""];
            [self.pill setValue:@"" forKey:@"extra"];
            
        }
    
        self.pillNotes = [temp copy];
        
        NSUInteger numberOfNonNilProperties = [self calculateNumberOfNonNilProperties];
        NSArray *pillPropertiesInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:numberOfNonNilProperties inSection:NOTES_SECTION]];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (numberOfNonNilProperties < 4 && ([self.tableView numberOfRowsInSection:NOTES_SECTION]-1) == numberOfNonNilProperties) {
            [self.tableView insertRowsAtIndexPaths:pillPropertiesInsertIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates];
        
        // Saving deletion and possible insertion changes
        NSLog(@"SAVING!");
        /*NSError *error;
        if (![self.pill.managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }*/
    }
}


#pragma mark -
#pragma mark Undo support

- (void)setUpUndoManager
{
    //If the pill's managed object context doesn't already have an undo manager, then create one and set it for the context and self.
    //The view controller needs to keep a reference to the undo manager it creates so that it can determine whether to remove the undo manager when editing finishes.
    if (self.pill.managedObjectContext.undoManager == nil) {
        
        NSUndoManager *anUndoManager = [[NSUndoManager alloc] init];
        [anUndoManager setLevelsOfUndo:3];
        self.undoManager = anUndoManager;
        self.pill.managedObjectContext.undoManager = self.undoManager;
    }
    // Register as an observer of the pill's context's undo manager.
    NSUndoManager *pillUndoManager = self.pill.managedObjectContext.undoManager;
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:pillUndoManager];
    [dnc addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:pillUndoManager];
}


- (void)cleanUpUndoManager
{
    // Remove self as an observer.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.pill.managedObjectContext.undoManager == self.undoManager) {
        self.pill.managedObjectContext.undoManager = nil;
        self.undoManager = nil;
    }        
}


- (NSUndoManager *)undoManager
{
    return self.pill.managedObjectContext.undoManager;
}


- (void)undoManagerDidUndo:(NSNotification *)notification
{
    [self updateRightBarButtonItemState];
}


- (void)undoManagerDidRedo:(NSNotification *)notification
{
    [self updateRightBarButtonItemState];
}


/*
 The view controller must be first responder in order to be able to receive shake events for undo. It should resign first responder status when it disappears.
 */
- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark -
#pragma mark Segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if ([[segue identifier] isEqualToString:@"EditPillData"]) {
        
        PillEditingViewController *pillEditingViewController = (PillEditingViewController *)[segue destinationViewController];
        pillEditingViewController.editedPill = self.pill;
        
        if (indexPath.section == PILL_SECTION) {
            switch (indexPath.row) {
                case 0: {
                    pillEditingViewController.editedFieldKey = @"name";
                    pillEditingViewController.editedFieldName = NSLocalizedString(@"Name", @"display name for name");
                } break;
                case 1: {
                    pillEditingViewController.editedFieldKey = @"strength";
                    pillEditingViewController.editedFieldName = NSLocalizedString(@"Strength", @"display name for amount");
                } break;
            } 
        
        } else if (indexPath.section == DOSAGE_SECTION) {
            pillEditingViewController.editedFieldKey = @"per_dose";
            pillEditingViewController.editedFieldName = NSLocalizedString(@"Dosage", @"display name for per_dose");

        } else if (indexPath.section == NOTES_SECTION) {
            if ([[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Warnings"]) {
                pillEditingViewController.editedFieldKey = @"warnings";
                pillEditingViewController.editedFieldName = NSLocalizedString(@"Warnings", @"display name for name"); 
            
            } else if ([[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Side effects"]) {
                pillEditingViewController.editedFieldKey = @"side_effects";
                pillEditingViewController.editedFieldName = NSLocalizedString(@"Side effects", @"display name for side effects");
                
            } else if ([[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Storage"]) {
                pillEditingViewController.editedFieldKey = @"storage";
                pillEditingViewController.editedFieldName = NSLocalizedString(@"Storage", @"display name for storage");
                
            } else if ([[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Extra"]) {
                pillEditingViewController.editedFieldKey = @"extra";
                pillEditingViewController.editedFieldName = NSLocalizedString(@"Extra", @"display name for extra");
                
            } else { }
        }  
    
    } else if ([[segue identifier] isEqualToString:@"AddPillNote"]) {
        PillNotesList *pillNotesList = (PillNotesList *)[segue destinationViewController];
        pillNotesList.pillNotes = self.pillNotes;
        pillNotesList.editedPill = self.pill;
    
    } else if ([[segue identifier] isEqualToString:@"SetReminderFrequency"]) {
        ReminderFrequencyViewController *reminderFrequencyViewController = (ReminderFrequencyViewController *)[segue destinationViewController];
        reminderFrequencyViewController.reminder = self.pill.whoRemindFor;
    
    } else if ([[segue identifier] isEqualToString:@"SetReminderDate"]) {
        ReminderDateViewController *reminderDateViewController = (ReminderDateViewController *)[segue destinationViewController];
        reminderDateViewController.reminder = self.pill.whoRemindFor;
        
        if (indexPath.row == 1) {
            reminderDateViewController.editedFieldKey = @"start_date";  
            reminderDateViewController.editedFieldName = NSLocalizedString(@"Start date", @"display name for start date");
        
        } else if (indexPath.row == 2) {
            reminderDateViewController.editedFieldKey = @"end_date";  
            reminderDateViewController.editedFieldName = NSLocalizedString(@"End date", @"display name for end date");
            
        } else if (indexPath.row == 3) {
            reminderDateViewController.editedFieldKey = @"hours";
            reminderDateViewController.editedFieldName = NSLocalizedString(@"Hours", @"display name for hours");
            
        } else { }
    
    } else if ([[segue identifier] isEqualToString:@"SetReminderType"]) {
        ReminderTypeViewController *reminderTypeViewController = (ReminderTypeViewController *)[segue destinationViewController];
        reminderTypeViewController.reminder = self.pill.whoRemindFor;
        reminderTypeViewController.editedFieldKey = @"reminder_type";  
        reminderTypeViewController.editedFieldName = NSLocalizedString(@"Reminder type", @"display name for reminder type");
    
    } else if ([[segue identifier] isEqualToString:@"SetReminderSound"]) {
        ReminderSoundViewController *reminderSoundViewController = (ReminderSoundViewController *)[segue destinationViewController];
        reminderSoundViewController.reminder = self.pill.whoRemindFor;
        reminderSoundViewController.editedFieldKey = @"alarm_sound";  
        reminderSoundViewController.editedFieldName = NSLocalizedString(@"Alarm sound", @"display name for alarm sound");
        
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end

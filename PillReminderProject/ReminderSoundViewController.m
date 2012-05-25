//
//  ReminderSoundViewController.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/16/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "ReminderSoundViewController.h"

@interface ReminderSoundViewController ()
@property (nonatomic, strong) NSArray *sounds;
@property (nonatomic) SystemSoundID sound;
@property (nonatomic) NSInteger selectedCell;
@property (nonatomic) BOOL isSoundPlaying;
@end

@implementation ReminderSoundViewController

@synthesize reminder = _reminder;
@synthesize editedFieldName = _editedFieldName;
@synthesize editedFieldKey = _editedFieldKey;
@synthesize sounds = _sounds;
@synthesize sound = _sound;
@synthesize selectedCell = _selectedCell;
@synthesize isSoundPlaying = _isSoundPlaying;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i=0; i<self.sounds.count; i++) {
        if ([[self.sounds objectAtIndex:i] isEqualToString:self.reminder.alarm_sound]) {
            
            self.selectedCell = i;
            NSIndexPath *row = [NSIndexPath indexPathForRow:self.selectedCell inSection:0];
            [self.tableView selectRowAtIndexPath:row animated:NO scrollPosition:UITableViewScrollPositionNone];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:row];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self stopSound];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopSound];
}

- (NSArray *)sounds {
    if (_sounds == nil) _sounds = [[NSArray alloc] initWithObjects:@"reminding", @"morning", nil];
    return _sounds;
}

- (void)setSounds:(NSArray *)sounds {
    _sounds = sounds;
}

- (void)stopSound {
    if (self.sound) {
        self.isSoundPlaying = NO;
        AudioServicesDisposeSystemSoundID(self.sound);
    }
}


- (void)createAndPlaySound:(NSString *)soundName {
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:soundName 
                                                        ofType:@"caf"];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)[NSURL fileURLWithPath:soundPath],&sound);
    self.sound = sound;
    self.isSoundPlaying = YES;
    AudioServicesPlayAlertSound(self.sound);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sounds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Reminder Sound Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[self.sounds objectAtIndex:indexPath.row] capitalizedString];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger newIndex = self.selectedCell;
    if (newIndex == indexPath.row) {
        if (self.isSoundPlaying) {
            [self stopSound];
        
        } else [self createAndPlaySound:[self.sounds objectAtIndex:indexPath.row]];
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedCell = indexPath.row;
        [self stopSound];
        [self createAndPlaySound:[self.sounds objectAtIndex:indexPath.row]];
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.reminder.alarm_sound = [self.sounds objectAtIndex:indexPath.row];
}

@end

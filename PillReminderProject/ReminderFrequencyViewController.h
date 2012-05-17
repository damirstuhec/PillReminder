//
//  ReminderFrequencyViewController.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/17/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"
#import "WeekdaysViewController.h"
#import "SpecialRemindersViewController.h"


@interface ReminderFrequencyViewController : UITableViewController <WeekdaysViewControllerDelegate>

@property (nonatomic, strong) Reminder *reminder;
@property (nonatomic, strong) NSArray *weekdays;

@end
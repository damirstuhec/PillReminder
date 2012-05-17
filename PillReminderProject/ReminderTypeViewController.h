//
//  ReminderTypeViewController.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/16/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"

@interface ReminderTypeViewController : UITableViewController

@property (nonatomic, strong) Reminder *reminder;
@property (nonatomic, strong) NSString *editedFieldKey;
@property (nonatomic, strong) NSString *editedFieldName;

@end

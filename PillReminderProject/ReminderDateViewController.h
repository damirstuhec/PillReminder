//
//  ReminderDateViewController.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/11/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"

@interface ReminderDateViewController : UIViewController

@property (nonatomic, strong) Reminder *reminder;

@property (nonatomic, strong) NSString *editedFieldKey;
@property (nonatomic, strong) NSString *editedFieldName;

- (IBAction)datePickerValueChanged:(id)sender;

@end

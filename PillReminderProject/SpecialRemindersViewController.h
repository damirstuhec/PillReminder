//
//  SpecialRemindersViewController.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/17/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SpecialRemindersViewControllerDelegate;


@interface SpecialRemindersViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) id <SpecialRemindersViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *monthday;
@property (nonatomic, strong) NSArray *interval;
@property (nonatomic, strong) NSArray *periodicity;

@property (nonatomic, strong) NSString *editedFieldKey;
@property (nonatomic, strong) NSString *editedFieldName;

@end


@protocol SpecialRemindersViewControllerDelegate

- (void)specialRemindersViewControllerDelegate:(SpecialRemindersViewController *)controller 
                    didFinishSelectingMonthday:(NSArray *)monthday;

- (void)specialRemindersViewControllerDelegate:(SpecialRemindersViewController *)controller 
                    didFinishSelectingInterval:(NSArray *)interval;

- (void)specialRemindersViewControllerDelegate:(SpecialRemindersViewController *)controller 
                 didFinishSelectingPeriodicity:(NSArray *)periodicity;

@end
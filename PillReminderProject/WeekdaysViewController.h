//
//  WeekdaysViewController.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/17/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WeekdaysViewControllerDelegate;

@interface WeekdaysViewController : UITableViewController
@property (nonatomic, strong) NSArray *weekdays;

@property (nonatomic, weak) id <WeekdaysViewControllerDelegate> delegate;
@end

@protocol WeekdaysViewControllerDelegate
- (void)weekdaysViewController:(WeekdaysViewController *)controller didFinishSelectingWeekdays:(NSArray *)weekdays;
@end
//
//  Reminder+Create.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/12/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "Reminder.h"

@interface Reminder (Create)

+ (Reminder *)reminderWithStartDate:(NSDate *)startDate
                            endDate:(NSDate *)endDate
                           interval:(NSArray *)interval
                           weekdays:(NSArray *)weekdays
                          frequency:(NSNumber *)frequency 
                        periodicity:(NSArray *)periodicity
                    specialMonthday:(NSArray *)specialMonthday
                              hours:(NSArray *)hours 
                         alarmSound:(NSString *)alarmSound 
                       reminderType:(NSNumber *)reminderType
                      notifications:(NSArray *)notifications
                           remindMe:(BOOL)remindMe
             inManagedObjectContext:(NSManagedObjectContext *)context;

@end
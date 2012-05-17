//
//  Reminder+Create.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/12/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "Reminder+Create.h"

@implementation Reminder (Create)

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
                           remindMe:(BOOL)remindMe
             inManagedObjectContext:(NSManagedObjectContext *)context
{
    Reminder *reminder = nil;
    
    reminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminder"
                                             inManagedObjectContext:context];
    reminder.start_date = startDate;
    reminder.end_date = endDate;
    reminder.interval = interval;
    reminder.weekdays = weekdays;
    reminder.frequency = frequency;
    reminder.periodicity = periodicity;
    reminder.special_monthday = specialMonthday;
    reminder.hours = hours;
    reminder.alarm_sound = alarmSound;
    reminder.reminder_type = reminderType;
    reminder.remind_me = remindMe;
        
    return reminder;
}

@end

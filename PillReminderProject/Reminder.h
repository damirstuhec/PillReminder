//
//  Reminder.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/17/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pill;

@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSString *alarm_sound;
@property (nonatomic, retain) NSDate *end_date;
@property (nonatomic, retain) NSArray *hours;
@property (nonatomic, retain) NSArray *interval;
@property (nonatomic, retain) NSNumber *frequency;
@property (nonatomic, retain) NSArray *periodicity;
@property (nonatomic) BOOL remind_me;
@property (nonatomic, retain) NSNumber *reminder_type;
@property (nonatomic, retain) NSDate *start_date;
@property (nonatomic, retain) NSArray *weekdays;
@property (nonatomic, retain) NSArray *special_monthday;
@property (nonatomic, retain) NSSet *pills;
@end

@interface Reminder (CoreDataGeneratedAccessors)

- (void)addPillsObject:(Pill *)value;
- (void)removePillsObject:(Pill *)value;
- (void)addPills:(NSSet *)values;
- (void)removePills:(NSSet *)values;

@end

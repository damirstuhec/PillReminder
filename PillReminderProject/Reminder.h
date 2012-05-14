//
//  Reminder.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/14/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pill;

@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSString * alarm_sound;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSMutableOrderedSet *hours;
@property (nonatomic, retain) NSString * interval;
@property (nonatomic, retain) NSNumber * periodicity;
@property (nonatomic, retain) NSString * periodicity_special;
@property (nonatomic, retain) NSNumber * remind_me;
@property (nonatomic, retain) NSNumber * reminder_type;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSString * weekdays;
@property (nonatomic, retain) NSSet *pills;
@end

@interface Reminder (CoreDataGeneratedAccessors)

- (void)addPillsObject:(Pill *)value;
- (void)removePillsObject:(Pill *)value;
- (void)addPills:(NSSet *)values;
- (void)removePills:(NSSet *)values;

@end

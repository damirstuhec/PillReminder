//
//  Reminder.h
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pill;

@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSString * hours;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * interval;
@property (nonatomic, retain) NSNumber * periodicity;
@property (nonatomic, retain) NSString * periodicity_special;
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

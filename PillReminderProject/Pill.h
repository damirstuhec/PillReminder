//
//  Pill.h
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Reminder;

@interface Pill : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * extra;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * reminder;
@property (nonatomic, retain) NSString * side_effects;
@property (nonatomic, retain) NSString * storage;
@property (nonatomic, retain) NSString * warnings;
@property (nonatomic, retain) Reminder *whoRemindFor;

@end

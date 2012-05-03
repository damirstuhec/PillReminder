//
//  Pill+Create.h
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "Pill.h"
#import "Reminder.h"

@interface Pill (Create)

+ (Pill *)pillWithName:(NSString *)name
              strength:(NSString *)strength
               perDose:(NSNumber *)perDose 
              warnings:(NSString *)warnings 
           sideEffects:(NSString *)sideEffects 
               storage:(NSString *)storage 
                 extra:(NSString *)extra 
              reminder:(NSNumber *)reminder 
          whoRemindFor:(Reminder *)whoRemindFor
inManagedObjectContext:(NSManagedObjectContext *)context;
                                                
@end

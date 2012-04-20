//
//  Pill+Create.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "Pill+Create.h"
//#import "Reminder+Create.h"

@implementation Pill (Create)

+ (Pill *)pillWithName:(NSString *)name 
                amount:(NSNumber *)amount 
              warnings:(NSString *)warnings 
           sideEffects:(NSString *)sideEffects 
               storage:(NSString *)storage 
                 extra:(NSString *)extra 
              reminder:(NSNumber *)reminder 
          whoRemindFor:(Reminder *)whoRemindFor
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Pill *pill = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pill"];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"amount = %d", amount];
    NSArray *arrayOfPredicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:arrayOfPredicates];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *pills = [context executeFetchRequest:request error:&error];

    if (!pills || ([pills count] > 1)) {
        // error
        NSLog(@"Error");
        
    } else if (![pills count]) {
        
        NSLog(@"Kreiranje nove tablete");
        
        pill = [NSEntityDescription insertNewObjectForEntityForName:@"Pill"
                                                     inManagedObjectContext:context];
        pill.name = name;
        pill.amount = amount;
        pill.warnings = warnings;
        pill.side_effects = sideEffects;
        pill.storage = storage;
        pill.extra = extra;
        pill.reminder = reminder;
        pill.whoRemindFor = nil;    //[Reminder reminderWithPeriodicity ...

    } else {
        
        NSLog(@"Error - tableta ze obstaja");
        
        pill = [pills lastObject];
    }
    
    return pill;
}

@end

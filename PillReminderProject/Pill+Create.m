//
//  Pill+Create.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "Pill+Create.h"
#import "Reminder+Create.h"

@implementation Pill (Create)


+ (BOOL)isTherePillWithName:(NSString *)name 
                   strength:(NSString *)strength
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pill"];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"strength = %@", strength];
    NSArray *arrayOfPredicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:arrayOfPredicates];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *pills = [context executeFetchRequest:request error:&error];
    
    if ([pills count] == 1) {
        
        return YES;
    
    } else return NO;
}

+ (Pill *)pillWithName:(NSString *)name 
              strength:(NSString *)strength
              perDose:(NSNumber *)perDose 
              warnings:(NSString *)warnings 
           sideEffects:(NSString *)sideEffects 
               storage:(NSString *)storage 
                 extra:(NSString *)extra 
              reminder:(NSNumber *)reminder
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Pill *pill = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pill"];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"strength = %@", strength];
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
        pill.strength = strength;
        pill.per_dose = perDose;
        pill.warnings = warnings;
        pill.side_effects = sideEffects;
        pill.storage = storage;
        pill.extra = extra;
        pill.reminder = reminder;
        pill.whoRemindFor = [Reminder reminderWithStartDate:nil endDate:nil interval:nil weekdays:nil periodicity:nil periodicitySpecial:nil hours:nil alarmSound:nil reminderType:nil remindMe:0 inManagedObjectContext:context];

    } else {
        
        NSLog(@"Error - tableta ze obstaja");
        
        pill = [pills lastObject];
    }
    NSLog(@"%@", pill.objectID);
    
    return pill;
}

@end

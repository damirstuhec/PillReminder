//
//  History+Create.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 6/1/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "History+Create.h"

@implementation History (Create)

+ (void)historyWithPillName:(NSString *)pillName
                   strength:(NSString *)pillStrength
                    andDate:(NSString *)date
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    History *history = nil;
    history = [NSEntityDescription insertNewObjectForEntityForName:@"History"
                                         inManagedObjectContext:context];
    history.pillName = pillName;
    history.pillStrength = pillStrength;
    history.date = date;
}

@end

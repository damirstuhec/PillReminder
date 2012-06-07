//
//  History+Create.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 6/1/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "History.h"

@interface History (Create)

+ (void)historyWithPillName:(NSString *)pillName
                   strength:(NSString *)pillStrength
                    andDate:(NSString *)date
     inManagedObjectContext:(NSManagedObjectContext *)context;

@end

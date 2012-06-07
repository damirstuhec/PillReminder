//
//  History.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 6/1/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface History : NSManagedObject

@property (nonatomic, retain) NSString * pillName;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * pillStrength;

@end

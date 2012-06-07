//
//  PRAppDelegate.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 4/5/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PRAppDelegate.h"
#import "History+Create.h"

@implementation PRAppDelegate

@synthesize window = _window;
@synthesize historyDocument = _historyDocument;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)stop:(UILocalNotification *)notification ifLastDate:(NSDate *)lastDate
{
    NSLog(@"LOGGING fireDate: %@", notification.fireDate);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSTimeInterval day = 24*60*60;
    NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval:day];
    NSDate *expiryDate = lastDate;
    
	NSDateComponents *tomorrowDateComponents = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:tomorrow];
    [tomorrowDateComponents setTimeZone:[NSTimeZone defaultTimeZone]];
    
    NSDateComponents *expiryTimeComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:expiryDate];
    [expiryTimeComponents setTimeZone:[NSTimeZone defaultTimeZone]];
    
    [tomorrowDateComponents setHour:[expiryTimeComponents hour]];
    [tomorrowDateComponents setMinute:[expiryTimeComponents minute]];
    [tomorrowDateComponents setSecond:[expiryTimeComponents second]];
    
    NSDate *tomorrowDate = [calendar dateFromComponents:tomorrowDateComponents];
    
    //NSLog(@"Tomorrow: %@  -  Expiry: %@", tomorrowDate, expiryDate);
    
    if ([tomorrowDate compare:expiryDate] == NSOrderedDescending) {
        NSLog(@"Canceling notification");
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfoDictionary = notification.userInfo;
    NSString *pillName = [userInfoDictionary valueForKey:@"pill.name"];
    NSString *pillStrength = [userInfoDictionary valueForKey:@"pill.strength"];
    NSString *pillsPerDose = [userInfoDictionary valueForKey:@"pill.per_dose"];
    NSDate *pillEndDate = [userInfoDictionary valueForKey:@"pill.end_date"];
    
    if (application.applicationState == UIApplicationStateActive)
    {
        // NSLog(@"Application is active");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" 
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"- Take pill(s) -\nName: %@\nStrength: %@\nIntake: %@ pill(s)", nil), pillName, pillStrength, pillsPerDose]
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
        [alert show];
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd. MM. yyyy"];
    
    [History historyWithPillName:pillName strength:pillStrength andDate:[dateFormat stringFromDate:[NSDate date]] inManagedObjectContext:self.historyDocument.managedObjectContext];
    
    [self stop:notification ifLastDate:pillEndDate];
}

/*
- (void)initializeiCloudAccess {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] != nil)
            NSLog(@"iCloud is available\n");
        else
            NSLog(@"This tutorial requires iCloud, but it is not available.\n");
    });
}
*/

@end

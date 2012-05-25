//
//  PRAppDelegate.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 4/5/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)initializeiCloudAccess;
- (void)stop:(UILocalNotification *)notification ifLastDate:(NSDate *)lastDate;
@end

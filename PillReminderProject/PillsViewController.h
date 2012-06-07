//
//  PillsViewController.h
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "PillAddingViewController.h"

// implement this protocol if you want PillsViewController to be able to segue to you
@protocol PillsViewControllerSegue <NSObject>
@property (nonatomic, strong) UIManagedDocument *document;
@end

@interface PillsViewController : CoreDataTableViewController <UIAlertViewDelegate>
//@property (nonatomic, strong) UIManagedDocument *pillReminderDatabase;     // Model is a Core Data database of pills
@end
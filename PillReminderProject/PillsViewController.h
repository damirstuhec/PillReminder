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

@interface PillsViewController : CoreDataTableViewController <PillAddingViewControllerDelegate, PillDetailsViewControllerDelegate>

@property (nonatomic, strong) UIManagedDocument *pillReminderDatabase;     // Model is a Core Data database of pills

@end
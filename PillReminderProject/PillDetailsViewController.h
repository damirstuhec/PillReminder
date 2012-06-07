//
//  PillDetailsViewController.h
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pill.h"
#import "CoreDataTableViewController.h"

@interface PillDetailsViewController : CoreDataTableViewController <UIAlertViewDelegate>
@property (nonatomic, strong) Pill *pill;
@property (nonatomic, strong) UIManagedDocument *pillDatabase;
- (IBAction)remindMeSwitched:(id)sender;
@end

@interface PillDetailsViewController (Private)

- (void)setUpUndoManager;
- (void)cleanUpUndoManager;

@end
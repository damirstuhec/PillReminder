//
//  PillDetailsViewController.h
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pill.h"

@protocol PillDetailsViewControllerDelegate;

@interface PillDetailsViewController : UITableViewController <UIAlertViewDelegate>
@property (nonatomic, strong) Pill* pill;
- (IBAction)remindMeSwitched:(id)sender;

@property (nonatomic, weak) id <PillDetailsViewControllerDelegate> detailsDelegate;
@end

@interface PillDetailsViewController (Private)

- (void)setUpUndoManager;
- (void)cleanUpUndoManager;

@end

@protocol PillDetailsViewControllerDelegate
- (void)pillDetailsViewController:(PillDetailsViewController *)controller didFinishWithSave:(BOOL)save;
@end
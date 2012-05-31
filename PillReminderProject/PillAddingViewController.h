//
//  PillAddingViewController.h
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PillDetailsViewController.h"

@protocol PillAddingViewControllerDelegate;

@interface PillAddingViewController : PillDetailsViewController <UIAlertViewDelegate>

@property (nonatomic, weak) id <PillAddingViewControllerDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@protocol PillAddingViewControllerDelegate
- (void)pillAddingViewController:(PillAddingViewController *)controller didFinishWithSave:(BOOL)save;
@end
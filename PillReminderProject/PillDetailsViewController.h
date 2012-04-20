//
//  PillDetailsViewController.h
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pill.h"

@interface PillDetailsViewController : UITableViewController

@property (nonatomic, strong) Pill* pill;

@end

@interface PillDetailsViewController (Private)

- (void)setUpUndoManager;
- (void)cleanUpUndoManager;

@end
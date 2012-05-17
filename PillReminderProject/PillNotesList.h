//
//  PillNotesList.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 4/28/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pill.h"

@interface PillNotesList : UITableViewController

@property (nonatomic, strong) Pill *editedPill;
@property (nonatomic, strong) NSArray *pillNotes;

@end
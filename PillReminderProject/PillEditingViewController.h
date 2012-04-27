//
//  PillEditingViewController.h
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pill.h"

@interface PillEditingViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) Pill *editedPill;
@property (nonatomic, strong) NSString *editedFieldKey;
@property (nonatomic, strong) NSString *editedFieldName;

@end

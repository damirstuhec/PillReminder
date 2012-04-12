//
//  PillSaver.h
//  PillReminderProject
//
//  Created by Damir Stuhec on 4/12/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PillSaver : UIViewController

@property (nonatomic, strong) UIManagedDocument *pillDatabase;

@property (weak, nonatomic) IBOutlet UITextField *pillNameFld;

- (IBAction)savePill:(id)sender;

@end

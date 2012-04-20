//
//  PillAddingViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillAddingViewController.h"
#import "Pill.h"

@interface PillAddingViewController ()

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


@implementation PillAddingViewController

@synthesize delegate=_delegate, managedObjectContext=_managedObjectContext;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    // Set up the undo manager and set editing state to YES.
    [self setUpUndoManager];
    self.editing = YES;
}


- (void)viewDidUnload
{    
    [super viewDidUnload];
    [self cleanUpUndoManager];    
}


#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)cancel:(id)sender
{
    [self.delegate pillAddingViewController:self didFinishWithSave:NO];
}


- (IBAction)save:(id)sender
{    
    [self.delegate pillAddingViewController:self didFinishWithSave:YES];
}


@end

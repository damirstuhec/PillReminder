//
//  PillAddingViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillAddingViewController.h"
#import "Pill+Create.h"

@interface PillAddingViewController ()

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


@implementation PillAddingViewController

@synthesize delegate=_delegate, managedObjectContext=_managedObjectContext, parentManagedObjectContext = _parentManagedObjectContext;


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
    NSSet *set = self.managedObjectContext.insertedObjects;
    Pill *newPill = [set anyObject];

    if ([Pill isTherePillWithName:newPill.name strength:newPill.strength inManagedObjectContext:self.parentManagedObjectContext]) {
        NSLog(@"Tableta obstaja");
        // open a dialog with just an OK button
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pill with given name and strength already exists.\nPlease choose different values."
                                                                 delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
        
    } else {
         NSLog(@"Tableta ne obstaja");
        [self.delegate pillAddingViewController:self didFinishWithSave:YES];
    }
}

@end

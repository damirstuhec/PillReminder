//
//  PillAddingViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillAddingViewController.h"
#import "Pill+Create.h"
#import "PillsViewController.h"

@interface PillAddingViewController()

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


@implementation PillAddingViewController

@synthesize delegate=_delegate, managedObjectContext=_managedObjectContext;

- (NSURL *)iCloudURL
{
    return [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
}

- (NSURL *)iCloudDocumentsURL
{
    return [[self iCloudURL] URLByAppendingPathComponent:@"Documents"];
}

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
    [self.delegate pillAddingViewController:self didSave:NO withDocument:nil];
}


- (IBAction)save:(id)sender
{
    NSURL *url = [[self iCloudDocumentsURL] URLByAppendingPathComponent:self.pill.name];
    [[NSFileManager defaultManager] moveItemAtURL:self.pillDatabase.fileURL toURL:url error:nil];
     
    if ([self.pill.name isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter Pill Name"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    
    } else [self.delegate pillAddingViewController:self didSave:YES withDocument:self.pillDatabase];
}

@end

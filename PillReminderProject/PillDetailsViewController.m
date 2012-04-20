//
//  PillDetailsViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillDetailsViewController.h"
#import "PillEditingViewController.h"

@interface PillDetailsViewController()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *warningsLabel;
@property (nonatomic, weak) IBOutlet UILabel *reminderLabel;

@property (nonatomic, strong) NSUndoManager *undoManager;

- (void)updateInterface;
- (void)updateRightBarButtonItemState;

@end


@implementation PillDetailsViewController

@synthesize pill = _pill;
@synthesize nameLabel = _nameLabel, amountLabel = _amountLabel, warningsLabel = _warningsLabel, reminderLabel = _reminderLabel, undoManager = _undoManager;



- (void)updateInterface {
    NSLog(@"Update interface, Pill name: %@", self.pill.name);
    
    self.nameLabel.text = self.pill.name;
    self.amountLabel.text = [NSString stringWithFormat:@"%d mg", [self.pill.amount integerValue]];
    if (!self.pill.warnings) self.warningsLabel.text = @"Not set"; else self.warningsLabel.text = self.pill.warnings;
    
    if (!self.pill.reminder || self.pill.reminder == 0) self.reminderLabel.text = @"NO"; else self.reminderLabel.text = @"YES";
}

- (void)updateRightBarButtonItemState
{
    // Conditionally enable the right bar button item -- it should only be enabled if the pill is in a valid state for saving.
    self.navigationItem.rightBarButtonItem.enabled = [self.pill validateForUpdate:NULL];
}   


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self class] == [PillDetailsViewController class]) {
        self.title = [NSString stringWithFormat:@"%@ [%d]", self.pill.name, [self.pill.amount integerValue]];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    self.tableView.allowsSelection = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Redisplay the data.    
    [self updateInterface];    
    //[self updateRightBarButtonItemState];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    // Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];
    
    /*
     When editing starts, create and set an undo manager to track edits. Then register as an observer of undo manager change notifications, so that if an undo or redo operation is performed, the table view can be reloaded.
     When editing ends, de-register from the notification center and remove the undo manager, and save the changes.
     */
    if (editing) {
        [self setUpUndoManager];
    }
    else {
        [self cleanUpUndoManager];
        // Save the changes.
        NSError *error;
        if (![self.pill.managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark -
#pragma mark Table view data source methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Only allow selection if editing.
    if (self.editing) {
        return indexPath;
    }
    return nil;
}


/*
 Manage row selection: If a row is selected, create a new editing view controller to edit the property associated with the selected row.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        [self performSegueWithIdentifier:@"EditPillData" sender:self];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark -
#pragma mark Undo support

- (void)setUpUndoManager
{
    /*
     If the book's managed object context doesn't already have an undo manager, then create one and set it for the context and self.
     The view controller needs to keep a reference to the undo manager it creates so that it can determine whether to remove the undo manager when editing finishes.
     */
    if (self.pill.managedObjectContext.undoManager == nil) {
        
        NSUndoManager *anUndoManager = [[NSUndoManager alloc] init];
        [anUndoManager setLevelsOfUndo:3];
        self.undoManager = anUndoManager;
        
        self.pill.managedObjectContext.undoManager = self.undoManager;
    }
    
    // Register as an observer of the book's context's undo manager.
    NSUndoManager *pillUndoManager = self.pill.managedObjectContext.undoManager;
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:pillUndoManager];
    [dnc addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:pillUndoManager];
}


- (void)cleanUpUndoManager
{
    // Remove self as an observer.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.pill.managedObjectContext.undoManager == self.undoManager) {
        self.pill.managedObjectContext.undoManager = nil;
        self.undoManager = nil;
    }        
}


- (NSUndoManager *)undoManager
{
    return self.pill.managedObjectContext.undoManager;
}


- (void)undoManagerDidUndo:(NSNotification *)notification {
    
    // Redisplay the data.    
    [self updateInterface];
    [self updateRightBarButtonItemState];
}


- (void)undoManagerDidRedo:(NSNotification *)notification {
    
    // Redisplay the data.    
    [self updateInterface];
    [self updateRightBarButtonItemState];
}


/*
 The view controller must be first responder in order to be able to receive shake events for undo. It should resign first responder status when it disappears.
 */
- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditPillData"]) {
        
        PillEditingViewController *pillEditingViewController = (PillEditingViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        pillEditingViewController.editedPill = self.pill;
        switch (indexPath.row) {
            case 0: {
                pillEditingViewController.editedFieldKey = @"name";
                pillEditingViewController.editedFieldName = NSLocalizedString(@"Name", @"display name for name");
            } break;
            case 1: {
                pillEditingViewController.editedFieldKey = @"amount";
                pillEditingViewController.editedFieldName = NSLocalizedString(@"Amount", @"display name for amount");
            } break;
            case 2: {
                pillEditingViewController.editedFieldKey = @"warnings";
                pillEditingViewController.editedFieldName = NSLocalizedString(@"Warnings", @"display name for warnings");
            } break;
        }    
    }
}

@end

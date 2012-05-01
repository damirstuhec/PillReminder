//
//  PillDetailsViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillDetailsViewController.h"
#import "PillEditingViewController.h"
#import "PillNotesList.h"

@interface PillDetailsViewController()

@property (nonatomic, strong) NSUndoManager *undoManager;
@property (nonatomic, strong) NSArray *pillNotes;

- (void)updateRightBarButtonItemState;

@end


@implementation PillDetailsViewController

#define PILL_SECTION 0
#define NOTES_SECTION 1
#define REMINDER_SECTION 2

@synthesize pill = _pill, undoManager = _undoManager, pillNotes = _pillNotes;


- (NSArray *)pillNotes {

    if (_pillNotes == nil) {
        
        NSString *warnings = @"";
        if (self.pill.warnings != nil) warnings = self.pill.warnings;
        
        NSString *side_effects = @"";
        if (self.pill.side_effects != nil) side_effects = self.pill.side_effects;
        
        NSString *storage = @"";
        if (self.pill.storage != nil) storage = self.pill.storage;
        
        NSString *extra = @"";
        if (self.pill.extra != nil) extra = self.pill.extra;
        
        _pillNotes = [[NSArray alloc] initWithObjects:warnings, side_effects, storage, extra, nil];
    }
    
    return _pillNotes;
}

- (void)setPillNotes:(NSArray *)pillNotes {
    _pillNotes = pillNotes;
}


- (void)updateRightBarButtonItemState
{
    // Conditionally enable the right bar button item -- it should only be enabled if the pill is in a valid state for saving.
    self.navigationItem.rightBarButtonItem.enabled = [self.pill validateForUpdate:NULL];
}   

- (NSUInteger)calculateNumberOfNonNilProperties {
    
    // Calculate number of required rows in pill section
    NSUInteger numberOfNonNilProperties = 4;
    
    for (int i=0; i<4; i++)
    {
        if (![self.pillNotes objectAtIndex:i] || [[self.pillNotes objectAtIndex:i] isEqualToString:@""]) numberOfNonNilProperties--;
    }
    
    return numberOfNonNilProperties;
}

#pragma mark -
#pragma mark View lifecycle

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
    
    NSMutableArray *temp = [self.pillNotes mutableCopy];
    [temp replaceObjectAtIndex:0 withObject:self.pill.warnings];
    [temp replaceObjectAtIndex:1 withObject:self.pill.side_effects];
    [temp replaceObjectAtIndex:2 withObject:self.pill.storage];
    [temp replaceObjectAtIndex:3 withObject:self.pill.extra];
    
    self.pillNotes = [temp copy];
    
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Editing

- (void)addPillNoteAddButton {
    [self.tableView beginUpdates];
    
    NSUInteger numberOfNonNilProperties = [self calculateNumberOfNonNilProperties];
    NSArray *pillPropertiesInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:numberOfNonNilProperties inSection:NOTES_SECTION]];
    
    [self setUpUndoManager];
    if (self.editing && numberOfNonNilProperties < 4) {
        [self.tableView insertRowsAtIndexPaths:pillPropertiesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];    
        
    } else if (numberOfNonNilProperties < 4){
        [self.tableView deleteRowsAtIndexPaths:pillPropertiesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self.tableView endUpdates];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    // Hide the back button when editing starts, and show it again when editing finishes.
    [self.navigationItem setHidesBackButton:editing animated:animated];
    
    [self addPillNoteAddButton];
    
    if (!self.editing) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    
    switch (section) {
        case PILL_SECTION:
            title = @"Pill";
            break;
        case NOTES_SECTION:
            title = @"Notes";
            break;
        default:
            break;
    }
    
    return title;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (!self.editing && section == NOTES_SECTION) {
        return @"To add more notes tap the Edit button in the upper right corner.";
    
    } else { return @""; }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;

    switch (section) {
        case PILL_SECTION:
            rows = 2;
            break;
        case NOTES_SECTION:
            rows = [self calculateNumberOfNonNilProperties];
            if (self.editing && rows < 4) rows++;
            //NSLog(@"rows: %d", rows);
            break;
		default:
            break;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // For the Ingredients section, if necessary create a new cell and configure it with an additional label for the amount.
    // Give the cell a different identifier from that used for cells in other sections so that it can be dequeued separately.
    
    NSUInteger numberOfNonNilProperties = [self calculateNumberOfNonNilProperties];
    
    if (indexPath.section == PILL_SECTION) {
        static NSString *PillDetailsCellIdentifier = @"Details Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:PillDetailsCellIdentifier];
        
        if (cell == nil) {
            // Create a cell to display pill property.
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PillDetailsCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.pill.name;
            
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Amount";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d mg", [self.pill.amount integerValue]];
            
        }
    
    } else if (indexPath.section == NOTES_SECTION) {
        
        if (indexPath.row < numberOfNonNilProperties) {
            
            static NSString *PillDetailsCellIdentifier = @"Details Cell";
            cell = [tableView dequeueReusableCellWithIdentifier:PillDetailsCellIdentifier];
            
            if (cell == nil) {
                // Create a cell to display pill property.
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PillDetailsCellIdentifier];
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
            
            int j=-1, i=0;
            
            while (j!=indexPath.row)
            {
                if ([[self.pillNotes objectAtIndex:i] length] > 0) { j++; i++;
                } else { i++; }
            }
            i--;
            
            if (i == 0) {
                cell.textLabel.text = @"Warnings";
                cell.detailTextLabel.text = self.pill.warnings;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            } else if (i == 1) {
                cell.textLabel.text = @"Side effects";
                cell.detailTextLabel.text = self.pill.side_effects;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            } else if (i == 2) {
                cell.textLabel.text = @"Storage";
                cell.detailTextLabel.text = self.pill.storage;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            } else if (i == 3) {
                cell.textLabel.text = @"Extra";
                cell.detailTextLabel.text = self.pill.extra;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            if ([cell.detailTextLabel.text isEqualToString:@"Empty .."]) {
                [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
                
            } else { [cell.detailTextLabel setTextColor:[UIColor blackColor]]; }
            
        } else {
            // If the row is outside the range, it's the row that was added to allow insertion (see tableView:numberOfRowsInSection:) so give it an appropriate label.
			static NSString *AddPillPropertyCellIdentifier = @"Add Pill Property Cell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:AddPillPropertyCellIdentifier];
			if (cell == nil) {
                // Create a cell to display "Add Ingredient".
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddPillPropertyCellIdentifier];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            cell.textLabel.text = @"Add note";
            cell.detailTextLabel.text = @"Choose";
        }
    } /*else {
        // If necessary create a new cell and configure it appropriately for the section.  Give the cell a different identifier from that used for cells in the Ingredients section so that it can be dequeued separately.
        static NSString *MyIdentifier = @"GenericCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        NSString *text = nil;
        
        switch (indexPath.section) {
            case TYPE_SECTION: // type -- should be selectable -> checkbox
                text = [recipe.type valueForKey:@"name"];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case INSTRUCTIONS_SECTION: // instructions
                text = @"Instructions";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.editingAccessoryType = UITableViewCellAccessoryNone;
                break;
            default:
                break;
        }
        
        cell.textLabel.text = text;
    }*/

    return cell;
}


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
    NSUInteger numberOfNonNilProperties = [self calculateNumberOfNonNilProperties];
    
    if ((self.editing && indexPath.section == PILL_SECTION) || (self.editing && indexPath.section == NOTES_SECTION && indexPath.row < numberOfNonNilProperties)) {
        [self performSegueWithIdentifier:@"EditPillData" sender:self];
    
    } else if (self.editing && indexPath.section == NOTES_SECTION) {
        [self performSegueWithIdentifier:@"AddPillNote" sender:self];
    }
}


#pragma mark -
#pragma mark Editing rows

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    NSUInteger numberOfNonNilProperties = [self calculateNumberOfNonNilProperties];
    
    // Only allow editing in the ingredients section.
    // In the ingredients section, the last row (row number equal to the count of ingredients) is added automatically (see tableView:cellForRowAtIndexPath:) to provide an insertion cell, so configure that cell for insertion; the other cells are configured for deletion.
    if (indexPath.section == NOTES_SECTION) {
        // If this is the last item, it's the insertion row.
        if (indexPath.row == numberOfNonNilProperties) {
            style = UITableViewCellEditingStyleInsert;
        
        }else {
            style = UITableViewCellEditingStyleDelete;
        }
        
    }
    
    return style;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Only allow deletion, and only in the NOTES_SECTION
    if ((editingStyle == UITableViewCellEditingStyleDelete) && (indexPath.section == NOTES_SECTION)) {
        
         UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        // Set the action name for the undo operation.
        NSUndoManager * undoManager = [[self.pill managedObjectContext] undoManager];
        [undoManager setActionName:@"Deleting Pill Note"];
        
        NSMutableArray *temp = [self.pillNotes mutableCopy];
        
        // Pass current value to the edited object
        if ([cell.textLabel.text isEqualToString:@"Warnings"]) {
            [temp replaceObjectAtIndex:0 withObject:@""];
            [self.pill setValue:@"" forKey:@"warnings"];
            
        } else if ([cell.textLabel.text isEqualToString:@"Side effects"]) {
            [temp replaceObjectAtIndex:1 withObject:@""];
            [self.pill setValue:@"" forKey:@"side_effects"];
            
        } else if ([cell.textLabel.text isEqualToString:@"Storage"]) {
            [temp replaceObjectAtIndex:2 withObject:@""];
            [self.pill setValue:@"" forKey:@"storage"];
            
        } else if ([cell.textLabel.text isEqualToString:@"Extra"]) {
            [temp replaceObjectAtIndex:3 withObject:@""];
            [self.pill setValue:@"" forKey:@"extra"];
            
        }
    
        self.pillNotes = [temp copy];
        
        NSUInteger numberOfNonNilProperties = [self calculateNumberOfNonNilProperties];
        NSArray *pillPropertiesInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:numberOfNonNilProperties inSection:NOTES_SECTION]];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        if (numberOfNonNilProperties < 4 && ([self.tableView numberOfRowsInSection:NOTES_SECTION]-1) == numberOfNonNilProperties)
        {
            [self.tableView insertRowsAtIndexPaths:pillPropertiesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
        }
        [self.tableView endUpdates];
        
        NSError *error;
        if (![self.pill.managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
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
    [self updateRightBarButtonItemState];
}


- (void)undoManagerDidRedo:(NSNotification *)notification {
    // Redisplay the data.    
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


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditPillData"]) {
        
        PillEditingViewController *pillEditingViewController = (PillEditingViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        pillEditingViewController.editedPill = self.pill;
        
        if (indexPath.section == PILL_SECTION) {
            switch (indexPath.row) {
                case 0: {
                    pillEditingViewController.editedFieldKey = @"name";
                    pillEditingViewController.editedFieldName = NSLocalizedString(@"Name", @"display name for name");
                } break;
                case 1: {
                    pillEditingViewController.editedFieldKey = @"amount";
                    pillEditingViewController.editedFieldName = NSLocalizedString(@"Amount", @"display name for amount");
                } break;
            } 
        
        } else if (indexPath.section == NOTES_SECTION) {
            switch (indexPath.row) {
                case 0: {
                    pillEditingViewController.editedFieldKey = @"warnings";
                    pillEditingViewController.editedFieldName = NSLocalizedString(@"Warnings", @"display name for name");
                } break;
                case 1: {
                    pillEditingViewController.editedFieldKey = @"side_effects";
                    pillEditingViewController.editedFieldName = NSLocalizedString(@"Side effects", @"display name for side effects");
                } break;
                case 2: {
                    pillEditingViewController.editedFieldKey = @"storage";
                    pillEditingViewController.editedFieldName = NSLocalizedString(@"Storage", @"display name for storage");
                } break;
                case 3: {
                    pillEditingViewController.editedFieldKey = @"extra";
                    pillEditingViewController.editedFieldName = NSLocalizedString(@"Extra", @"display name for extra");
                } break;
            } 
        }  
    
    } else if ([[segue identifier] isEqualToString:@"AddPillNote"]) {
        
        PillNotesList *pillNotesList = (PillNotesList *)[segue destinationViewController];
        pillNotesList.pillNotes = self.pillNotes;
        pillNotesList.editedPill = self.pill;
    }
}

@end

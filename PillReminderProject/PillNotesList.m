//
//  PillNotesList.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 4/28/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillNotesList.h"

@interface PillNotesList()

@property (nonatomic) NSInteger *numberOfSelectedNotes;

@end


@implementation PillNotesList

@synthesize editedPill = _editedPill, pillNotes = _pillNotes, numberOfSelectedNotes = _numberOfSelectedNotes;

- (NSArray *)pillNotes {
    if (_pillNotes == nil) _pillNotes = [[NSArray alloc] init];
    return _pillNotes;
}

- (void)setPillNotes:(NSArray *)pillNotes {
    _pillNotes = pillNotes;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Available Notes";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (NSInteger)calculateNumberOfNilProperties {
    
    // Calculate number of required rows in pill section
    NSInteger numberOfNilProperties = 0;
    
    for (int i=0; i<4; i++)
    {
        if (![self.pillNotes objectAtIndex:i] || [[self.pillNotes objectAtIndex:i] isEqualToString:@""]) numberOfNilProperties++;
    }
    
    return numberOfNilProperties;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self calculateNumberOfNilProperties];
    self.numberOfSelectedNotes = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self calculateNumberOfNilProperties];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoteCell";
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    int j=-1, i=0;
    
    while (j!=indexPath.row)
    {
        if (![self.pillNotes objectAtIndex:i] || [[self.pillNotes objectAtIndex:i] isEqualToString:@""]) {
            j++; i++;
            
        } else { i++; }
    }
    i--;
    
    if (i == 0) {
        cell.textLabel.text = @"Warnings";
        
    } else if (i == 1) {
        cell.textLabel.text = @"Side effects";
        
    } else if (i == 2) {
        cell.textLabel.text = @"Storage";
        
    } else if (i == 3) {
        cell.textLabel.text = @"Extra";
    }
    
    return cell;
}

#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save:(id)sender
{
    NSUndoManager * undoManager = [[self.editedPill managedObjectContext] undoManager];
    [undoManager setActionName:@"Adding Pill Note"];
    
    UITableViewCell *cell = nil;
    NSIndexPath *indexPath = nil;

    for (int i=0; i<[self calculateNumberOfNilProperties]; i++)
    {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            if ([cell.textLabel.text isEqualToString:@"Warnings"]) {
                [self.editedPill setValue:@"Empty .." forKey:@"warnings"];
                
            } else if ([cell.textLabel.text isEqualToString:@"Side effects"]) {
                [self.editedPill setValue:@"Empty .." forKey:@"side_effects"];
                
            } else if ([cell.textLabel.text isEqualToString:@"Storage"]) {
                [self.editedPill setValue:@"Empty .." forKey:@"storage"];
                
            } else if ([cell.textLabel.text isEqualToString:@"Extra"]) {
                [self.editedPill setValue:@"Empty .." forKey:@"extra"];
                
            }
        }
    }
    
    /*
    NSError *error = nil;
	if (![[self.editedPill managedObjectContext] save:&error]) {
		
        Replace this implementation with code to handle the error appropriately.
		 
        abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
        */
		/*NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    */
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender
{
    // Don't pass current value to the edited object, just pop.
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"choosen note: %@", cell.textLabel.text);
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark; self.numberOfSelectedNotes++;
    } else { cell.accessoryType = UITableViewCellAccessoryNone; self.numberOfSelectedNotes--; }
    
    if (self.numberOfSelectedNotes > 0) {
        UIBarButtonItem *button = self.navigationItem.rightBarButtonItem;
        button.enabled = YES;
    
    } else {
        UIBarButtonItem *button = self.navigationItem.rightBarButtonItem;
        button.enabled = NO;
    }
}

@end

//
//  PillsViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillsViewController.h"
#import "Pill+Create.h"
#import "PillDetailsViewController.h"


@implementation PillsViewController

@synthesize pillReminderDatabase = _pillReminderDatabase;


// attaches an NSFetchRequest to this UITableViewController
- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pill"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" 
                                                                                     ascending:YES 
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate -> ALL pills
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.pillReminderDatabase.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


- (void)prepopulateDataIntoDocument:(UIManagedDocument *)document
{
    dispatch_queue_t fetchQ = dispatch_queue_create("Prepopulate pills data", NULL);
    dispatch_async(fetchQ, ^{
        [document.managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)

            [Pill pillWithName:@"Lekadol" strength:@"0 mg" perDose:[NSNumber numberWithInteger:0] warnings:@"" sideEffects:@"" storage:@"" extra:@"" reminder:[NSNumber numberWithInteger:0] whoRemindFor:nil inManagedObjectContext:document.managedObjectContext];
            
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
        }];
    });
    dispatch_release(fetchQ);
}


- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.pillReminderDatabase.fileURL path]]) {
        
        NSLog(@"Dokument ne obstaja");
        // does not exist on disk, so create it
        [self.pillReminderDatabase saveToURL:self.pillReminderDatabase.fileURL 
                            forSaveOperation:UIDocumentSaveForCreating 
                           completionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            [self prepopulateDataIntoDocument:self.pillReminderDatabase];
        }];
        
    } else if (self.pillReminderDatabase.documentState == UIDocumentStateClosed) {
        
        NSLog(@"Obstaja ampak je zaprt");
        // exists on disk, but we need to open it
        [self.pillReminderDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
        }];
        
    } else if (self.pillReminderDatabase.documentState == UIDocumentStateNormal) {
        
        NSLog(@"Obstaja in je odprt");
        // already open and ready to use
        [self setupFetchedResultsController];
    }
}


- (void)setPillReminderDatabase:(UIManagedDocument *)pillReminderDatabase
{
    if (_pillReminderDatabase != pillReminderDatabase) {
        _pillReminderDatabase = pillReminderDatabase;
        [self useDocument];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.pillReminderDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                             inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default PillReminder Database"];
        self.pillReminderDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Pill Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Pill *pill = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = pill.name;
    cell.detailTextLabel.text = pill.strength;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Pill *pill = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    /*
    if ([segue.destinationViewController respondsToSelector:@selector(setPill:)]) {
        [segue.destinationViewController performSelector:@selector(setPill:) withObject:pill];
    }
    */
    
    if ([[segue identifier] isEqualToString:@"AddPill"]) {
        
        /*
         The destination view controller for this segue is an AddViewController to manage addition of the book.
         This block a new managed object context as a child of the root view controller's context. It then creates a new book using the child context. This means that changes made to the book remain discrete from the application's managed object context until the book's context is saved.
         The root view controller sets itself as the delegate of the add controller so that it can be informed when the user has completed the add operation -- either saving or canceling (see addViewController:didFinishWithSave:).
         IMPORTANT: It's not necessary to use a second context for this. You could just use the existing context, which would simplify some of the code -- you wouldn't need to perform two saves, for example. This implementation, though, illustrates a pattern that may sometimes be useful (where you want to maintain a separate set of edits).
         */
        
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        PillAddingViewController *pillAddingViewController = (PillAddingViewController *)[navController topViewController];
        pillAddingViewController.delegate = self;
        
        // Create a new managed object context for the new book; set its parent to the fetched results controller's context.
        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [addingContext setParentContext:[self.fetchedResultsController managedObjectContext]];
        
        Pill *newPill = (Pill *)[NSEntityDescription insertNewObjectForEntityForName:@"Pill" inManagedObjectContext:addingContext];
        pillAddingViewController.pill = newPill;
        pillAddingViewController.managedObjectContext = addingContext;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowPillDetails"]) {
        
        // Pass the selected pill to the new details view controller.
        PillDetailsViewController *pillDetailsViewController = (PillDetailsViewController *)[segue destinationViewController];
        pillDetailsViewController.pill = pill;
    }  
}


#pragma mark - Add controller delegate

/*
 Add controller's delegate method; informs the delegate that the add operation has completed, and indicates whether the user saved the new pill.
 */
- (void)pillAddingViewController:(PillAddingViewController *)controller didFinishWithSave:(BOOL)save
{
    if (save) {
        /*
         The new book is associated with the add controller's managed object context.
         This means that any edits that are made don't affect the application's main managed object context -- it's a way of keeping disjoint edits in a separate scratchpad. Saving changes to that context, though, only push changes to the fetched results controller's context. To save the changes to the persistent store, you have to save the fetch results controller's context as well.
         */        
        NSError *error;
        NSManagedObjectContext *addingManagedObjectContext = [controller managedObjectContext];
        if (![addingManagedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    // Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
}

@end

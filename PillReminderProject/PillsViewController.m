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


@interface PillsViewController()
@property (nonatomic, strong) NSMetadataQuery *iCloudQuery;
@end

@implementation PillsViewController

@synthesize pillReminderDatabase = _pillReminderDatabase;
@synthesize iCloudQuery = _iCloudQuery;


#pragma mark - iCloud Query

- (NSMetadataQuery *)iCloudQuery
{
    if (!_iCloudQuery) {
        _iCloudQuery = [[NSMetadataQuery alloc] init];
        _iCloudQuery.searchScopes = [NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope];
        _iCloudQuery.predicate = [NSPredicate predicateWithFormat:@"%K like '*'", NSMetadataItemFSNameKey];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processCloudQueryResults:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:_iCloudQuery];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processCloudQueryResults:)
                                                     name:NSMetadataQueryDidUpdateNotification
                                                   object:_iCloudQuery];
    }
    return _iCloudQuery;
}

- (NSURL *)iCloudURL
{
    return [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
}

- (NSURL *)iCloudDocumentsURL
{
    return [[self iCloudURL] URLByAppendingPathComponent:@"Documents"];
}


- (NSURL *)filePackageURLForCloudURL:(NSURL *)url
{
    if ([[url path] hasPrefix:[[self iCloudDocumentsURL] path]]) {
        NSArray *iCloudDocumentsURLComponents = [[self iCloudDocumentsURL] pathComponents];
        NSArray *urlComponents = [url pathComponents];
        if ([iCloudDocumentsURLComponents count] < [urlComponents count]) {
            urlComponents = [urlComponents subarrayWithRange:NSMakeRange(0, [iCloudDocumentsURLComponents count]+1)];
            url = [NSURL fileURLWithPathComponents:urlComponents];
        }
    }
    return url;
}

- (void)logError:(NSError *)error inMethod:(SEL)method
{
    NSString *errorDescription = error.localizedDescription;
    if (!errorDescription) errorDescription = @"???";
    NSString *errorFailureReason = error.localizedFailureReason;
    if (!errorFailureReason) errorFailureReason = @"???";
    if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(method), errorDescription, errorFailureReason);
}


- (void)removeCloudURL:(NSURL *)url
{
    [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:[url lastPathComponent]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        NSError *coordinationError;
        [coordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForDeleting error:&coordinationError byAccessor:^(NSURL *newURL) {
            NSError *removeError;
            [[NSFileManager defaultManager] removeItemAtURL:newURL error:&removeError];
            [self logError:removeError inMethod:_cmd]; // _cmd means "this method" (it's a SEL)
            // should also remove log files in CoreData directory in the cloud!
            // i.e., delete the files in [self iCloudCoreDataLogFilesURL]/[url lastPathComponent]
        }];
        [self logError:coordinationError inMethod:_cmd];
    });
}

- (void)processCloudQueryResults:(NSNotification *)notification
{
    [self.iCloudQuery disableUpdates];
    int resultCount = [self.iCloudQuery resultCount];
    
    if (resultCount < 1 || resultCount > 1) {
        NSLog(@"Napaka: %d dokumentov", resultCount);
        for (int i=0; i<resultCount; i++) {
            NSMetadataItem *item = [self.iCloudQuery resultAtIndex:i];
            NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
            url = [self filePackageURLForCloudURL:url];
            
            [self removeCloudURL:url];
        }
    
    } else {
        NSLog(@"OK - 1 dokument");
        NSMetadataItem *item = [self.iCloudQuery resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey]; // this will be a file, not a directory
        url = [self filePackageURLForCloudURL:url];
        if (![url isEqual:self.pillReminderDatabase.fileURL]) {
            self.pillReminderDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
            [self setPersistentStoreOptionsInDocument:self.pillReminderDatabase];
        }
    }
    [self.iCloudQuery enableUpdates];
}

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

            [Pill pillWithName:@"Lekadol" strength:@"0 mg" perDose:[NSNumber numberWithInteger:1] warnings:@"" sideEffects:@"" storage:@"" extra:@"" inManagedObjectContext:document.managedObjectContext];
            
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
            //[self prepopulateDataIntoDocument:self.pillReminderDatabase];
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

// sprememba
- (void)setPillReminderDatabase:(UIManagedDocument *)pillReminderDatabase
{
    if (_pillReminderDatabase != pillReminderDatabase) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self  // remove observing of old document (if any)
                                                        name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                      object:_pillReminderDatabase.managedObjectContext.persistentStoreCoordinator];
        [[NSNotificationCenter defaultCenter] removeObserver:self  // remove observing of old document (if any)
                                                        name:UIDocumentStateChangedNotification
                                                      object:_pillReminderDatabase];
        
        
        _pillReminderDatabase = pillReminderDatabase;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(documentContentsChanged:)
                                                     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                   object:_pillReminderDatabase.managedObjectContext.persistentStoreCoordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(documentStateChanged:)
                                                     name:UIDocumentStateChangedNotification
                                                   object:_pillReminderDatabase];
        
        [self useDocument];
    }
}

// sprememba
- (void)documentContentsChanged:(NSNotification *)notification
{
    NSLog(@"halo1");
    [self.pillReminderDatabase.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

// sprememba
- (void)documentStateChanged:(NSNotification *)notification
{
    NSLog(@"halo2");
    if (self.pillReminderDatabase.documentState & UIDocumentStateInConflict) {
        // look at the changes in notification's userInfo and resolve conflicts
        //   or just take the latest version (by doing nothing)
        // in any case (even if you do nothing and take latest version),
        //   mark all old versions resolved ...
        NSArray *conflictingVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:self.pillReminderDatabase.fileURL];
        for (NSFileVersion *version in conflictingVersions) {
            version.resolved = YES;
        }
        // ... and remove the old version files in a separate thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            NSError *error;
            [coordinator coordinateWritingItemAtURL:self.pillReminderDatabase.fileURL options:NSFileCoordinatorWritingForDeleting error:&error byAccessor:^(NSURL *newURL) {
                [NSFileVersion removeOtherVersionsOfItemAtURL:self.pillReminderDatabase.fileURL error:NULL];
            }];
            if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription, error.localizedFailureReason);
        });
    } else if (self.pillReminderDatabase.documentState & UIDocumentStateSavingError) {
        NSLog(@"SAVING ERROR");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.pillReminderDatabase) {
        NSURL *url = [[self iCloudDocumentsURL] URLByAppendingPathComponent:@"Default PillReminder Database"];
        
        //NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                             //inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default PillReminder Database"];
        self.pillReminderDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
        [self setPersistentStoreOptionsInDocument:self.pillReminderDatabase];
    }
    
    [self.tableView reloadData];
    if (![self.iCloudQuery isStarted]) [self.iCloudQuery startQuery];
    [self.iCloudQuery enableUpdates];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.iCloudQuery disableUpdates];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the edit and add buttons.
    self.toolbarItems = [NSArray arrayWithObject:self.editButtonItem];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:.168f green:.305f blue:.411f alpha:1.0f];
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
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
    //if (editingStyle == UITableViewCellEditingStyleDelete) {
    if (!(self.pillReminderDatabase.documentState & UIDocumentStateEditingDisabled)) {
        Pill *pill = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:pill];
        
        NSLog(@"SAVING!");
        
        [self.pillReminderDatabase saveToURL:self.pillReminderDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];

    } else {
        // notify user that deletion is not currently possible? (probably not)
        // we probably also should return NO from canDeleteRowAtIndexPath: whenever editing is disabled
    }  
}

- (NSURL *)iCloudCoreDataLogFilesURL
{
    return [[self iCloudURL] URLByAppendingPathComponent:@"CoreData"];
}

- (void)setPersistentStoreOptionsInDocument:(UIManagedDocument *)document
{
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    
    [options setObject:[document.fileURL lastPathComponent] forKey:NSPersistentStoreUbiquitousContentNameKey];
    [options setObject:[self iCloudCoreDataLogFilesURL] forKey:NSPersistentStoreUbiquitousContentURLKey];
    
    document.persistentStoreOptions = options;
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
        //NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        //[addingContext setParentContext:[self.fetchedResultsController managedObjectContext]];
        
        Pill *newPill = [Pill pillWithName:@"" strength:@"0 mg" perDose:[NSNumber numberWithInteger:1] warnings:@"" sideEffects:@"" storage:@"" extra:@"" inManagedObjectContext:[self.fetchedResultsController managedObjectContext]];//addingContext];
    
        pillAddingViewController.pill = newPill;
        pillAddingViewController.managedObjectContext = [self.fetchedResultsController managedObjectContext]; //addingContext;
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
    NSLog(@"LOG: SAVING NEW: %d", save);
    if (save) {
        
        NSLog(@"SAVING!");
        
        [self.pillReminderDatabase saveToURL:self.pillReminderDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (!success) NSLog(@"Failed to save document %@", self.pillReminderDatabase.localizedName);
        }];
    }
    
    // Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
}

- (void)pillDetailsViewController:(PillDetailsViewController *)controller didFinishWithSave:(BOOL)save
{
    NSLog(@"LOG: SAVING: %d", save);
    if (save) {
        
        NSLog(@"SAVING!");
        
        [self.pillReminderDatabase saveToURL:self.pillReminderDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (!success) NSLog(@"Failed to save document %@", self.pillReminderDatabase.localizedName);
        }];
    }
    
    // Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  PillsViewController.m
//  PillReminder
//
//  Created by Damir Stuhec on 4/19/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillsViewController.h"
#import "PillDetailsViewController.h"
#import "AskerViewController.h"
#import "Pill+Create.h"


@interface PillsViewController() <AskerViewControllerDelegate>
@property (nonatomic, strong) NSArray *documents;
@property (nonatomic, strong) NSMetadataQuery *iCloudQuery;
@property (nonatomic, strong) Pill *pill;
@end

@implementation PillsViewController

@synthesize documents = _documents;
@synthesize iCloudQuery = _iCloudQuery;
@synthesize pill = _pill;
//@synthesize pillReminderDatabase = _pillReminderDatabase;   // odstrani kasneje





- (void)createDocumentWithURL:(NSURL *)url
{
    NSLog(@"Create new UIManagedDocument");
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        
        if (success) {
            /*NSLog(@"konec shranjevanja");
            
            Pill *newPill = [Pill pillWithName:[document.fileURL lastPathComponent] strength:@"0 mg" perDose:[NSNumber numberWithInteger:1] warnings:@"" sideEffects:@"" storage:@"" extra:@"" inManagedObjectContext:document.managedObjectContext];//addingContext];
            
            NSLog(@"ponovno shranim");
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
                if(!success) NSLog(@"failed to save document");
                if(success) NSLog(@"Success: save document");
            }];
            */
        } else {
            NSLog(@"failed to SAVE!");
        }
    }];
}

- (void)setDocuments:(NSArray *)documents
{
    documents = [documents sortedArrayUsingComparator:^NSComparisonResult(NSURL *url1, NSURL *url2) {
        return [[url1 lastPathComponent] caseInsensitiveCompare:[url2 lastPathComponent]];
    }];
    
    if (![_documents isEqualToArray:documents]) {
        _documents = documents;
        [self.tableView reloadData];
        NSLog(@"doc3-2: %d", [self.documents count]);
    }
    
    for (int i=0; i<_documents.count; i++) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[[_documents objectAtIndex:i] path]]) {
            [self createDocumentWithURL:[_documents objectAtIndex:i]];
        }
    }
    NSLog(@"doc3: %d", [self.documents count]);
}

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

- (void)processCloudQueryResults:(NSNotification *)notification
{
    [self.iCloudQuery disableUpdates];
    
    NSMutableArray *documents = [NSMutableArray array];
    int resultCount = [self.iCloudQuery resultCount];
    NSLog(@"LOG: resultCount = %d", resultCount);
    
    for (int i=0; i<resultCount; i++) {
        NSMetadataItem *item = [self.iCloudQuery resultAtIndex:i];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        url = [self filePackageURLForCloudURL:url];
        if (url && ![documents containsObject:url]) [documents addObject:url];
    }
    self.documents = documents;
    
    [self.iCloudQuery enableUpdates];
}

// attaches an NSFetchRequest to this UITableViewController
/*- (void)setupFetchedResultsController
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
*/

/*
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
*/

/*
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
*/

/*
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
*/
/*
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
*/
/*
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
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData]; // step 38: ugh!
    if (![self.iCloudQuery isStarted]) [self.iCloudQuery startQuery];
    [self.iCloudQuery enableUpdates];
    
    NSLog(@"doc1: %d", [self.documents count]);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.iCloudQuery disableUpdates];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the edit and add buttons.
    self.toolbarItems = [NSArray arrayWithObject:self.editButtonItem];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:.168f green:.305f blue:.411f alpha:1.0f];
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

#pragma mark - UITableViewDataSource

// 6. Implement UITableViewDataSource number of rows in section and cellForRowAtIndexPath: using Model
// Back to top for step 7.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"doc2: %d", [self.documents count]);
    return [self.documents count];
}

/*
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
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Pill Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSLog(@"cellforrow");
    // Configure the cell...
    NSURL *url = [self.documents objectAtIndex:indexPath.row];
    cell.textLabel.text = [url lastPathComponent];
    cell.detailTextLabel.text = nil;
    
    return cell;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSURL *url = [self.documents objectAtIndex:indexPath.row];
        NSMutableArray *documents = [self.documents mutableCopy];
        [documents removeObject:url];
        _documents = documents;  // Argh!
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self removeCloudURL:url];
    }   
}

/*
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
*/

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

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Pill *pill = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    //if ([segue.destinationViewController respondsToSelector:@selector(setPill:)]) {
    //    [segue.destinationViewController performSelector:@selector(setPill:) withObject:pill];
    //}
    
    if ([[segue identifier] isEqualToString:@"AddPill"]) {
        
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
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddPill"]) {
        AskerViewController *asker = (AskerViewController *)segue.destinationViewController;
        asker.delegate = self;
        asker.question = @"New pill name:";

    } else {
        NSIndexPath *indexPath = nil;
        if ([sender isKindOfClass:[NSIndexPath class]]) {
            indexPath = (NSIndexPath *)sender;
        } else if ([sender isKindOfClass:[UITableViewCell class]]) {
            indexPath = [self.tableView indexPathForCell:sender];
        } else if (!sender || (sender == self) || (sender == self.tableView)) {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        
        if (indexPath && [segue.identifier isEqualToString:@"ShowPillDetails"]) {
            if ([segue.destinationViewController conformsToProtocol:@protocol(PillsViewControllerSegue)]) {
                NSURL *url = [self.documents objectAtIndex:indexPath.row];
                [segue.destinationViewController setTitle:[url lastPathComponent]];
                UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
                [self setPersistentStoreOptionsInDocument:document]; // make cloud Core Data documents efficient!
                [segue.destinationViewController setDocument:document];
                
                //Pill *newPill = [Pill pillWithName:[document.fileURL lastPathComponent] strength:@"0 mg" perDose:[NSNumber numberWithInteger:1] warnings:@"" sideEffects:@"" storage:@"" extra:@"" inManagedObjectContext:document.managedObjectContext];//addingContext];
                
                //[segue.destinationViewController setPill:newPill];
                
                /*
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pill" inManagedObjectContext:document.managedObjectContext];
                [request setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", [document.fileURL lastPathComponent]];
                [request setPredicate:predicate];
                
                // Edit the sort key as appropriate.
                request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" 
                                                                                                 ascending:YES 
                                                                                                  selector:@selector(localizedCaseInsensitiveCompare:)]];
                
                NSError *error = nil;
                NSArray *result = [document.managedObjectContext executeFetchRequest:request error:&error];
                
                NSLog(@"RESULT COUNT: %d", [result count]);
                NSLog(@"self.pill.name: %@", [[result objectAtIndex:0] name]); */
            }
        }
    }
}

#pragma mark - Add controller delegate

- (void)askerViewController:(AskerViewController *)sender
             didAskQuestion:(NSString *)question
               andGotAnswer:(NSString *)answer
{
    NSURL *url = [[self iCloudDocumentsURL] URLByAppendingPathComponent:answer];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Pill with given name already exists.\nPlease set new name."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        NSMutableArray *documents = [self.documents mutableCopy];
        [documents addObject:url];
        self.documents = documents;
        int row = [self.documents indexOfObject:url];
        //UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:[self.documents objectAtIndex:row]];
        //[self setPersistentStoreOptionsInDocument:document]; // make cloud Core Data documents efficient!
        NSLog(@"segue");
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self performSegueWithIdentifier:@"ShowPillDetails" sender:indexPath];
        [self dismissModalViewControllerAnimated:YES];
    }
}

/*
 Add controller's delegate method; informs the delegate that the add operation has completed, and indicates whether the user saved the new pill.
 */

/*
- (void)pillAddingViewController:(PillAddingViewController *)controller didSave:(BOOL)save withDocument:(UIManagedDocument *)document
{
    if (save) {
        NSURL *url = document.fileURL;
    
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Pill with given name already exists.\nPlease set new name."
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            NSMutableArray *documents = [self.documents mutableCopy];
            [documents addObject:url];
            self.documents = documents;
        
            int row = [self.documents indexOfObject:url];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self performSegueWithIdentifier:@"Show Document" sender:indexPath];
            [self dismissModalViewControllerAnimated:YES];
        
            //[self.tableView reloadData];
            //NSLog(@"dodajam dokument. Skupno stevilo=%d", [self.documents count]);
        }
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}
*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

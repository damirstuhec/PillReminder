//
//  PillsTableViewController.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 4/5/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillsTableViewController.h"
#import "Pill.h"
#import "Reminder.h"

@implementation PillsTableViewController

-(void)setupFetchedResultsController
{
    // self.fetchedResultsController = ..
}

@synthesize pillDatabase = _pillDatabase;

-(void)populateTestPillsIntoDocument:(UIManagedDocument *)document
{
    /*
    dispatch_queue_t populateQ = dispatch_queue_create("Test pills populate", NULL);
    dispatch_async(populateQ, ^{
        [document.managedObjectContext performBlock:^{
            // populate testing pills
        }];
    });
    dispatch_release(populateQ);
    */
}

-(void)useDocument
{
    // sinhronizacijski dokument podatkovne baze še ne obstaja - kreacija sinhronizacijskega dokumenta
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.pillDatabase.fileURL path]])
    {
        [self.pillDatabase saveToURL:self.pillDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            [self setupFetchedResultsController];
            
            [self populateTestPillsIntoDocument:self.pillDatabase];
        }];
        
    // sinhronizacijski dokument podatkovne baze je zaprt
    }else if (self.pillDatabase.documentState == UIDocumentStateClosed)
    {
        [self.pillDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
        }];
        
    // sinhronizacijski dokument podatkovne baze je odprt in pripravljen za uporabo
    }else if (self.pillDatabase.documentState == UIDocumentStateNormal)
    {
        [self setupFetchedResultsController];
    }
}

-(void)setPillDatabase:(UIManagedDocument *)pillDatabase
{
    // lazy instantiation - varna inicializacija
    if (_pillDatabase != pillDatabase)
    {
        _pillDatabase = pillDatabase;
        [self useDocument];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.pillDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Pill Database"];
        self.pillDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Pill Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    return cell;
}

@end

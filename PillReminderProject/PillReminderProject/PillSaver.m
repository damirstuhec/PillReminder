//
//  PillSaver.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 4/12/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "PillSaver.h"
#import <CoreData/CoreData.h>

@implementation PillSaver


@synthesize pillDatabase = _pillDatabase;

@synthesize pillNameFld = _pillNameFld;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

-(void)useDocument
{
    // sinhronizacijski dokument podatkovne baze še ne obstaja - kreacija sinhronizacijskega dokumenta
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.pillDatabase.fileURL path]])
    {
        [self.pillDatabase saveToURL:self.pillDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
        }];
        
        // sinhronizacijski dokument podatkovne baze je zaprt
    }else if (self.pillDatabase.documentState == UIDocumentStateClosed)
    {
        [self.pillDatabase openWithCompletionHandler:^(BOOL success) {
        }];
        
        // sinhronizacijski dokument podatkovne baze je odprt in pripravljen za uporabo
    }else if (self.pillDatabase.documentState == UIDocumentStateNormal)
    {
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

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.pillDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Pill Database"];
        self.pillDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setPillNameFld:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)savePill:(id)sender {
    
    NSManagedObject *newName = [NSEntityDescription insertNewObjectForEntityForName:@"Pill" inManagedObjectContext:self.pillDatabase.managedObjectContext];
    [newName setValue:self.pillNameFld.text forKey:@"name"];
    _pillNameFld.text = @"";
    
    NSError *err;
    if (![self.pillDatabase.managedObjectContext save:&err]) {
        NSLog(@"An error has occured: %@", [err localizedDescription]);
    }
}
@end

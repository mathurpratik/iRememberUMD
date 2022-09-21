//
//  MyRecordsTableViewController.m
//  iRememberUMD
//
//  Created by Pratik Mathur on 3/23/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import "MyRecordsTableViewController.h"
#import "AppDelegate.h"

@implementation MyRecordsTableViewController
@synthesize databaseName,databasePath,database;
//@synthesize memoriesArray;
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
    //memoriesArray = nil;
    
    // PM: connect to database
    databaseName = @"mymemories.sqlite";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    [databasePath retain];
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    if(success){
        [self updateGlobalRecsArray ];
        return;
    }
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    [fileManager release];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) updateGlobalRecsArray {
    
    // PM: get shared instance of global records array
    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray * globalRecs = [myDelegate myRecordsGlobalArray];
    
    if ([globalRecs count] == 0) {
        [globalRecs release];
        globalRecs = nil;
        globalRecs = [[NSMutableArray alloc] init ];
        int rc = -1;
        rc = sqlite3_open([databasePath UTF8String], &database);
        if(rc == SQLITE_OK) {
            sqlite3_stmt *statement = nil;
            
            
            NSString *fullQuery = @"SELECT * FROM memories";
            
            const char *sql = [fullQuery UTF8String];
            
            if(sqlite3_prepare_v2(database, sql, -1, &statement, NULL)!=SQLITE_OK)
                NSAssert1(0, @"Error preparing statement '%s'", sqlite3_errmsg(database));
            else
            {
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *place= [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 4)];
                    //[User setName:[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)]];
                    //[User setAge:[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)]];
                    
                    [globalRecs addObject:place];
                    //[currentUser release];
                }
            }
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
    }
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewwillappear");
    [self updateGlobalRecsArray];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewdidappear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewwilldissapear");

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewdiddisappear");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    // PM: get shared instance of global records array
    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray * globalRecs = [myDelegate myRecordsGlobalArray];
    
    return [globalRecs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // PM: get shared instance of global records array
    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray * globalRecs = [myDelegate myRecordsGlobalArray];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *currentPlace = [globalRecs objectAtIndex:indexPath.row];
    [[cell textLabel] setText:currentPlace];

    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void) dealloc{
    // PM: database vars
    [databaseName release];
    [databasePath release];
    [super dealloc];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end

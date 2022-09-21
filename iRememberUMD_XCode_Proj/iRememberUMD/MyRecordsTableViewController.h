//
//  MyRecordsTableViewController.h
//  iRememberUMD
//
//  Created by Pratik Mathur on 3/23/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface MyRecordsTableViewController : UITableViewController{
    // PM: database variables
    NSString *databaseName;
    NSString *databasePath;
    sqlite3 *database;
    
    //NSMutableArray *memoriesArray;
}

// PM: database vars
@property (nonatomic, retain) NSString * databaseName;
@property (nonatomic, retain) NSString * databasePath;
@property (nonatomic) sqlite3 * database;

- (void) updateGlobalRecsArray;

//@property (nonatomic, retain) NSMutableArray * memoriesArray;
@end

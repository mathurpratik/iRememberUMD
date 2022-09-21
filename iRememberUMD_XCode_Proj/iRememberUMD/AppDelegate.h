//
//  AppDelegate.h
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/4/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <sqlite3.h>
#import "ASIFormDataRequest.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    // PM: database variables
    NSString *databaseName;
    NSString *databasePath;
    sqlite3 *database;
    
    NSMutableArray * myRecordsGlobalArray;
    
    // PM: reachability stuff
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    
    ASIFormDataRequest *request;

    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray * myRecordsGlobalArray;

// PM: database vars
@property (nonatomic, retain) NSString * databaseName;
@property (nonatomic, retain) NSString * databasePath;
@property (nonatomic) sqlite3 * database;

@property (retain, nonatomic) ASIFormDataRequest *request;


- (void) updateGlobalRecsArray;
- (void) upLoadUnsuccessfulRecords;
@end

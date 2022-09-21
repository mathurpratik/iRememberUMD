//
//  AppDelegate.m
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/4/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize myRecordsGlobalArray;
@synthesize databaseName,databasePath,database;
@synthesize request;
- (void)dealloc
{
    [_window release];
    [myRecordsGlobalArray release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // PM: make a connection to database
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
        return YES;
    }
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    [fileManager release];

    
    myRecordsGlobalArray = [[NSMutableArray alloc] init ];
    
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
    
	hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
	[hostReach startNotifier];
	[self updateInterfaceWithReachability: hostReach];
	
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	[self updateInterfaceWithReachability: internetReach];
    
    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	[self updateInterfaceWithReachability: wifiReach];
    
    
    return YES;
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
    
}

- (void) reachabilityChanged: (NSNotification* )note
{
    NSLog(@"reachability changed\n");
	Reachability* curReach = [note object];    
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    NSLog(@"update interface with reachability\n");
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        NSLog(@"Network not reachable");
    }

    if(curReach == hostReach)
	{
        /*
		[self configureTextField: remoteHostStatusField imageView: remoteHostIcon reachability: curReach];
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        BOOL connectionRequired= [curReach connectionRequired];
        
        summaryLabel.hidden = (netStatus != ReachableViaWWAN);
        NSString* baseLabel=  @"";
        if(connectionRequired)
        {
            baseLabel=  @"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
        }
        else
        {
            baseLabel=  @"Cellular data network is active.\n  Internet traffic will be routed through it.";
        }
        summaryLabel.text= baseLabel;
         */
        NSLog(@"host reach case\n");
    }
	if(curReach == internetReach)
	{	
		//[self configureTextField: internetConnectionStatusField imageView: internetConnectionIcon reachability: curReach];
        NSLog(@"internet reach\n");
	}
	if(curReach == wifiReach)
	{	
		//[self configureTextField: localWiFiConnectionStatusField imageView: localWiFiConnectionIcon reachability: curReach];
        NSLog(@"wifi reach\n");
        
        // PM: good place to re-try my records upload
        [self upLoadUnsuccessfulRecords];
	}
	
}

// PM: This function is called as soon as wifi reachability is detected. 
//     It performs a database lookup and tries to determine if 
- (void) upLoadUnsuccessfulRecords{
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
                NSString *tags= [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 4)];
                float lat = sqlite3_column_double(statement, 2);
                float lng = sqlite3_column_double(statement, 3);
                NSData * data = sqlite3_column_blob(statement, 1);
                //[User setAge:[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)]];
                
                NSLog(@"Uploading %@", tags);
                
                // step 1. get blob key from GAE
                NSURL *blobKeyURL = [NSURL URLWithString:@"http://irememberumcp.appspot.com/getnewblobkey"];
                //NSURL *blobKeyURL = [NSURL URLWithString:@"http://localhost:8888/getnewblobkey"];
                ASIHTTPRequest *uploadURLRequest = [ASIHTTPRequest requestWithURL:blobKeyURL];
                [uploadURLRequest setDelegate:self];
                [uploadURLRequest setDidFailSelector:@selector(didFailToGetBlobKey:)];
                [uploadURLRequest setDidFinishSelector:@selector(didReceiveBlobKey:)];
                
                
                
                [uploadURLRequest startSynchronous];
                NSError *error = [uploadURLRequest error];
                if (!error) {
                    NSString *blobkey = [uploadURLRequest responseString];
                    
                    
                    NSLog(@"Received upload URL from GAE");
                    NSLog(@"blobkey = %@", blobkey);
                    
                    // step 2. generate upload URL from blob key
                    NSString * uploadURLStr = [NSString stringWithFormat:@"http://irememberumcp.appspot.com/_ah/upload/%@/", blobkey];
                    //NSString * uploadURLStr = [NSString stringWithFormat:@"http://localhost:8888/_ah/upload/%@", blobkey];
                    NSLog(@"upload URL = %@", uploadURLStr);
                    
                    //NSURL *uploadURL = [NSURL URLWithString:uploadURLStr];
                    [request cancel];
                    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:uploadURLStr]]];
                    [request setPostValue:[NSString stringWithFormat:@"%f",lat] forKey:@"myLat"];
                    [request setPostValue:[NSString stringWithFormat:@"%f",lng] forKey:@"myLng"];
                    [request setPostValue:tags forKey:@"myTags"];
                    //[uploadRequest setPostValue:responseBlobKey forKey:@"blob-key"];
                    //NSString * tmp = [responseBlobKey ge]
                    //[request setPostValue:@"" forKey:@""];
                    [request setTimeOutSeconds:20];
                    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
                    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
                    [request setDelegate:self];
                    [request setDidFailSelector:@selector(uploadFailed:)];
                    [request setDidFinishSelector:@selector(uploadFinished:)];
                    
                    [request setData:data forKey:@"myFile"];
                    [request startAsynchronous];
                    NSLog(@"Uploading data...");
                    //[statusBar setText:@"Uploading..."];
                }
                
                //[currentUser release];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}



- (void)uploadFailed:(ASIHTTPRequest *)theRequest
{
	NSLog(@"Request failed:\r\n");
    //[statusBar setText:@"Could not upload. Database backup."];
    
    //[self persistBlobToDisk];
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest
{
    NSLog(@"Upload finished:\r\n");
    //[statusBar setText:@"Upload complete!"];
    NSString * successResponse = [theRequest responseString];
    NSLog(@"SUCCESS RESPONSE = %@", successResponse);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end

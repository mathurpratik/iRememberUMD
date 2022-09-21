//
//  SecondViewController.m
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/4/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import "SecondViewController.h"
#import "ASIFormDataRequest.h"
#import "UserDroppedPinAnnotation.h"
#import "AppDelegate.h"
@implementation SecondViewController
@synthesize locationManager;
@synthesize actSpinner, btnStart, btnPlay, tags, lat, lng,map, statusBar;
@synthesize request;
@synthesize databaseName,databasePath,database,myRecordsDataSource;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    pinDropped = NO;
    [self gotoLocation];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.map addGestureRecognizer:longPressGesture];
    [longPressGesture release];
    
    self.locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 5;
	
    
    //Start the toggle in true mode.
	toggle = YES;
	btnPlay.hidden = YES;
    
	//Instanciate an instance of the AVAudioSession object.
	AVAudioSession * audioSession = [AVAudioSession sharedInstance];
	//Setup the audioSession for playback and record. 
	//We could just use record and then switch it to playback leter, but
	//since we are going to do both lets set it up once.
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
	//Activate the session
	[audioSession setActive:YES error: &error];
    
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
        [self updateGlobalRecsArray];
        return;
    }
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    [fileManager release];

    
    
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

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [statusBar setText:@"Tap and hold for pin drop.Click Record and share!"];
     
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

// PM: changes begin

//////////////////////  L O C A T I O N    C A L L B A C K S   ///////////////////////////

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    
    [locationManager stopUpdatingLocation];
    pinDropped = NO;
    NSLog(@"new location = %@", [newLocation description]);
    
    lat = newLocation.coordinate.latitude;
    lng = newLocation.coordinate.longitude;
    
    [self performLargeUpload];
}

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    
    NSLog(@"long press gesture");
    
    
    // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
    CGPoint point = [sender locationInView:self.map];
    CLLocationCoordinate2D locCoord = [self.map convertPoint:point toCoordinateFromView:self.map];
    
    for (id annotation in map.annotations){
        UserDroppedPinAnnotation * userDrop = (UserDroppedPinAnnotation *) annotation;
        if (userDrop.coordinate.latitude == locCoord.latitude && 
            userDrop.coordinate.longitude == locCoord.longitude) {
            return;
        }
    }
    
    // clear out map annotations
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
    for (id annotation in map.annotations)
        [toRemove addObject:annotation];
    [map removeAnnotations:toRemove];
    
    
    // Then all you have to do is create the annotation and add it to the map
    UserDroppedPinAnnotation *dropPin = [[UserDroppedPinAnnotation alloc] initWithCoordinate: locCoord];
        
    [self.map addAnnotation:dropPin];
    self.lat = dropPin.coordinate.latitude;
    self.lng = dropPin.coordinate.longitude;
    [dropPin release];
    pinDropped = YES;
    
}


- (void)gotoLocation
{
	
    // start off by default at UMCP
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 38.988301848435725;
    newRegion.center.longitude = -76.9424057006836;
    newRegion.span.latitudeDelta = 0.025;
    newRegion.span.longitudeDelta = 0.025;
    
	
    [self.map setRegion:newRegion animated:YES];
}
//////////////////////  R E C O R D I N G    F U N C T I O N S ///////////////////////////

- (IBAction)  start_button_pressed{
    
	if(toggle)
	{
		toggle = NO;
		[actSpinner startAnimating];
        [statusBar setText:@"Recording..."];
		[btnStart setTitle:@"Stop Rec." forState: UIControlStateNormal ];	
		btnPlay.enabled = toggle;
		btnPlay.hidden = !toggle;

		NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
		[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
		[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
		[recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
		
		
		recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
		NSLog(@"Using File called: %@",[recordedTmpFile path]);
		//Setup the recorder to use this file and record to it.
		recorder = [[ AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];
		//Use the recorder to start the recording.
		//Im not sure why we set the delegate to self yet.  
		//Found this in antother example, but Im fuzzy on this still.
		[recorder setDelegate:self];
		//We call this to start the recording process and initialize 
		//the subsstems so that when we actually say "record" it starts right away.
		[recorder prepareToRecord];
		//Start the actual Recording
		[recorder record];
		//There is an optional method for doing the recording for a limited time see 
		//[recorder recordForDuration:(NSTimeInterval) 10]
		
	}
	else
	{
		toggle = YES;
		[actSpinner stopAnimating];
		[btnStart setTitle:@"Record" forState:UIControlStateNormal ];
        [statusBar setText:@"Click Play to listen or just share!"];
		btnPlay.enabled = toggle;
		btnPlay.hidden = !toggle;
		
		NSLog(@"Using File called: %@",[recordedTmpFile path]);
		//Stop the recorder.
		[recorder stop];        
	}
}

-(IBAction) play_button_pressed{
    
	//The play button was pressed... 
	//Setup the AVAudioPlayer to play the file that we just recorded.
	AVAudioPlayer * avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedTmpFile error:&error];
	[avPlayer prepareToPlay];
	[avPlayer play];    
}

- (IBAction) upload_button_pressed:(id)sender {
    // PM: adding some code to check whether user entered tag info
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Error"
                          message: @"Must enter tag before uploading"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];

    
    if ([tags text] == nil) {
        NSLog(@"Must enter a tag!");
        [alert show];
        [alert release];
        return;
    }
    if ([[tags text]isEqualToString:@""]){
        NSLog(@"Must enter a tag!");
        [alert show];
        [alert release];
        return;
    }
    
    
    NSLog(@"upload button pressed");
    if (pinDropped) {
        // use location of dropped pin. No need to start location manager!
        [self performLargeUpload];
        return;
    }
    [statusBar setText:@"Trying to determine your location."];
    [locationManager startUpdatingLocation]; // this will invoke "didUpdateUserLocation"
    
    [alert release];
}

- (IBAction)performLargeUpload
{
    // step 1. get blob key from GAE
    NSURL *blobKeyURL = [NSURL URLWithString:@"http://irememberumcp.appspot.com/getnewblobkey"];
    //NSURL *blobKeyURL = [NSURL URLWithString:@"http://localhost:8888/getnewblobkey"];
    ASIHTTPRequest *uploadURLRequest = [ASIHTTPRequest requestWithURL:blobKeyURL];
    [uploadURLRequest setDelegate:self];
	[uploadURLRequest setDidFailSelector:@selector(didFailToGetBlobKey:)];
	[uploadURLRequest setDidFinishSelector:@selector(didReceiveBlobKey:)];
    [uploadURLRequest startAsynchronous];
}

- (IBAction)textFieldDidEndEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)didFailToGetBlobKey:(ASIHTTPRequest *) theRequest {
    NSLog(@"Failed to get upload URL from GAE");
    
    [ self persistBlobToDisk];
}

- (void)didReceiveBlobKey:(ASIHTTPRequest *)theRequest{
    NSLog(@"Received upload URL from GAE");
    NSString * blobkey = [theRequest responseString];
    NSLog(@"blobkey = %@", blobkey);
    
    // step 2. generate upload URL from blob key
    NSString * uploadURLStr = [NSString stringWithFormat:@"http://irememberumcp.appspot.com/_ah/upload/%@/", blobkey];
    //NSString * uploadURLStr = [NSString stringWithFormat:@"http://localhost:8888/_ah/upload/%@", blobkey];
    NSLog(@"upload URL = %@", uploadURLStr);
    
    //NSURL *uploadURL = [NSURL URLWithString:uploadURLStr];
    [request cancel];
	[self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:uploadURLStr]]];
    [request setPostValue:[NSString stringWithFormat:@"%f",self.lat] forKey:@"myLat"];
	[request setPostValue:[NSString stringWithFormat:@"%f",self.lng] forKey:@"myLng"];
    [request setPostValue:tags.text forKey:@"myTags"];
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
    
    [request setFile:[recordedTmpFile path] forKey:@"myFile"];
	[request startAsynchronous];
	NSLog(@"Uploading data...");
    [statusBar setText:@"Uploading..."];
    
    
}

- (void)uploadFailed:(ASIHTTPRequest *)theRequest
{
	NSLog(@"Request failed:\r\n");
    [statusBar setText:@"Could not upload. Database backup."];
    
    [self persistBlobToDisk];
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest
{
    NSLog(@"Upload finished:\r\n");
    [statusBar setText:@"Upload complete!"];
    NSString * successResponse = [theRequest responseString];
    NSLog(@"SUCCESS RESPONSE = %@", successResponse);
}

- (void) persistBlobToDisk {
    // PM: get shared instance of global records array
    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray * globalRecs = [myDelegate myRecordsGlobalArray];
    
    
    // PM: good time to insert voice memory blob into database.
    NSData * blob = [NSData dataWithContentsOfURL:recordedTmpFile];
    int rc=-1;
    rc = sqlite3_open([databasePath UTF8String], &database);
    
    if(rc == SQLITE_OK) {
        sqlite3_exec(database, "BEGIN", 0, 0, 0);
        
        
        NSLog(@"Connected To: %@",databasePath);
        sqlite3_stmt *updStmt =nil; 
        const char *sql = "INSERT INTO memories (data,place) VALUES (?,?);";
        
        rc = sqlite3_prepare_v2(database, sql, -1, &updStmt, NULL);
        
        if(rc!= SQLITE_OK)
        {
            NSLog(@"Error while creating update statement:%@", sqlite3_errmsg(database));
        }
        sqlite3_bind_text( updStmt, 2, [[tags text] UTF8String], -1, SQLITE_TRANSIENT);
        rc = sqlite3_bind_blob(updStmt, 1, [blob bytes], [blob length] , SQLITE_BLOB);
        
        if((rc = sqlite3_step(updStmt)) != SQLITE_DONE)
        {
            NSLog(@"Error while updating: %@", sqlite3_errmsg(database));
            sqlite3_reset(updStmt);
        } 
        
        sqlite3_exec(database, "COMMIT", 0, 0, 0);
        //rc = sqlite3_reset(updStmt);
        
        sqlite3_close(database);
        
        [globalRecs addObject:[tags text]];
        
    }
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


- (void) dealloc {
    [locationManager stopUpdatingLocation];
	[locationManager release];
    
    // PM: database vars
    [databaseName release];
    [databasePath release];
    [super dealloc];
}

@end

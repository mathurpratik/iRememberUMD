//
//  SecondViewController.h
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/4/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
// another test. one more test.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "ASIHTTPRequestDelegate.h"
#import "sqlite3.h"
@class ASIFormDataRequest;
@interface SecondViewController : UIViewController<CLLocationManagerDelegate,AVAudioRecorderDelegate,ASIHTTPRequestDelegate>{
    CLLocationManager * locationManager;
    
    IBOutlet MKMapView *map;
    IBOutlet UIButton * btnStart;
	IBOutlet UIButton * btnPlay;
	IBOutlet UIActivityIndicatorView * actSpinner;
    IBOutlet UITextField * tags;
    IBOutlet UILabel * statusBar;
    float lat;
    float lng;
	BOOL toggle;
    BOOL pinDropped;
	
	//Variables setup for access in the class:
	NSURL * recordedTmpFile;
	AVAudioRecorder * recorder;
	NSError * error;
    
    // PM: database variables
    NSString *databaseName;
    NSString *databasePath;
    sqlite3 *database;
    NSMutableArray * myRecordsDataSource;
    
    ASIFormDataRequest *request;
}

@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic,retain)IBOutlet UIActivityIndicatorView * actSpinner;
@property (nonatomic,retain)IBOutlet UIButton * btnStart;
@property (nonatomic,retain)IBOutlet UIButton * btnPlay;
@property (nonatomic, retain) IBOutlet UITextField * tags;
@property (nonatomic, retain) IBOutlet UILabel * statusBar;
@property (nonatomic, assign) float lat;
@property (nonatomic, assign) float lng;

// PM: database vars
@property (nonatomic, retain) NSString * databaseName;
@property (nonatomic, retain) NSString * databasePath;
@property (nonatomic) sqlite3 * database;
@property (nonatomic, retain) NSMutableArray * myRecordsDataSource;

@property (retain, nonatomic) ASIFormDataRequest *request;
- (IBAction) start_button_pressed;
- (IBAction) play_button_pressed;
- (IBAction) upload_button_pressed:(id)sender;
- (IBAction) performLargeUpload;
- (IBAction)textFieldDidEndEditing:(id)sender;
- (void) gotoLocation;
- (void) persistBlobToDisk;
- (void) updateGlobalRecsArray;

@end

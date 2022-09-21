//
//  FirstViewController.h
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/4/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
// test commit.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ParsedVoiceMemory.h"
#import "MemoryDetailViewController.h"


@interface FirstViewController : UIViewController<MKMapViewDelegate,NSXMLParserDelegate>
{
    IBOutlet MKMapView *map;
    IBOutlet UITextField * tagsText;
    IBOutlet UILabel * statusBar;
    
@private
    NSXMLParser *xmlParser;
    NSInteger depth;
    NSMutableString *currentName;
    NSString *currentElement;
    NSMutableArray * voiceMemories;
    ParsedVoiceMemory * currentObject;
    
    MemoryDetailViewController * detailViewController;
}

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) IBOutlet UITextField * tagsText;
@property (nonatomic, retain) IBOutlet UILabel * statusBar;
@property (nonatomic, retain) IBOutlet MemoryDetailViewController * detailViewController;

// user interface
- (void)gotoLocation;
- (IBAction)updateMap:(id)sender;
- (IBAction)textFieldDidEndEditing:(id)sender;

// parsing
- (void)start:(NSString *) xml;


@end

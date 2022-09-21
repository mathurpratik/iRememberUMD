//
//  FirstViewController.m
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/4/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import "FirstViewController.h"
#import "ASIHTTPRequest.h"
#import "VoiceMemoryAnnotation.h"
#import <AVFoundation/AVFoundation.h>

@interface FirstViewController ()
- (void)showCurrentDepth;
@end

@implementation FirstViewController
@synthesize map, tagsText,statusBar, detailViewController;
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
    [self gotoLocation];
    
    voiceMemories = [[NSMutableArray alloc] init ];
    self.detailViewController = nil;
    map.delegate = self;
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

- (IBAction)textFieldDidEndEditing:(id)sender {
    [sender resignFirstResponder];
}


// M A P   C A L L    B A C K S


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView*singleAnnotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    
    
    // PM: this pin will have a callout (i.e. dont' forget to override title function! Else exception thrown)
    singleAnnotationView.canShowCallout = YES;
    
    // PM: add disclosure button
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    
    singleAnnotationView.rightCalloutAccessoryView = rightButton;
    
    return singleAnnotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view 
calloutAccessoryControlTapped:(UIControl *)control
{
    id<MKAnnotation> selectedAnn = view.annotation;
    
    if ([selectedAnn isKindOfClass:[VoiceMemoryAnnotation class]])
    {
        VoiceMemoryAnnotation *vma = (VoiceMemoryAnnotation *)selectedAnn;
        // PM: display details about selected pin
        detailViewController = [[MemoryDetailViewController alloc]initWithNibName:@"MemoryDetailViewController" bundle:nil andVMA:vma ];
        [self presentModalViewController:detailViewController animated:YES];
        NSLog(@"selected VMA = %@, blobkey=%@", vma, vma.blobkey);
    }
    else
    {
        NSLog(@"selected annotation (not a VMA) = %@", selectedAnn);
    }
    
    
}


// PM: changes begin

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

- (IBAction)updateMap:(id)sender{
    NSLog(@"update map with tags: %@", tagsText.text);
    [statusBar setText:@"Downloading memories..."];
    
    // clear voice memories
    if (voiceMemories != nil) {
        [voiceMemories release];
    }
    voiceMemories = [[NSMutableArray alloc]init];
    
    // clear out map annotations
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
    for (id annotation in map.annotations)
        [toRemove addObject:annotation];
    [map removeAnnotations:toRemove];
    
    
    double latDel = map.region.span.latitudeDelta;
    double lonDel = map.region.span.longitudeDelta;
    double centerLat = map.region.center.latitude;
    double centerLon = map.region.center.longitude;
    
    double north = centerLat + latDel;
    double east =  centerLon + lonDel;
    double south = centerLat - latDel;
    double west =  centerLon - lonDel;
    NSLog(@"center = (%f,%f)", centerLat, centerLon);
    NSLog(@"north = %f east= %f south = %f west = %f ",north, east, south, west);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://irememberumcp.appspot.com/search?north=%f&east=%f&south=%f&west=%f&tags=%@",north,east,south,west,tagsText.text]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didFinishSearch:)];
    [request setDidFailSelector:@selector(didFailSearch:)];
    [request startAsynchronous];
    
}

- (void)didFinishSearch:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *locationsXML = [request responseString];
    [statusBar setText:@"Download complete. Adding pins..."];
    //NSLog(@"SUCESS RESPONSE: %@", locationsXML);
    
    [self start:locationsXML];
    
    
}

- (void)didFailSearch:(ASIHTTPRequest *)request
{
    NSLog(@"search failed");
}


/////////// P A R S I N G ////////////

- (void)start:(NSString *) xml
{
    
    xmlParser = [[NSXMLParser alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    [xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
    
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser 
{
    NSLog(@"Document started");
    depth = 0;
    currentElement = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
    NSLog(@"Error: %@", [parseError localizedDescription]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{
    [currentElement release];
    currentElement = [elementName copy];
    
    if ([currentElement isEqualToString:@"Location"])
    {
        ++depth;
        [self showCurrentDepth];
        
        currentObject = [[ParsedVoiceMemory alloc] init];
    }
    else if ([currentElement isEqualToString:@"name"])
    {
        [currentName release];
        currentName = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"Location"]) 
    {
        
        // PM: might as well add the annotation to map
        CLLocationCoordinate2D testCoord;
        testCoord.latitude = currentObject.lat;
        testCoord.longitude = currentObject.lng;
        VoiceMemoryAnnotation * voiceAnnotation = [[VoiceMemoryAnnotation alloc] initWithBlobkey:currentObject.blobkey andCoordinate:testCoord];
        [self.map addAnnotation:voiceAnnotation];
        
        --depth;
        [self showCurrentDepth];
        [voiceMemories addObject:currentObject];
        currentObject = nil;
    }
    else if ([elementName isEqualToString:@"name"])
    {
        if (depth == 1)
        {
            NSLog(@"Outer name tag: %@", currentName);
        }
        else 
        {
            NSLog(@"Inner name tag: %@", currentName);
        }
    }
}        

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([currentElement isEqualToString:@"lat"]) 
    {
        currentObject.lat = [string doubleValue];
    }
    if ([currentElement isEqualToString:@"lng"]) 
    {
        currentObject.lng = [string doubleValue];
    }
    if ([currentElement isEqualToString:@"blobkey"]) 
    {
        currentObject.blobkey = [NSString stringWithString:string];
    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
    NSLog(@"Document finished");
    [statusBar setText:@"Tap pins to play!"];
}

#pragma mark -
#pragma mark Private methods

- (void)showCurrentDepth
{
    NSLog(@"Current depth: %d", depth);
}




- (void)dealloc{
    // user interface
    [map release];
    [tagsText release];
    
    // parser
    [currentElement release];
    [currentName release];
    [xmlParser release];
    [voiceMemories release];
    [detailViewController release];
    [super dealloc];

}

@end

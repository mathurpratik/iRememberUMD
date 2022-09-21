//
//  VoiceMemoryAnnotation.m
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/7/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import "VoiceMemoryAnnotation.h"

@implementation VoiceMemoryAnnotation
@synthesize blobkey,coordinate;

-(id)initWithBlobkey:(NSString *) key andCoordinate:(CLLocationCoordinate2D) c{
	blobkey = [NSString stringWithString:key];
    coordinate = c;
	return self;
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return @"Tap for details";
}

- (void) dealloc {
    [blobkey release];
    [super dealloc];
}
@end

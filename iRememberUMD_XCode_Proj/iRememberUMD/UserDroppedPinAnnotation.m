//
//  UserDroppedPinAnnotation.m
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/8/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import "UserDroppedPinAnnotation.h"

@implementation UserDroppedPinAnnotation
@synthesize coordinate;
-(id)initWithCoordinate:(CLLocationCoordinate2D) c{

    coordinate = c;
	return self;
}
@end

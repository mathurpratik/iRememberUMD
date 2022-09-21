//
//  UserDroppedPinAnnotation.h
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/8/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface UserDroppedPinAnnotation : NSObject <MKAnnotation> {
   
}

 -(id)initWithCoordinate:(CLLocationCoordinate2D) c;
@end

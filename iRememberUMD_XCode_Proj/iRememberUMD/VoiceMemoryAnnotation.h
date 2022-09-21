//
//  VoiceMemoryAnnotation.h
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/7/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface VoiceMemoryAnnotation : NSObject <MKAnnotation> {
    NSString * blobkey;
}
@property (nonatomic, retain) NSString * blobkey;

-(id)initWithBlobkey:(NSString *) key andCoordinate:(CLLocationCoordinate2D) c;
@end

//
//  ParsedVoiceMemory.h
//  iRememberUMD
//
//  Created by Pratik Mathur on 1/6/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsedVoiceMemory : NSObject {
    NSString * blobkey;
    double lat;
    double lng;
}

@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;
@property (nonatomic, retain) NSString * blobkey;
@end

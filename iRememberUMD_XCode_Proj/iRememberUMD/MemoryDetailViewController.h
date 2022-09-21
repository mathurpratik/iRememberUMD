//
//  MemoryDetailViewController.h
//  iRememberUMD
//
//  Created by Pratik Mathur on 3/18/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoiceMemoryAnnotation.h"

@interface MemoryDetailViewController : UIViewController{
    IBOutlet UIButton * btnDone;
    IBOutlet UIButton * btnPlay;
    IBOutlet UILabel * lblBlobKey;
    VoiceMemoryAnnotation * vma;
}

@property (nonatomic,retain)IBOutlet UIButton * btnDone;
@property (nonatomic,retain)IBOutlet UIButton * btnPlay;
@property (nonatomic,retain)IBOutlet UILabel * lblBlobKey;
@property (nonatomic,retain)VoiceMemoryAnnotation * vma;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andVMA:(VoiceMemoryAnnotation *)myVma;
- (IBAction) doneBtnPressed:(id)sender;
- (IBAction) playBtnPressed:(id)sender;
@end

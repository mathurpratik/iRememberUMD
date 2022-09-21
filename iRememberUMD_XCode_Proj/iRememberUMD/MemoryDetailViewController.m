//
//  MemoryDetailViewController.m
//  iRememberUMD
//
//  Created by Pratik Mathur on 3/18/12.
//  Copyright (c) 2012 University of Maryland, College Park. All rights reserved.
//

#import "MemoryDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "VoiceMemoryAnnotation.h"
#import <AVFoundation/AVFoundation.h>

@implementation MemoryDetailViewController
@synthesize btnDone, btnPlay, vma, lblBlobKey;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andVMA:(VoiceMemoryAnnotation *)myVma
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set vma
        vma = myVma;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [lblBlobKey setText:vma.blobkey];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction) doneBtnPressed:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction) playBtnPressed:(id)sender{
    NSLog(@"playing...");
    
    
    VoiceMemoryAnnotation *voiceAnnotation = vma;
    NSLog(@"blobkey = %@", voiceAnnotation.blobkey);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://irememberumcp.appspot.com/handledownload?blob-key=%@",voiceAnnotation.blobkey]];
    __block ASIHTTPRequest *downloadRequest = [ASIHTTPRequest requestWithURL:url];
    [downloadRequest setCompletionBlock:^{
        // Use when fetching text data
        //NSString *responseString = [request responseString];
        //[statusBar setText:@"Download complete! Playing now..."];
        NSLog(@"Download complete! PLaying now..");
        // Use when fetching binary data
        NSData * downloadedData = [downloadRequest responseData];
        AVAudioPlayer * avPlayer = [[AVAudioPlayer alloc] initWithData:downloadedData error:NULL];
        [avPlayer prepareToPlay];
        [avPlayer play];
        
    }];
    [downloadRequest setFailedBlock:^{
        NSError *error = [downloadRequest error];
        NSLog(@"error downloading audio file from GAE: %@",[error description]);
    }];
    [downloadRequest startAsynchronous];
    NSLog(@"Downloading memory...");
    //[statusBar setText:@"Downloading memory..."];

    
}

@end

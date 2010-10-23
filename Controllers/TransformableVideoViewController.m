//
//  TransformableVideoViewController.m
//  TransformableVideo
//
//  Created by Kyle Kinkade on 10/16/10.
//  Copyright 2010 Monster Costume Inc. All rights reserved.
//

#import "TransformableVideoViewController.h"
#import "TransformableVideoView.h"

@implementation TransformableVideoViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidAppear:(BOOL)animated; 
{
	[super viewDidAppear:animated];
	
	TransformableVideoView *videoView = [[TransformableVideoView alloc] initWithFrame:CGRectMake(50,50,200,200)];
	
	[self.view addSubview:videoView];
	[videoView release];
}
@end

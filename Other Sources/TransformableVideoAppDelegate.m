//
//  TransformableVideoAppDelegate.m
//  TransformableVideo
//
//  Created by Kyle Kinkade on 10/16/10.
//  Copyright 2010 Monster Costume Inc. All rights reserved.
//

#import "TransformableVideoAppDelegate.h"
#import "TransformableVideoViewController.h"

@implementation TransformableVideoAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    // Override point for customization after application launch.
    // Add the view controller's view to the window and display.
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    return YES;
}

- (void)dealloc 
{
    [viewController release];
    [window release];
    [super dealloc];
}


@end

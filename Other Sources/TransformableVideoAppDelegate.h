//
//  TransformableVideoAppDelegate.h
//  TransformableVideo
//
//  Created by Kyle Kinkade on 10/16/10.
//  Copyright 2010 Monster Costume Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransformableVideoViewController;

@interface TransformableVideoAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
    TransformableVideoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TransformableVideoViewController *viewController;

@end


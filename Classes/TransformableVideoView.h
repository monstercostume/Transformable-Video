//
//  TransformableVideoView.h
//
//  Created by Kyle Kinkade on 10/22/10.
//  Copyright 2010 Monster Costume Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransformableVideoView : UIView 
{
	CGAffineTransform		originalTransform;
    CFMutableDictionaryRef	touchBeginPoints;
}

@end

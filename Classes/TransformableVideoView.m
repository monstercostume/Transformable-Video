//
//  TransformableVideoView.m
//
//  Created by Kyle Kinkade on 10/22/10.
//  Copyright 2010 Monster Costume Inc. All rights reserved.
//

#import "TransformableVideoView.h"
#import "CameraImageHelper.h"

#pragma mark 
#pragma mark -
#pragma mark UITouch Category
#pragma mark -
#pragma mark

@interface UITouch (TouchSorting)

- (NSComparisonResult)compareAddress:(id)obj;

@end

@implementation UITouch (TouchSorting)

- (NSComparisonResult)compareAddress:(id)obj 
{
    if ((void *)self < (void *)obj) 
	{
        return NSOrderedAscending;
    } 
	else if ((void *)self == (void *)obj) 
	{
        return NSOrderedSame;
    } 
	else 
	{
        return NSOrderedDescending;
    }
}

@end

#pragma mark 
#pragma mark -
#pragma mark Transformation Category
#pragma mark -
#pragma mark

@interface TransformableVideoView (Transformation)

- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches;
- (void)updateOriginalTransformForTouches:(NSSet *)touches;

- (void)cacheBeginPointForTouches:(NSSet *)touches;
- (void)removeTouchesFromCache:(NSSet *)touches;

@end

@implementation TransformableVideoView (Transformation)


- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches {
	
    NSArray *sortedTouches = [[touches allObjects] sortedArrayUsingSelector:@selector(compareAddress:)];
    NSInteger numTouches = [sortedTouches count];
    
	// If there are no touches, simply return identify transform.
	if (numTouches == 0) 
	{
        return CGAffineTransformIdentity;
    }
	
	// Single touch
	if (numTouches == 1) 
	{
        UITouch *touch = [sortedTouches objectAtIndex:0];
		
		id value = (id)CFDictionaryGetValue(touchBeginPoints, touch);
		if(!value)
			return CGAffineTransformIdentity;
		
        CGPoint beginPoint = *(CGPoint *)value;
        CGPoint currentPoint = [touch locationInView:self.superview];
		return CGAffineTransformMakeTranslation(currentPoint.x - beginPoint.x, currentPoint.y - beginPoint.y);
	}
	
	// If two or more touches, go with the first two (sorted by address)
	UITouch *touch1 = [sortedTouches objectAtIndex:0];
	UITouch *touch2 = [sortedTouches objectAtIndex:1];
	
	id value1 = (id)CFDictionaryGetValue(touchBeginPoints, touch1);
	if(!value1)
		return CGAffineTransformIdentity;
	
	id value2 = (id)CFDictionaryGetValue(touchBeginPoints, touch2);
	if(!value2)
		return CGAffineTransformIdentity;
	
    CGPoint beginPoint1 = *(CGPoint *)value1;
    CGPoint currentPoint1 = [touch1 locationInView:self.superview];
    CGPoint beginPoint2 = *(CGPoint *)value2;
    CGPoint currentPoint2 = [touch2 locationInView:self.superview];
	
	double layerX = self.center.x;
	double layerY = self.center.y;
	
	double x1 = beginPoint1.x - layerX;
	double y1 = beginPoint1.y - layerY;
	double x2 = beginPoint2.x - layerX;
	double y2 = beginPoint2.y - layerY;
	double x3 = currentPoint1.x - layerX;
	double y3 = currentPoint1.y - layerY;
	double x4 = currentPoint2.x - layerX;
	double y4 = currentPoint2.y - layerY;
	
	double D = (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2);
	if (D < 0.1) {
        return CGAffineTransformMakeTranslation(x3-x1, y3-y1);
    }
	
	double a = (y1-y2)*(y3-y4) + (x1-x2)*(x3-x4);
	double b = (y1-y2)*(x3-x4) - (x1-x2)*(y3-y4);
	double tx = (y1*x2 - x1*y2)*(y4-y3) - (x1*x2 + y1*y2)*(x3+x4) + x3*(y2*y2 + x2*x2) + x4*(y1*y1 + x1*x1);
	double ty = (x1*x2 + y1*y2)*(-y4-y3) + (y1*x2 - x1*y2)*(x3-x4) + y3*(y2*y2 + x2*x2) + y4*(y1*y1 + x1*x1);
	
    return CGAffineTransformMake(a/D, -b/D, b/D, a/D, tx/D, ty/D);
}


- (void)updateOriginalTransformForTouches:(NSSet *)touches 
{
	
    if ([touches count] > 0) 
	{
        CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:touches];
        self.transform = CGAffineTransformConcat(originalTransform, incrementalTransform);
        originalTransform = self.transform;
    }
}


- (void)cacheBeginPointForTouches:(NSSet *)touches 
{
	
	/*
	 For each touch that's passed in, look to see if it's already been cached in the touchBeginPoints dictionary. If it hasn't, then allocate space for a CGPoint and associate that in the dictionary with the touch.  Then update the value of the point (whether newly-created or previously-cached) to record the new beginning point.
	 */
	for (UITouch *touch in touches) 
	{
		CGPoint *point = (CGPoint *)CFDictionaryGetValue(touchBeginPoints, touch);
		if (point == NULL) 
		{
			point = (CGPoint *)malloc(sizeof(CGPoint));
			CFDictionarySetValue(touchBeginPoints, touch, point);
		}
		*point = [touch locationInView:self.superview];
	}
}


- (void)removeTouchesFromCache:(NSSet *)touches 
{
    for (UITouch *touch in touches) 
	{
        CGPoint *point = (CGPoint *)CFDictionaryGetValue(touchBeginPoints, touch);
        if (point != NULL) 
		{
            free((void *)CFDictionaryGetValue(touchBeginPoints, touch));
            CFDictionaryRemoveValue(touchBeginPoints, touch);
        }
    }
}
@end

#pragma mark 
#pragma mark -
#pragma mark PhotoView Class
#pragma mark -
#pragma mark

@implementation TransformableVideoView

#pragma mark 
#pragma mark -
#pragma mark Init/dealloc methods
#pragma mark

- (id)initWithFrame:(CGRect)aFrame
{
	if(self = [super initWithFrame:aFrame])
	{
		originalTransform = CGAffineTransformIdentity;
		touchBeginPoints = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);

		self.backgroundColor = [UIColor whiteColor];
		
		self.userInteractionEnabled = YES;
		self.exclusiveTouch = NO;
		self.multipleTouchEnabled = YES;
		
		UIView *v = [CameraImageHelper previewWithBounds:self.bounds];
		v.userInteractionEnabled = NO;
		[CameraImageHelper startRunning];
		
		[self addSubview:v];
	}
	return self;
}

- (void)dealloc 
{
    [super dealloc];
}

#pragma mark 
#pragma mark -
#pragma mark Touches
#pragma mark

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[self updateOriginalTransformForTouches:[event touchesForView:self]];
    [self removeTouchesFromCache:touches];
	
    NSMutableSet *remainingTouches = [[[event touchesForView:self] mutableCopy] autorelease];
    [remainingTouches minusSet:touches];
    [self cacheBeginPointForTouches:remainingTouches];
	
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	[self.superview bringSubviewToFront:self];
	
	NSMutableSet *currentTouches = [[[event touchesForView:self] mutableCopy] autorelease];
    [currentTouches minusSet:touches];
	
    if ([currentTouches count] > 0) 
	{
        [self updateOriginalTransformForTouches:currentTouches];
        [self cacheBeginPointForTouches:currentTouches];
    }
	
    [self cacheBeginPointForTouches:touches];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:[event touchesForView:self]];
    self.transform = CGAffineTransformConcat(originalTransform, incrementalTransform);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self touchesEnded:touches withEvent:event];
}

- (void)rotate:(float)angle
{
	self.transform = CGAffineTransformRotate(self.transform, angle);
}

- (void)scale:(float)size
{
	CGAffineTransform tt = [self transform];
	CGAffineTransformMakeScale(size, size);
	self.transform = tt;
}

- (void)resetScale
{
	CFDictionaryRemoveAllValues(touchBeginPoints);
	originalTransform = CGAffineTransformIdentity;
	[self setTransform:CGAffineTransformIdentity];
}

@end

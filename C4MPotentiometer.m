/*******************************************************************************
 * This file is part of the C4MiOS_Potentiometer project.
 * 
 * Copyright (c) 2012 C4M PROD.
 * 
 * C4MiOS_Potentiometer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * C4MiOS_Potentiometer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with C4MiOS_Potentiometer. If not, see <http://www.gnu.org/licenses/lgpl.html>.
 * 
 * Contributors:
 * C4M PROD - initial API and implementation
 ******************************************************************************/

#import "C4MPotentiometer.h"
#import <QuartzCore/QuartzCore.h>
#import "math.h"


@implementation C4MPotentiometer


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if (self) {
		[self initData];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
	if(mStepsArray != nil)[mStepsArray release];
    [super dealloc];
}



#pragma mark - 
#pragma Data Management Methods


- (void)initData
{
	// Default, init with view center.
	[self setReferencePositionTo:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
	mDelegate					= nil;
	mMinDistanceFromReference	= 0;
	mMaxDistanceFromReference	= 10000;
	mMinDegreAngle				= 0;
	mMaxDegreAngle				= 360;
	mStepsArray					= nil;
	mCursorView					= nil;	
	mIsCursorAnimated			= TRUE;
	mCurrentSelectedStep		= 0;
}


- (void)setReferencePositionTo:(CGPoint)_Position
{
	mReferencePoint.x			= _Position.x;
	mReferencePoint.y			= _Position.y;
}


- (CGPoint)referencePoint
{
	return mReferencePoint;
}


- (void)setSwipeStepArayTo:(NSArray*)_SwipeSteps currentSelectedStepIndex:(int)_CurrentSelectedStep
{
	if(_CurrentSelectedStep < 0 || _CurrentSelectedStep > [_SwipeSteps count])
	{
		NSLog(@"!!! Warning !!! invalide default step index");
		mCurrentSelectedStep	= 0;
	}
	else
	{
		mCurrentSelectedStep	= _CurrentSelectedStep;
	}
	
	
	if([_SwipeSteps count] > 0)
	{
		mStepsArray				= [NSMutableArray arrayWithArray:_SwipeSteps];
		[self checkForStepAnglesInvalidValues];
		
		NSSortDescriptor* sort	= [[NSSortDescriptor alloc] initWithKey:nil ascending:YES selector:@selector(compare:)];		
		mStepsArray				= [NSMutableArray arrayWithArray:[mStepsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
		[sort release];
	
		[mStepsArray retain];
		[self setSwipeTypeTo:step_swipe_mode];
	}
	else
	{
		NSLog(@"!!! Warning !!! invalide swipe steps array.");
		[self setSwipeTypeTo:free_swipe_mode];
	}
}


- (void)checkForStepAnglesInvalidValues
{
	NSMutableArray* checkedArray = [NSMutableArray array];
	
	
	for(NSNumber* aStepAngle in mStepsArray)
	{
		if(mMinDegreAngle > [aStepAngle floatValue])
		{
			NSLog(@"!!! Warning !!! minimum angle set to %f conflicting with minimum step set to %f. Value automatacally set to minimum angle.", mMinDegreAngle, [mStepsArray objectAtIndex:0]);
			[checkedArray addObject:[NSNumber numberWithFloat:mMinDegreAngle]];
		}
		else if(mMaxDegreAngle < [aStepAngle floatValue])
		{			
			NSLog(@"!!! Warning !!! maximum angle set to %f conflicting with maximum step set to %f. Value automatacally set to maximum angle.", mMaxDegreAngle, [mStepsArray objectAtIndex:[mStepsArray count] - 1]);
			[checkedArray addObject:[NSNumber numberWithFloat:mMaxDegreAngle]];
		}
		else
		{
			[checkedArray addObject:aStepAngle];
		}
	}
}


- (void)setSwipeTypeTo:(int)_SwipeType
{
	if(_SwipeType > -1 && _SwipeType < 2)
	{
		mSwipeMode			= _SwipeType;
	}
	else
	{
		NSLog(@"!!! Warning !!! invalide swipe type");
		mSwipeMode			= free_swipe_mode;
	}
}


- (int)swipeMode
{
	return mSwipeMode;
}


- (void)setDelegate:(NSObject<C4MPotentiometerDelegate>*)_Delegate
{
	if(_Delegate == nil && mDelegate != nil)
	{
		[mDelegate release];
		mDelegate			= nil;
	}
	else
	{	
		mDelegate			= [_Delegate retain];
		
		if([mDelegate respondsToSelector:@selector(backgroundViewForPotentiometerView:)])
		{
			[self setCursorBackgroundImage:[mDelegate backgroundViewForPotentiometerView:self]];
		}					
	}
}


- (void)setCursorBackgroundImage:(UIView*)_CursorBackgroundView
{
	if(mCursorView != nil)
	{
		[mCursorView removeFromSuperview];
		[mCursorView release];
		mCursorView = nil;
	}
	
	if(_CursorBackgroundView != nil)
	{
		mCursorView		= [_CursorBackgroundView retain];
		mCursorView.frame	= CGRectMake(mReferencePoint.x - mCursorView.frame.size.width / 2, mReferencePoint.y - mCursorView.frame.size.height / 2, mCursorView.frame.size.width, mCursorView.frame.size.height);
		[self addSubview:mCursorView];
	}
}


- (UIView*)cursorBackground
{
	return mCursorView;
}


- (NSObject<C4MPotentiometerDelegate>*)delegate
{
	return mDelegate;
}


- (void)setMinDistanceFromCenter:(int)_Min
{
	if(_Min >= 0 && _Min <= mMaxDistanceFromReference)
	{
		mMinDistanceFromReference	= _Min;
	}
	else
	{		
		NSLog(@"!!! Warning !!! invalide minimum distance from center");
	}
}


- (int)minDistanceFromCenter
{
	return mMinDistanceFromReference;
}


- (void)setMaxDistanceFromCenter:(int)_Max
{
	if(_Max >= 0 && mMinDistanceFromReference <= _Max)
	{
		mMaxDistanceFromReference	= _Max;
	}
	else
	{		
		NSLog(@"!!! Warning !!! invalide maximum distance from center");
	}
}


- (int)maxDistanceFromCenter
{
	return mMaxDistanceFromReference;
}


- (void)setMinAngle:(float)_Angle
{
	if(_Angle >= 0 && _Angle <= mMaxDegreAngle)
	{
		mMinDegreAngle				= _Angle;
	}
	else
	{		
		NSLog(@"!!! Warning !!! invalide minimum angle");
	}
}


- (float)minAngle
{
	return mMinDegreAngle;
}


- (void)setMaxAngle:(float)_Angle
{
	if(_Angle >= 0 && _Angle >= mMinDegreAngle)
	{
		mMaxDegreAngle				= _Angle;
	}
	else
	{		
		NSLog(@"!!! Warning !!! invalide maximum angle");
	}
}


- (float)maxAngle
{
	return mMaxDegreAngle;
}


- (void)setAnimatedCursor:(BOOL)_Animated
{
	mIsCursorAnimated				= _Animated;
}


- (void)animatedCursor
{
	return mIsCursorAnimated;
}


- (float)calculateNewAngle:(CGPoint)_TouchedPoint
{
	float distance                  = sqrt( pow((_TouchedPoint.x - mReferencePoint.x), 2) + pow((_TouchedPoint.y - mReferencePoint.y), 2));
	
    // bouttons touched
    if(distance > mMinDistanceFromReference && distance < mMaxDistanceFromReference)
    {
        float opos                  = _TouchedPoint.y - mReferencePoint.y;
        if(opos < 0) 
        {
            opos                    = -1 * opos;
        }        
        
        float adj                   = _TouchedPoint.x - mReferencePoint.x;
        if(adj < 0) 
        {
            adj                     = -1 * adj;
        }
        
        float angle                 = atan( opos / adj );
		
        angle                       = angle * 180 / M_PI;             
        
        // top part of the wheel
        if(_TouchedPoint.y >= mReferencePoint.y)
        {
            // top left part of the wheel
            if(_TouchedPoint.x <= mReferencePoint.x)
            {
                angle               = 90 + (90 - angle);
            }
        }
        // Buttom part of the wheel
        else
        {
            // buttom right part of the wheel
            if(_TouchedPoint.x >= mReferencePoint.x)
            {
                angle               = 270 + (90 - angle);
            }
            // buttom left part of the wheel
            else
            {
                
                angle               += 180 ;
            }
        } 
		
		if(angle >= mMinDegreAngle && angle <= mMaxDegreAngle)
		{
			return angle;
		}
		else
		{
			return -1;
		}
	}
	else
	{
		return -1;
	}
}


- (int)getStepIndex:(float)_Angle
{
	int currentStep			= 0;
	
	if(_Angle < [[mStepsArray objectAtIndex:0] floatValue])
	{
		return 0;
	}
	
	for(int i = 0 ; i < [mStepsArray count] - 1 ; i++)
	{
		if(_Angle >= [[mStepsArray objectAtIndex:i] floatValue] && _Angle < [[mStepsArray objectAtIndex:i + 1] floatValue])
		{
			float distFromCurrentStep		= _Angle - [[mStepsArray objectAtIndex:i] floatValue];
			float distFromNextStep			= [[mStepsArray objectAtIndex:i + 1] floatValue] - _Angle;
			
			if(distFromCurrentStep > distFromNextStep)
			{
				return currentStep + 1;
			}
			else
			{
				return currentStep;
			}
		}
		currentStep++;
	}
	return currentStep;
}




#pragma mark -
#pragma mark View Update Method


- (void)rotateCursorForAngle:(NSNumber*)_Angle
{
	if(mIsCursorAnimated)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kCursorAnimationDuration];
		
		mCursorView.layer.transform		= CATransform3DMakeRotation([_Angle floatValue] * M_PI / 180 + M_PI / 2, 0, 0, 1);
		
		[UIView commitAnimations];
	}
	else
	{
		mCursorView.layer.transform		= CATransform3DMakeRotation([_Angle floatValue] * M_PI / 180 + M_PI / 2, 0, 0, 1);
	}
}




#pragma mark -
#pragma mark Touches


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	float angle				= [self calculateNewAngle:[(UITouch*)[[touches allObjects] objectAtIndex:0] locationInView:self]];
	if(angle > -1)
	{
		if(mSwipeMode == free_swipe_mode)
		{
			[self rotateCursorForAngle:[NSNumber numberWithFloat:angle]];
			if([mDelegate respondsToSelector:@selector(potentiometerView:touchBeginToAngle:)])
			{
				[mDelegate potentiometerView:self touchBeginToAngle:[NSNumber numberWithFloat:angle]];
			}
		}
		else
		{
			int step = [self getStepIndex:angle];
	
			if(mCurrentSelectedStep != step)
			{
				mCurrentSelectedStep		= step;
				
				[self rotateCursorForAngle:[mStepsArray objectAtIndex:mCurrentSelectedStep]];
				mCurrentSelectedStep = step;
				if([mDelegate respondsToSelector:@selector(potentiometerView:selectedStepIndex:andStepValue:)])
				{
					[mDelegate potentiometerView:self selectedStepIndex:mCurrentSelectedStep andStepValue:[[mStepsArray objectAtIndex:mCurrentSelectedStep] floatValue]];
				}
			}
		}	
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	float angle				= [self calculateNewAngle:[(UITouch*)[[touches allObjects] objectAtIndex:0] locationInView:self]];
	if(angle > -1)
	{
		if(mSwipeMode == free_swipe_mode)
		{
			[self rotateCursorForAngle:[NSNumber numberWithFloat:angle]];
			if([mDelegate respondsToSelector:@selector(potentiometerView:touchMoveToAngle:)])
			{
				[mDelegate potentiometerView:self touchMoveToAngle:[NSNumber numberWithFloat:angle]];
			}
		}
		else
		{
			int step = [self getStepIndex:angle];
			if(mCurrentSelectedStep != step)
			{
				mCurrentSelectedStep		= step;
				[self rotateCursorForAngle:[mStepsArray objectAtIndex:mCurrentSelectedStep]];
				mCurrentSelectedStep = step;
				if([mDelegate respondsToSelector:@selector(potentiometerView:selectedStepIndex:andStepValue:)])
				{
					[mDelegate potentiometerView:self selectedStepIndex:mCurrentSelectedStep andStepValue:[[mStepsArray objectAtIndex:mCurrentSelectedStep] floatValue]];
				}
			}
		}	
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	float angle				= [self calculateNewAngle:[(UITouch*)[[touches allObjects] objectAtIndex:0] locationInView:self]];
	if(angle > -1)
	{
		if(mSwipeMode == free_swipe_mode)
		{
			if([mDelegate respondsToSelector:@selector(potentiometerView:touchEndedToAngle:)])
			{
				[mDelegate potentiometerView:self touchEndedToAngle:[NSNumber numberWithFloat:angle]];
			}
		}
		else
		{
			int step = [self getStepIndex:angle];
			if(mCurrentSelectedStep != step)
			{
				mCurrentSelectedStep = step;
				if([mDelegate respondsToSelector:@selector(potentiometerView:selectedStepIndex:andStepValue:)])
				{
					[mDelegate potentiometerView:self selectedStepIndex:mCurrentSelectedStep andStepValue:[[mStepsArray objectAtIndex:mCurrentSelectedStep] floatValue]];
				}
			}
		}	
	}
}



@end

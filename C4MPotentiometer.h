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

#define kCursorAnimationDuration	0.3


#import <UIKit/UIKit.h>
#import "C4MPotentiometerDelegate.h"




enum positionInView {
	position_top_left,
	position_top_middle,
	position_top_right,
	position_middle_left,
	position_center,
	position_middle_right,
	position_buttom_left,
	position_buttom_middle,
	position_buttom_right
	};

enum swipe_mode {
	free_swipe_mode,
	step_swipe_mode
};



@interface C4MPotentiometer : UIView 
{
	// indicate the type of swipe wanted : free or step by step
    int									mSwipeMode;
	
	int									mMinDistanceFromReference;
	int									mMaxDistanceFromReference;
	float								mMinDegreAngle;
	float								mMaxDegreAngle;
	
	CGPoint								mReferencePoint;
	
	NSObject<C4MPotentiometerDelegate>*	mDelegate;
	
	NSMutableArray*						mStepsArray;
	int									mCurrentSelectedStep;
	
	BOOL								mIsCursorAnimated;
	UIView*								mCursorView;
}

- (void)initData;
- (float)calculateNewAngle:(CGPoint)_TouchedPoint;
- (void)setSwipeStepArayTo:(NSArray*)_SwipeSteps currentSelectedStepIndex:(int)_CurrentSelectedStep;
- (void)checkForStepAnglesInvalidValues;


- (void)rotateCursorForAngle:(NSNumber*)_Angle;

- (void)setCursorBackgroundImage:(UIView*)_CursorBackgroundView;
- (UIView*)cursorBackground;

- (void)setReferencePositionTo:(CGPoint)_Position;
- (CGPoint)referencePoint;

- (void)setSwipeTypeTo:(int)_SwipeType;
- (int)swipeMode;

- (void)setDelegate:(NSObject<C4MPotentiometerDelegate>*)_Delegate;
- (NSObject<C4MPotentiometerDelegate>*)delegate;

- (void)setMinDistanceFromCenter:(int)_Min;
- (int)minDistanceFromCenter;

- (void)setMaxDistanceFromCenter:(int)_Max;
- (int)maxDistanceFromCenter;

- (void)setMinAngle:(float)_Angle;
- (float)minAngle;

- (void)setMaxAngle:(float)_Angle;
- (float)maxAngle;


@end

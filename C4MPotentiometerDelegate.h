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

#import <Foundation/Foundation.h>

@class C4MPotentiometer;

@protocol C4MPotentiometerDelegate <NSObject>
- (UIView*)backgroundViewForPotentiometerView:(C4MPotentiometer*)_PotentiometerView;

@optional
// return the angle mesured in degre in indirect sens. 0 is Est.
- (void)potentiometerView:(C4MPotentiometer*)_PotentiometerView touchBeginToAngle:(NSNumber*)_DegreAngle;
- (void)potentiometerView:(C4MPotentiometer*)_PotentiometerView touchMoveToAngle:(NSNumber*)_DegreAngle;
- (void)potentiometerView:(C4MPotentiometer*)_PotentiometerView touchEndedToAngle:(NSNumber*)_DegreAngle;

- (void)potentiometerView:(C4MPotentiometer*)_PotentiometerView selectedStepIndex:(int)_StepIndex andStepValue:(float)_StepAngleValue;

@end

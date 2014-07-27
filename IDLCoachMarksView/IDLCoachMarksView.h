//
//  WSCoachMarksView.h
//  Version 0.2
//
//  Created by Dimitry Bentsionov on 4/1/13.
//  Copyright (c) 2013 Workshirt, Inc. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

@protocol IDLCoachMarksViewDelegate;
@protocol IDLCoachMarksViewDataSource;

@interface IDLCoachMarksView : UIView

@property (nonatomic, weak) id<IDLCoachMarksViewDelegate> delegate;
@property (nonatomic, weak) id<IDLCoachMarksViewDataSource> dataSource;

@property (nonatomic, strong) UIColor *maskColor;

@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) CGFloat cutoutPadding;
@property (nonatomic, assign) CGFloat maximumLabelWidth;
@property (nonatomic, assign) CGFloat labelSpacing;
@property (nonatomic, assign) BOOL enableContinueLabel;

- (id)initWithFrame:(CGRect)frame;
- (void)start;

@end

@protocol IDLCoachMarksViewDataSource <NSObject>

@required
- (NSInteger)numberOfCoachMarksInView:(IDLCoachMarksView *)view;
- (CGRect)coachMarksView:(IDLCoachMarksView *)view rectAtIndex:(NSInteger)index;
- (NSString *)coachMarksView:(IDLCoachMarksView *)view captionAtIndex:(NSInteger)index;

@end

@protocol IDLCoachMarksViewDelegate <NSObject>

@optional
- (void)coachMarksView:(IDLCoachMarksView*)coachMarksView willNavigateToIndex:(NSInteger)index;
- (void)coachMarksView:(IDLCoachMarksView*)coachMarksView didNavigateToIndex:(NSInteger)index;
- (void)coachMarksViewWillCleanup:(IDLCoachMarksView*)coachMarksView;
- (void)coachMarksViewDidCleanup:(IDLCoachMarksView*)coachMarksView;

@end
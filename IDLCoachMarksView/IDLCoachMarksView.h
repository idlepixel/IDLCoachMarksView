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

+ (CGRect)rectContainingViews:(NSArray *)viewArray relativeToView:(UIView *)referenceView;
+ (CGRect)rectContainingView:(UIView *)view relativeToView:(UIView *)referenceView;

- (CGRect)rectContainingViews:(NSArray *)viewArray;
- (CGRect)rectContainingView:(UIView *)view;

@property (nonatomic, weak) id<IDLCoachMarksViewDelegate> delegate;
@property (nonatomic, weak) id<IDLCoachMarksViewDataSource> dataSource;

@property (nonatomic, strong) NSNumber *animationDuration               UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *cutoutRounding                  UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *cutoutPadding                   UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) NSNumber *cutoutCaptionMargin             UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIFont *captionTitleFont                  UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *captionTitleColor                UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) NSString *continuePrompt                  UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *continuePromptTitleFont           UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *continuePromptTitleColor         UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *continuePromptBackgroundColor    UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *continuePromptHeight            UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *continuePromptEnabled           UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *maskColor                        UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) NSNumber *maximumLabelWidth;


- (id)initWithFrame:(CGRect)frame;
- (void)configure;
- (void)applyAppearanceDefaults:(BOOL)force;
- (void)showCoachMarks;

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
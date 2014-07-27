//
//  WSCoachMarksView.m
//  Version 0.2
//
//  Created by Dimitry Bentsionov on 4/1/13.
//  Copyright (c) 2013 Workshirt, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IDLCoachMarksView.h"

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kCutoutRadius = 2.0f;
static const CGFloat kMaxLblWidth = 230.0f;
static const CGFloat kLblSpacing = 35.0f;
static const BOOL kEnableContinueLabel = YES;

@interface IDLCoachMarksView ()

@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) CAShapeLayer *mask;
@property (nonatomic, strong) UILabel *continueLabel;

@property (nonatomic, strong) NSNumber *currentIndex;

@end

@implementation IDLCoachMarksView

#pragma mark - Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (void)setup
{
    // Default
    self.animationDuration = kAnimationDuration;
    self.cutoutPadding = kCutoutRadius;
    self.maximumLabelWidth = kMaxLblWidth;
    self.labelSpacing = kLblSpacing;
    self.enableContinueLabel = kEnableContinueLabel;

    // Shape layer mask
    CAShapeLayer *mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.9f] CGColor]];
    [self.layer addSublayer:mask];
    self.mask = mask;

    // Capture touches
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];

    // Captions
    self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.maximumLabelWidth, 0.0f)];
    self.captionLabel.backgroundColor = [UIColor clearColor];
    self.captionLabel.textColor = [UIColor whiteColor];
    self.captionLabel.font = [UIFont systemFontOfSize:20.0f];
    self.captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.captionLabel.numberOfLines = 0;
    self.captionLabel.textAlignment = NSTextAlignmentCenter;
    self.captionLabel.alpha = 0.0f;
    [self addSubview:self.captionLabel];

    // Hide until unvoked
    self.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.currentIndex && self.currentIndex.integerValue >= 0) {
        [self goToCoachMarkIndexed:self.currentIndex.integerValue];
    }
}

#pragma mark - Cutout modify

- (void)setCutoutToRect:(CGRect)rect
{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutPadding];
    [maskPath appendPath:cutoutPath];

    // Set the new path
    self.mask.path = maskPath.CGPath;
}

- (void)animateCutoutToRect:(CGRect)rect
{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutPadding];
    [maskPath appendPath:cutoutPath];
    
    // Animate it
    CAShapeLayer *mask = self.mask;
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
}

#pragma mark - Mask color

- (void)setMaskColor:(UIColor *)maskColor
{
    _maskColor = maskColor;
    [self.mask setFillColor:[maskColor CGColor]];
}

#pragma mark - Touch handler

- (void)userDidTap:(UITapGestureRecognizer *)recognizer
{
    // Go to the next coach mark
    NSInteger index = 0;
    if (self.currentIndex) {
        index = self.currentIndex.integerValue + 1;
    }
    [self goToCoachMarkIndexed:index];
}

#pragma mark - Navigation

- (void)start
{
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         [self goToCoachMarkIndexed:0];
                     }];
}

- (void)goToCoachMarkIndexed:(NSUInteger)index
{
    
    // Out of bounds
    if (index >= [self dataSourceNumberOfCoachMarks]) {
        [self cleanup];
        return;
    }

    // Current index
    self.currentIndex = @(index);

    // Coach mark definition
    NSString *markCaption = [self dataSourceCaptionAtIndex:index];
    CGRect markRect = [self dataSourceRectAtIndex:index];

    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:index];
    }

    // Calculate the caption position and size
    self.captionLabel.alpha = 0.0f;
    self.captionLabel.frame = CGRectMake(0.0f, 0.0f, self.maximumLabelWidth, 0.0f);
    self.captionLabel.text = markCaption;
    [self.captionLabel sizeToFit];
    CGFloat y = markRect.origin.y + markRect.size.height + self.labelSpacing;
    CGFloat bottomY = y + self.captionLabel.frame.size.height + self.labelSpacing;
    if (bottomY > self.bounds.size.height) {
        y = markRect.origin.y - self.labelSpacing - self.captionLabel.frame.size.height;
    }
    CGFloat x = floorf((self.bounds.size.width - self.captionLabel.frame.size.width) / 2.0f);

    // Animate the caption label
    self.captionLabel.frame = (CGRect){{x, y}, self.captionLabel.frame.size};
    [UIView animateWithDuration:0.3f animations:^{
        self.captionLabel.alpha = 1.0f;
    }];

    // If first mark, set the cutout to the center of first mark
    if (index == 0) {
        CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
        CGRect centerZero = (CGRect){center, CGSizeZero};
        [self setCutoutToRect:centerZero];
    }

    // Animate the cutout
    [self animateCutoutToRect:markRect];

    // Show continue lbl if first mark
    if (self.enableContinueLabel) {
        UILabel *continueLabel = self.continueLabel;
        if (index == 0) {
            CGRect continueLabelRect = CGRectMake(0.0f, self.bounds.size.height - 30.0f, self.bounds.size.width, 30.0f);
            if (continueLabel == nil) {
                continueLabel = [[UILabel alloc] initWithFrame:continueLabelRect];
                continueLabel.font = [UIFont boldSystemFontOfSize:13.0f];
                continueLabel.textAlignment = NSTextAlignmentCenter;
                continueLabel.text = @"Tap to continue";
                continueLabel.alpha = 0.0f;
                continueLabel.backgroundColor = [UIColor whiteColor];
                [self addSubview:continueLabel];
                self.continueLabel = continueLabel;
            } else {
                continueLabel.frame = continueLabelRect;
            }
            [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
                continueLabel.alpha = 1.0f;
            } completion:nil];
        } else if (index > 0 && continueLabel != nil) {
            // Otherwise, remove the lbl
            [continueLabel removeFromSuperview];
            continueLabel = nil;
        }
    }
}

#pragma mark - Cleanup

- (void)cleanup
{
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillCleanup:)]) {
        [self.delegate coachMarksViewWillCleanup:self];
    }

    // Fade out self
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove self
                         [self removeFromSuperview];

                         // Delegate (coachMarksViewDidCleanup:)
                         if ([self.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                             [self.delegate coachMarksViewDidCleanup:self];
                         }
                     }];
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // Delegate (coachMarksView:didNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
        [self.delegate coachMarksView:self didNavigateToIndex:self.currentIndex.integerValue];
    }
}

- (NSInteger)dataSourceNumberOfCoachMarks
{
    if ([self.dataSource respondsToSelector:@selector(numberOfCoachMarksInView:)]) {
        return [self.dataSource numberOfCoachMarksInView:self];
    } else {
        return 0;
    }
}

- (CGRect)dataSourceRectAtIndex:(NSInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(coachMarksView:rectAtIndex:)]) {
        return [self.dataSource coachMarksView:self rectAtIndex:index];
    } else {
        return CGRectNull;
    }
}

- (NSString *)dataSourceCaptionAtIndex:(NSInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(coachMarksView:captionAtIndex:)]) {
        return [self.dataSource coachMarksView:self captionAtIndex:index];
    } else {
        return nil;
    }
}

@end

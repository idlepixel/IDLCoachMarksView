//
//  WSCoachMarksView.m
//  Version 0.2
//
//  Created by Dimitry Bentsionov on 4/1/13.
//  Copyright (c) 2013 Workshirt, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IDLCoachMarksView.h"

static const CGFloat kIDLCoachMarksViewDefaultAnimationDuration = 0.3f;
static const CGFloat kIDLCoachMarksViewDefaultCutoutRounding = 2.0f;
static const CGFloat kIDLCoachMarksViewDefaultCutoutPadding = 30.0f;
static const CGFloat kIDLCoachMarksViewDefaultMaximumLabelWidth = 230.0f;
static const CGFloat kIDLCoachMarksViewDefaultLabelSpacing = 35.0f;
static const BOOL kEnableContinueLabel = YES;


CG_INLINE CGFloat IDLCoachMarkViewCGSizeArea(CGSize size)
{
    return size.width * size.height;
}

@interface IDLCoachMarksView ()

@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) CAShapeLayer *mask;
@property (nonatomic, strong) UILabel *continueLabel;

@property (nonatomic, strong) NSNumber *currentIndex;

@property (nonatomic, assign) CGRect lastBounds;

@end

@implementation IDLCoachMarksView

+ (CGRect)rectContainingViews:(NSArray *)viewArray relativeToView:(UIView *)referenceView
{
    CGRect result = CGRectNull;
    
    if (referenceView != nil && viewArray.count > 0) {
        
        UIView *view = nil;
        for (NSInteger i = 0; i < viewArray.count; i++) {
            if ([[viewArray objectAtIndex:i] isKindOfClass:[UIView class]]) {
                view = [viewArray objectAtIndex:i];
                if (view.window == referenceView.window) {
                    CGRect viewRect = [referenceView convertRect:view.bounds fromView:view];
                    if (!CGRectEqualToRect(viewRect, CGRectNull) && IDLCoachMarkViewCGSizeArea(viewRect.size) > 0.0f) {
                        if (CGRectEqualToRect(result, CGRectNull)) {
                            result = viewRect;
                        } else {
                            result = CGRectUnion(result, viewRect);
                        }
                    }
                }
            }
        }
        
    }
    return result;
}

+ (CGRect)rectContainingView:(UIView *)view relativeToView:(UIView *)referenceView
{
    NSArray *viewArray = nil;
    if (view != nil) {
        viewArray = @[view];
    }
    return [[self class] rectContainingViews:viewArray relativeToView:referenceView];
}

- (CGRect)rectContainingViews:(NSArray *)viewArray
{
    return [[self class] rectContainingViews:viewArray relativeToView:self];
}

- (CGRect)rectContainingView:(UIView *)view
{
    return [[self class] rectContainingView:view relativeToView:self];
}

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
    self.animationDuration = kIDLCoachMarksViewDefaultAnimationDuration;
    self.cutoutRounding = kIDLCoachMarksViewDefaultCutoutRounding;
    self.cutoutPadding = kIDLCoachMarksViewDefaultCutoutPadding;
    self.maximumLabelWidth = kIDLCoachMarksViewDefaultMaximumLabelWidth;
    self.labelSpacing = kIDLCoachMarksViewDefaultLabelSpacing;
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
    
    CGRect bounds = self.bounds;
    if (!CGRectEqualToRect(self.lastBounds, bounds)) {
        self.lastBounds = bounds;
        if (self.currentIndex && self.currentIndex.integerValue >= 0) {
            [self showCoachMarkAtIndex:self.currentIndex.integerValue animated:NO];
        }
    }
}

#pragma mark - Cutout modify

- (UIBezierPath *)maskPathForCutout:(CGRect)cutout
{
    NSLog(@"cutout: %@",NSStringFromCGRect(cutout));
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    if (IDLCoachMarkViewCGSizeArea(cutout.size) > 0.0f) {
        CGFloat padding = self.cutoutPadding;
        if (padding != 0.0f) {
            cutout = CGRectInset(cutout, -padding, -padding);
            NSLog(@"cutout inset: %@",NSStringFromCGRect(cutout));
        }
        if (IDLCoachMarkViewCGSizeArea(cutout.size) > 0.0f) {
            UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:cutout cornerRadius:self.cutoutRounding];
            [maskPath appendPath:cutoutPath];
        }
    }
    return maskPath;
}

- (void)setCutoutToRect:(CGRect)rect
{
    // Define shape
    UIBezierPath *maskPath = [self maskPathForCutout:rect];

    // Set the new path
    self.mask.path = maskPath.CGPath;
}

- (void)animateCutoutToRect:(CGRect)rect
{
    // Define shape
    UIBezierPath *maskPath = [self maskPathForCutout:rect];
    
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

- (void)cleanupCutout
{
    [self animateCutoutToRect:self.bounds];
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
    [self showCoachMarkAtIndex:index animated:YES];
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
                         [self showCoachMarkAtIndex:0 animated:YES];
                     }];
}

- (void)showCoachMarkAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSLog(@"index: %i",index);
    
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
    
    NSLog(@"markRect: %@",NSStringFromCGRect(markRect));
    
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
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.captionLabel.alpha = 1.0f;
    }];
    
    // If first mark, set the cutout to the center of first mark
    if (animated) {
        if (index == 0) {
            CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
            CGRect centerZero = (CGRect){center, {1.0f,1.0f}};
            [self setCutoutToRect:centerZero];
        }
        
        // Animate the cutout
        [self animateCutoutToRect:markRect];
    } else {
        [self setCutoutToRect:markRect];
    }
    
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
            [UIView animateWithDuration:self.animationDuration delay:1.0f options:0 animations:^{
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
    [self cleanupCutout];
    
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

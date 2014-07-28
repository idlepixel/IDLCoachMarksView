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
static const CGFloat kIDLCoachMarksViewDefaultCutoutPadding = 2.0f;
static const CGFloat kIDLCoachMarksViewDefaultCutoutCaptionMargin = 20.0f;

CG_INLINE CGFloat IDLCoachMarkViewCGSizeArea(CGSize size)
{
    return size.width * size.height;
}

@interface IDLCoachMarksShowData : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL animated;

@end

@implementation IDLCoachMarksShowData

@end

@interface IDLCoachMarksView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) CAShapeLayer *maskShapeLayer;
@property (nonatomic, strong) UILabel *continuePromptLabel;

@property (nonatomic, strong) NSNumber *currentIndex;

@property (nonatomic, assign) CGRect lastBounds;

@property (nonatomic, assign) BOOL delayed;

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

+ (IDLCoachMarksView *)showCoachMarksInView:(UIView *)superview dataSource:(id<IDLCoachMarksViewDataSource>)dataSource delegate:(id<IDLCoachMarksViewDelegate>)delegate
{
    IDLCoachMarksView *coachMarksView = [[IDLCoachMarksView alloc] initCoachMarksInView:superview dataSource:dataSource delegate:delegate];
    [coachMarksView showCoachMarks];
    return coachMarksView;
}

- (id)initCoachMarksInView:(UIView *)superview dataSource:(id<IDLCoachMarksViewDataSource>)dataSource delegate:(id<IDLCoachMarksViewDelegate>)delegate
{
    CGRect bounds = superview.bounds;
    self = [self initWithFrame:bounds];
    if (self) {
        self.dataSource = dataSource;
        self.delegate = delegate;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.alpha = 0;
        self.hidden = YES;
        [superview addSubview:self];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self configure];
    }
    return self;
}

- (void)configure
{
    // Apply appearance defaults
    [self applyAppearanceDefaults:NO];
    
    // Hide until unvoked
    self.hidden = YES;
}

- (void)initializeSubViews
{
    [self cleanSubViews];
    
    // Shape layer mask
    CAShapeLayer *mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[self.maskColor CGColor]];
    [self.layer addSublayer:mask];
    self.maskShapeLayer = mask;
    
    // Capture touches
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    // Captions
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 0.0f)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.textColor = self.captionTitleColor;
    captionLabel.font = self.captionTitleFont;
    captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    captionLabel.numberOfLines = 0;
    captionLabel.textAlignment = NSTextAlignmentCenter;
    captionLabel.alpha = 0.0f;
    [self addSubview:captionLabel];
    self.captionLabel = captionLabel;
}

- (void)cleanSubViews
{
    // Shape layer mask
    if (self.maskShapeLayer) {
        [self.maskShapeLayer removeFromSuperlayer];
        self.maskShapeLayer = nil;
    }
    // Capture touches
    if (self.tapGestureRecognizer) {
        [self removeGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer = nil;
    }
    // Captions
    if (self.captionLabel) {
        [self.captionLabel removeFromSuperview];
        self.captionLabel = nil;
    }
    
    // Continue prompt
    if (self.continuePromptLabel) {
        [self.continuePromptLabel removeFromSuperview];
        self.continuePromptLabel = nil;
    }
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

- (void)applyAppearanceDefaults:(BOOL)force
{
    IDLCoachMarksView *appearance = [IDLCoachMarksView appearance];
    
    if (appearance.animationDuration == nil || force) {
        appearance.animationDuration = @(kIDLCoachMarksViewDefaultAnimationDuration);
    }
    if (appearance.cutoutRounding == nil || force) {
        appearance.cutoutRounding = @(kIDLCoachMarksViewDefaultCutoutRounding);
    }
    if (appearance.cutoutPadding == nil || force) {
        appearance.cutoutPadding = @(kIDLCoachMarksViewDefaultCutoutPadding);
    }
    
    if (appearance.cutoutCaptionMargin == nil || force) {
        appearance.cutoutCaptionMargin = @(kIDLCoachMarksViewDefaultCutoutCaptionMargin);
    }
    
    if (appearance.captionTitleFont == nil || force) {
        appearance.captionTitleFont = [UIFont systemFontOfSize:20.0f];
    }
    if (appearance.captionTitleColor == nil || force) {
        appearance.captionTitleColor = [UIColor whiteColor];
    }
    
    if (appearance.continuePrompt == nil || force) {
        appearance.continuePrompt = @"Tap to continue";
    }
    if (appearance.continuePromptTitleFont == nil || force) {
        appearance.continuePromptTitleFont = [UIFont boldSystemFontOfSize:13.0f];
    }
    if (appearance.continuePromptTitleColor == nil || force) {
        appearance.continuePromptTitleColor = [UIColor blackColor];
    }
    if (appearance.continuePromptBackgroundColor == nil || force) {
        appearance.continuePromptBackgroundColor = [UIColor whiteColor];
    }
    if (appearance.continuePromptHeight == nil || force) {
        appearance.continuePromptHeight = @(30.0f);
    }
    if (appearance.continuePromptEnabled == nil || force) {
        appearance.continuePromptEnabled = @(YES);
    }
    
    if (appearance.maskColor == nil || force) {
        appearance.maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.85f];
    }
}

#pragma mark - Cutout modify

- (CGRect)applyCutoutPadding:(CGRect)cutout
{
    CGFloat padding = self.cutoutPadding.floatValue;
    if (padding != 0.0f) {
        cutout = CGRectInset(cutout, -padding, -padding);
    }
    return cutout;
}

- (UIBezierPath *)maskPathForCutout:(CGRect)cutout
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    if (IDLCoachMarkViewCGSizeArea(cutout.size) > 0.0f) {
        UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:cutout cornerRadius:self.cutoutRounding.floatValue];
        [maskPath appendPath:cutoutPath];
    }
    return maskPath;
}

- (void)setCutoutToRect:(CGRect)rect
{
    [self animateCutoutToRect:rect duration:0.01f notify:NO];
}

- (void)animateCutoutToRect:(CGRect)rect
{
    [self animateCutoutToRect:rect duration:self.animationDuration.floatValue notify:YES];
}

#define kAnimationKeyPath       @"path"

- (void)animateCutoutToRect:(CGRect)rect duration:(NSTimeInterval)duration notify:(BOOL)notify
{
    CGRect cutout = [self applyCutoutPadding:rect];
    
    // Define shape
    UIBezierPath *maskPath = [self maskPathForCutout:cutout];
    
    // Animate it
    CAShapeLayer *mask = self.maskShapeLayer;
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:kAnimationKeyPath];
    if (notify) anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:kAnimationKeyPath];
    mask.path = maskPath.CGPath;
    mask.fillColor = self.maskColor.CGColor;
}

- (void)cleanupCutout
{
    [self animateCutoutToRect:self.bounds duration:self.animationDuration.floatValue notify:NO];
}

#pragma mark - Mask color

- (void)setMaskColor:(UIColor *)maskColor
{
    _maskColor = maskColor;
    [self.maskShapeLayer setFillColor:[maskColor CGColor]];
}

#pragma mark - Touch handler

- (void)userDidTap:(UITapGestureRecognizer *)recognizer
{
    if (!self.delayed) {
        // Go to the next coach mark
        NSInteger index = 0;
        if (self.currentIndex) {
            index = self.currentIndex.integerValue + 1;
        }
        [self showCoachMarkAtIndex:index animated:YES];
    }
}

#pragma mark - Navigation

- (void)showCoachMarks
{
    [self initializeSubViews];
    
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    [UIView animateWithDuration:self.animationDuration.floatValue
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
    // Out of bounds
    if (index >= [self dataSourceNumberOfCoachMarks]) {
        [self cleanup];
        return;
    }
    
    NSTimeInterval delay = 0.0f;
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndexWithDelay:)]) {
        delay = [self.delegate coachMarksView:self willNavigateToIndexWithDelay:index];
    } else if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:index];
    }
    
    IDLCoachMarksShowData *showData = [IDLCoachMarksShowData new];
    showData.index = index;
    showData.animated = animated;
    
    if (delay == 0.0f) {
        [self delayedShowCoachMark:showData];
    } else {
        self.delayed = YES;
        [self performSelector:@selector(delayedShowCoachMark:) withObject:showData afterDelay:delay];
    }
}


- (void)delayedShowCoachMark:(IDLCoachMarksShowData *)showData
{
    self.delayed = NO;
    
    // Current index
    self.currentIndex = @(showData.index);
    
    // Coach mark definition
    NSString *markCaption = [self dataSourceCaptionAtIndex:showData.index];
    CGRect markRect = [self dataSourceRectAtIndex:showData.index];

    CGRect bounds = self.bounds;
    
    CGFloat maximumLabelWidth;
    if (self.maximumLabelWidth) {
        maximumLabelWidth = self.maximumLabelWidth.floatValue;
    } else {
        maximumLabelWidth = bounds.size.width - 10.0f;
    }
    
    // Calculate the caption position and size
    UILabel *captionLabel = self.captionLabel;
    captionLabel.textColor = self.captionTitleColor;
    captionLabel.font = self.captionTitleFont;
    captionLabel.alpha = 0.0f;
    captionLabel.frame = CGRectMake(0.0f, 0.0f, maximumLabelWidth, 0.0f);
    captionLabel.text = markCaption;
    [captionLabel sizeToFit];
    CGFloat cutoutCaptionMargin = self.cutoutCaptionMargin.floatValue;
    CGFloat y = markRect.origin.y + markRect.size.height + cutoutCaptionMargin;
    CGFloat bottomY = y + captionLabel.frame.size.height + cutoutCaptionMargin;
    if (bottomY > bounds.size.height) {
        y = markRect.origin.y - cutoutCaptionMargin - captionLabel.frame.size.height;
    }
    CGFloat x = floorf((bounds.size.width - captionLabel.frame.size.width) / 2.0f);
    
    // Animate the caption label
    captionLabel.frame = (CGRect){{x, y}, captionLabel.frame.size};
    [UIView animateWithDuration:self.animationDuration.floatValue animations:^{
        captionLabel.alpha = 1.0f;
    }];
    
    // If first mark, set the cutout to the center of first mark
    if (showData.animated) {
        if (showData.index == 0) {
            CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
            CGRect centerZero = (CGRect){center, {1.0f,1.0f}};
            [self setCutoutToRect:centerZero];
        }
        
        // Animate the cutout
        [self animateCutoutToRect:markRect];
    } else {
        [self setCutoutToRect:markRect];
    }
    
    // Show continue label if first mark
    BOOL removeContinuePrompt = !self.continuePromptEnabled.boolValue;
    if (!removeContinuePrompt) {
        UILabel *continuePromptLabel = self.continuePromptLabel;
        if (index == 0) {
            CGFloat continuePromptHeight = self.continuePromptHeight.floatValue;
            CGRect continuePromptLabelRect = CGRectMake(0.0f, bounds.size.height - continuePromptHeight, bounds.size.width, continuePromptHeight);
            if (continuePromptLabel == nil) {
                continuePromptLabel = [[UILabel alloc] initWithFrame:continuePromptLabelRect];
                continuePromptLabel.textAlignment = NSTextAlignmentCenter;
                continuePromptLabel.alpha = 0.0f;
                [self addSubview:continuePromptLabel];
                self.continuePromptLabel = continuePromptLabel;
            } else {
                continuePromptLabel.frame = continuePromptLabelRect;
            }
            continuePromptLabel.font = self.continuePromptTitleFont;
            continuePromptLabel.text = self.continuePrompt;
            continuePromptLabel.textColor = self.continuePromptTitleColor;
            continuePromptLabel.backgroundColor = self.continuePromptBackgroundColor;
            [UIView animateWithDuration:self.animationDuration.floatValue delay:1.0f options:0 animations:^{
                continuePromptLabel.alpha = 1.0f;
            } completion:nil];
        } else if (index > 0 && continuePromptLabel != nil) {
            // Otherwise, remove the lbl
            removeContinuePrompt = YES;
        }
    }
    if (removeContinuePrompt) {
        [self.continuePromptLabel removeFromSuperview];
        self.continuePromptLabel = nil;
    }
}

#pragma mark - Cleanup

- (void)cleanup
{
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillCleanup:)]) {
        [self.delegate coachMarksViewWillCleanup:self];
    }
    self.currentIndex = nil;
    [self cleanupCutout];
    
    // Fade out self
    [UIView animateWithDuration:self.animationDuration.floatValue
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         
                         self.hidden = YES;
                         [self cleanSubViews];

                         // Delegate (coachMarksViewDidCleanup:)
                         if ([self.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                             [self.delegate coachMarksViewDidCleanup:self];
                         }
                     }];
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished
{
    if (finished) {
        if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
            [self.delegate coachMarksView:self didNavigateToIndex:self.currentIndex.integerValue];
        }
    }
}

#pragma mark - IDLCoachMarksViewDataSource

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

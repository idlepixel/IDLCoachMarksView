//
//  ViewController.m
//  IDLCoachMarksViewExample
//
//  Created by Trystan Pfluger on 26/07/2014.
//  Copyright (c) 2014 Idlepixel. All rights reserved.
//

#import "ExampleViewController.h"

#import "IDLCoachMarksView.h"

@interface ExampleViewController () <IDLCoachMarksViewDataSource, IDLCoachMarksViewDelegate>

@property (nonatomic, strong) IDLCoachMarksView *coachMarksView;

@end

@implementation ExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIColor *coachTintColor = [UIColor colorWithRed:0.15f green:0.40f blue:0.8f alpha:1.0f];
    
    IDLCoachMarksView *appearance = [IDLCoachMarksView appearance];
    appearance.captionTitleColor = [UIColor whiteColor];
    appearance.captionTitleFont = [UIFont italicSystemFontOfSize:14.0f];
    appearance.cutoutPadding = @(4.0f);
    
    appearance.maskColor = [coachTintColor colorWithAlphaComponent:0.9f];
    
    appearance.continuePromptTitleColor = coachTintColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
- (IBAction)actionShowCoachMarks:(id)sender
{
    CGRect bounds = self.view.bounds;
    if (self.coachMarksView == nil) {
        IDLCoachMarksView *view = [[IDLCoachMarksView alloc] initWithFrame:bounds];
        view.dataSource = self;
        view.delegate = self;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.coachMarksView = view;
    }
    self.coachMarksView.alpha = 0;
    
    self.coachMarksView.frame = self.tabBarController.view.bounds;
    [self.tabBarController.view addSubview:self.coachMarksView];
    
    [self.coachMarksView showCoachMarks];
}

#pragma mark - IDLCoachMarksViewDataSource

- (NSInteger)numberOfCoachMarksInView:(IDLCoachMarksView *)view
{
    return 6;
}

- (CGRect)coachMarksView:(IDLCoachMarksView *)view rectAtIndex:(NSInteger)index
{
    NSArray *views = nil;
    switch (index) {
        case 0:
            views = @[self.textField];
            break;
            
        case 1:
            views = @[self.textField,self.textFieldLabel];
            break;
            
        case 2:
            views = @[self.slider];
            break;
            
        case 3:
            views = @[self.showCoachMarksButton];
            break;
            
        case 4:
            views = @[self.textField,self.textFieldLabel,self.slider,self.showCoachMarksButton];
            break;
            
        case 5:
            views = @[self.tabBarController.tabBar];
            break;
            
        default:
            break;
    }
    return [view rectContainingViews:views];
}

- (NSString *)coachMarksView:(IDLCoachMarksView *)view captionAtIndex:(NSInteger)index
{
    NSString *caption = nil;
    switch (index) {
        case 0:
            caption = @"This is an input text field. You can enter text here by selecting it.";
            break;
            
        case 1:
            caption = @"This is a labelled text field.";
            break;
            
        case 2:
            caption = @"This is an input slider.";
            break;
            
        case 3:
            caption = @"This is the button that activates the coach marks.";
            break;
            
        case 4:
            caption = @"This is a collection of views.";
            break;
            
        case 5:
            caption = @"This is the app's tab bar. The other tabs have other coach mark usage examples. Tap the screen again to return to the app.";
            break;
            
        default:
            break;
    }
    return caption;
}

#pragma mark - IDLCoachMarksViewDelegate

- (void)coachMarksView:(IDLCoachMarksView*)coachMarksView willNavigateToIndex:(NSInteger)index
{
    NSLog(@"coachMarksView:%@<%p> willNavigateToIndex:%i",coachMarksView.class,coachMarksView,index);
}

- (void)coachMarksView:(IDLCoachMarksView*)coachMarksView didNavigateToIndex:(NSInteger)index
{
    NSLog(@"coachMarksView:%@<%p> didNavigateToIndex:%i",coachMarksView.class,coachMarksView,index);
}

- (void)coachMarksViewWillCleanup:(IDLCoachMarksView*)coachMarksView
{
    NSLog(@"coachMarksViewWillCleanup:%@<%p>",coachMarksView.class,coachMarksView);
}

- (void)coachMarksViewDidCleanup:(IDLCoachMarksView*)coachMarksView
{
    NSLog(@"coachMarksViewDidCleanup:%@<%p>",coachMarksView.class,coachMarksView);
}


@end

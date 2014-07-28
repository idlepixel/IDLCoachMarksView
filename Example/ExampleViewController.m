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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.coachMarksView.frame = self.view.bounds;
}
*/
 
- (IBAction)actionShowCoachMarks:(id)sender
{
    
    if (self.coachMarksView == nil) {
        IDLCoachMarksView *view = [[IDLCoachMarksView alloc] initWithFrame:self.view.bounds];
        view.dataSource = self;
        view.delegate = self;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.coachMarksView = view;
        
    }
    self.coachMarksView.alpha = 0;
    
    [self.view addSubview:self.coachMarksView];
    
    [self.coachMarksView showCoachMarks];
}

#pragma mark - IDLCoachMarksViewDataSource

- (NSInteger)numberOfCoachMarksInView:(IDLCoachMarksView *)view
{
    return 4;
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
            views = @[self.textField,self.textFieldLabel,self.slider,self.showCoachMarksButton];
            break;
            
        default:
            break;
    }
    return [view rectContainingViews:views];
}

- (NSString *)coachMarksView:(IDLCoachMarksView *)view captionAtIndex:(NSInteger)index
{
    return @"boop";
}

#pragma mark - IDLCoachMarksViewDelegate




@end

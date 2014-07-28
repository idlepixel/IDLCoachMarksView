//
//  ExampleTableViewController.m
//  IDLCoachMarksViewExample
//
//  Created by Trystan Pfluger on 28/07/2014.
//  Copyright (c) 2014 Idlepixel. All rights reserved.
//

#import "ExampleTableViewController.h"
#import "ExampleTableViewCell.h"

#import "IDLCoachMarksView.h"

@interface ExampleTableViewController () <IDLCoachMarksViewDataSource, IDLCoachMarksViewDelegate>

@property (nonatomic, strong) IDLCoachMarksView *coachMarksView;

@end

@implementation ExampleTableViewController

- (IBAction)actionShowCoachMarks:(id)sender
{
    UIView *superview = self.tabBarController.view;
    if (self.coachMarksView == nil) {
        self.coachMarksView = [[IDLCoachMarksView alloc] initCoachMarksInView:superview dataSource:self delegate:self];
        self.coachMarksView.maskColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.9f];
    }
    self.coachMarksView.alpha = 0;
    self.coachMarksView.frame = superview.bounds;
    
    [self.coachMarksView showCoachMarks];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExampleTableViewCell *cell = (ExampleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"Index: %i,%i",indexPath.section,indexPath.row];
    
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 30.0f;
    
    height += indexPath.row * 5.0f;
    
    return height;
}

-(CGRect)tableRectForIndexPath:(NSIndexPath *)indexPath
{
    CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
    return rect;
}

#pragma mark - IDLCoachMarksViewDataSource

- (NSInteger)numberOfCoachMarksInView:(IDLCoachMarksView *)view
{
    return 4;
}

#define kTopIndexPath       [NSIndexPath indexPathForRow:3 inSection:0]
#define kBottomIndexPath    [NSIndexPath indexPathForRow:7 inSection:2]

- (CGRect)coachMarksView:(IDLCoachMarksView *)view rectAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        case 3:
            return [view rectContainingView:self.showCoachMarksButton];
            break;
            
        case 1: {
            CGRect rect = [self tableRectForIndexPath:kTopIndexPath];
            return [view convertRect:rect fromView:self.tableView];
        }
            break;
            
        case 2: {
            CGRect rect = [self tableRectForIndexPath:kBottomIndexPath];
            return [view convertRect:rect fromView:self.tableView];
        }
            break;
            
        default:
            break;
    }
    return CGRectZero;
}

- (NSString *)coachMarksView:(IDLCoachMarksView *)view captionAtIndex:(NSInteger)index
{
    NSString *caption = nil;
    switch (index) {
        case 0:
        case 3:
            caption = @"This is the button that activates the coach marks.";
            break;
            
        case 1:
            caption = [NSString stringWithFormat:@"This is a table cell at {%i,%i}.",kTopIndexPath.section,kTopIndexPath.row];
            break;
            
        case 2:
            caption = [NSString stringWithFormat:@"This is a table cell at {%i,%i}.",kBottomIndexPath.section,kBottomIndexPath.row];
            break;
            
        default:
            break;
    }
    return caption;
}

#pragma mark - IDLCoachMarksViewDelegate

- (NSTimeInterval)coachMarksView:(IDLCoachMarksView*)coachMarksView willNavigateToIndexWithDelay:(NSInteger)index
{
    if (index == 1) {
        [self.tableView scrollToRowAtIndexPath:kTopIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    } else if (index == 2) {
        [self.tableView scrollToRowAtIndexPath:kBottomIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        return 0.3f;
    } else if (index == 3) {
        [self.tableView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f) animated:YES];
        return 0.3f;
    }
    return 0.0f;
}

@end

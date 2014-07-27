//
//  ViewController.h
//  IDLCoachMarksViewExample
//
//  Created by Trystan Pfluger on 26/07/2014.
//  Copyright (c) 2014 Idlepixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExampleViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *textFieldLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIButton *showCoachMarksButton;

- (IBAction)actionShowCoachMarks:(id)sender;

@end

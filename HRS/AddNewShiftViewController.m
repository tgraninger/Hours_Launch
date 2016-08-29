//
//  AddEventViewController.m
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "AddNewShiftViewController.h"

@interface AddNewShiftViewController ()
@property (nonatomic, retain) DAO *dao;
@property BOOL handlingOutTimeForCurrentShift;
@end

@implementation AddNewShiftViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  if (!self.currentShift) {
    self.handlingOutTimeForCurrentShift = NO;
    self.currentShift = [[ShiftObject alloc]init];
  } else if (!self.currentShift.endTime) {
    self.handlingOutTimeForCurrentShift = YES;
    self.startLabel.text = self.currentShift.startTime;
  }
}

- (IBAction)clockedInOrOut:(id)sender {
  if (self.handlingOutTimeForCurrentShift) {
    [[DAO sharedInstance]recordCurrentTimeForClockOutForShift:self.currentShift forJob:self.currentJob];
  } else {
    [[DAO sharedInstance]addNewShiftForJob:self.currentJob];
  }
}



- (void)styleButtons {
//  NSArray *buttons = [NSArray arrayWithObjects:self.eventNameField, self.eventDate, self.callTime, self.outtime, nil];
//  for (UITextField *field in buttons) {
//    CALayer *border = [CALayer layer];
//    CGFloat borderWidth = 1.0;
//    border.frame = CGRectMake(0, field.frame.size.height - borderWidth, field.frame.size.width, field.frame.size.height);
//    border.borderWidth = borderWidth;
//    border.borderColor = [[UIColor blueColor]CGColor];
//    [field.layer addSublayer:border];
//    [field.layer setMasksToBounds:YES];
//    if (field.tag > 0) {
//      [self.datePicker removeFromSuperview];
//      [field setInputView:self.datePicker];
//    }
//  }
}

- (IBAction)addEvent:(id)sender {
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end

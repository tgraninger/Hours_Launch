//
//  EventDetailsViewController.m
//  HRS
//
//  Created by Thomas on 7/18/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "ShiftDetailsViewController.h"
#import "NSDate+NSDate_StringMethods.h"

@interface ShiftDetailsViewController ()

@end

@implementation ShiftDetailsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSArray *labels = @[self.dateLabel, self.hoursLabel, self.startLabel, self.outLabel];
  for (UILabel *label in labels) {
    CALayer *layer = [label layer];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, label.frame.size.height-1, label.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor blueColor].CGColor];
    [layer addSublayer:bottomBorder];
  }
  [self displayDetailsForShift];
}

- (void)displayDetailsForShift {
  self.dateLabel.text = [self.selectedShift.startTime getStartDate:self.selectedShift.startTime];
  self.startLabel.text = [self.selectedShift.startTime getStartTime:self.selectedShift.startTime];
  self.outLabel.text = [self.selectedShift.endTime getEndTime:self.selectedShift.endTime];
  double hours = [[[DAO sharedInstance]hoursBetween:self.selectedShift.startTime and:self.selectedShift.endTime]doubleValue];
  self.hoursLabel.text = [NSString stringWithFormat:@"%.2f", hours];
  self.payLabel.text = [NSString stringWithFormat:@"%@", [[DAO sharedInstance]calculatePay:self.selectedShift]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  EventDetailsViewController.m
//  HRS
//
//  Created by Thomas on 7/18/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

/*
 Enable users to edit shifts... Add UIDatePicker.
 */

#import "ShiftDetailsViewController.h"
#import "NSDate+NSDate_StringMethods.h"
#import "EditShiftViewController.h"

@interface ShiftDetailsViewController ()

@end

@implementation ShiftDetailsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
	
	[self displayDetailsForShift];

	
//  NSArray *labels = @[self.dateLabel, self.hoursLabel, self.startLabel, self.outLabel];
//  for (UILabel *label in labels) {
//    CALayer *layer = [label layer];
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
//    bottomBorder.borderWidth = 1;
//    bottomBorder.frame = CGRectMake(-1, label.frame.size.height-1, label.frame.size.width, 1);
//    [bottomBorder setBorderColor:[UIColor blueColor].CGColor];
//    [layer addSublayer:bottomBorder];
//  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:YES];
  [self displayDetailsForShift];
}

//- (void)passDataToParent:(Shift *)shift {
//  self.selectedShift = shift;
//  [self displayDetailsForShift];
//}

- (void)displayDetailsForShift {
	
	self.dateLabel.text = [self.selectedShift.startTime getStartDate:self.selectedShift.startTime];
	self.startLabel.text = [self.selectedShift.startTime getStartTime:self.selectedShift.startTime];
	self.outLabel.text = [self.selectedShift.endTime getEndTime:self.selectedShift.endTime];
	double hours = [[[DAO sharedInstance]hoursBetween:self.selectedShift.startTime and:self.selectedShift.endTime]doubleValue];
	self.hoursLabel.text = [NSString stringWithFormat:@"%.2f", hours];
	if (self.selectedJob.hourlyWage) {
	self.payLabel.text = [NSString stringWithFormat:@"$%.2f", [[[DAO sharedInstance]calculateShiftPay:self.selectedShift
																							   forJob:self.selectedJob]doubleValue]];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  EditShiftViewController *esvc = (EditShiftViewController *)segue.destinationViewController;
  esvc.shiftToEdit = self.selectedShift;
  esvc.shiftDetailsViewController = self;
//  esvc.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  AddEventViewController.m
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "AddNewShiftViewController.h"
#import "NSDate+NSDate_StringMethods.h"

@interface AddNewShiftViewController ()

@property (nonatomic, retain) DAO *dao;

@end

@implementation AddNewShiftViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.dao = [DAO sharedInstance];
  [self handleIncompleteShift];
  [self setupJobPicker];
  [self setupLabels];
  [self styleButtons];
}

- (void)handleIncompleteShift {
  if (self.dao.hasIncompleteShifts) {
    self.handlingOutTimeForCurrentShift = YES;
    self.currentShift = [self.dao.incompleteShifts objectAtIndex:0];
  } else {
    self.handlingOutTimeForCurrentShift = NO;
  }
}

- (void)setupJobPicker {
  [self checkIfHardcodedJobDetails];
  [self.jobPicker setHidden:NO];
  [self.jobPicker setDelegate:self];
  [self.jobPicker setDataSource:self];
}

- (BOOL)checkIfHardcodedJobDetails {
  if ([self.currentJob.jobTitle isEqualToString:@"JobTitle"] || [self.currentJob.employer isEqualToString:@"Employer"]) {
    return YES;
  } else {
    return NO;
  }
}

- (void)setupLabels {
  if (self.handlingOutTimeForCurrentShift) {
    [self completingExistingShift];
  } else {
    [self creatingNewShift];
  }
}

- (void)creatingNewShift {
  [self.dateTitleLabel setHidden:YES];
  [self.startTitleLabel setHidden:YES];
  [self.endTitleLabel setHidden:YES];
  [self.dateLabel setHidden:YES];
  [self.startLabel setHidden:YES];
  [self.endLabel setHidden:YES];
  [self.useCurrentTime setTitle:@"Clock in with current time" forState:UIControlStateNormal];
  [self.selectTime setTitle:@"Clock in manually" forState:UIControlStateNormal];
}

- (void)completingExistingShift {
  [self.startLabel setHidden:NO];
  [self.dateLabel setHidden:NO];
  [self.startTitleLabel setHidden:NO];
  [self.dateTitleLabel setHidden:NO];
  [self.jobPickerTitleLabel setText:@"Ready to clock out!"];
  [self.dateTitleLabel setText:@"Date of shift:"];
  [self.dateLabel setText:[self.currentShift.startTime getStartDate:self.currentShift.startTime]];
  [self.startLabel setText:[self.currentShift.startTime getStartTime:self.currentShift.startTime]];
  [self.useCurrentTime setTitle:@"Clock out with current time" forState:UIControlStateNormal];
  [self.selectTime setTitle:@"Clock out manually" forState:UIControlStateNormal];
}

- (IBAction)clockedInOrOut:(id)sender {
  if (self.handlingOutTimeForCurrentShift) {
    [self clockOutOfExistingShift];
    [self performSegueWithIdentifier:@"showShiftDetailsAfterCompleted" sender:self];
  } else {
    [self createShiftWithStartDate];
  }
}

- (void)createShiftWithStartDate {
  [self setHandlingOutTimeForCurrentShift:YES];
  self.currentShift = [self.dao addNewShiftForJob:self.currentJob startDate:[self.dao getCurrentDate]];
  [self completingExistingShift];
}

- (void)clockOutOfExistingShift {
  [self setHandlingOutTimeForCurrentShift:NO];
  [self.dao completeShift:self.currentShift endDate:[self.dao getCurrentDate]];
  [self creatingNewShift];
}

- (void)nullifyTextFields {
  self.dateLabel = nil;
  self.startLabel = nil;
  self.endLabel = nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.dao.managedJobs.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  NSString *str;
  if ([self checkIfHardcodedJobDetails]) {
    [self.jobPickerTitleLabel setText:@"Tap settings to update your job details"];
    str = @"My Job";
  } else {
    str = [NSString stringWithFormat:@"%@: %@", [[self.dao.managedJobs objectAtIndex:row]employer], [[self.dao.managedJobs objectAtIndex:row]jobTitle]];
  }
  return str;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return 20;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  self.currentJob = [self.dao.managedJobs objectAtIndex:row];
  NSLog(@"current job : %@",self.currentJob);
}

- (void)styleButtons {
  NSArray *buttons = [NSArray arrayWithObjects:self.useCurrentTime, self.selectTime, nil];
  for (UITextField *button in buttons) {
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1.0;
    border.frame = CGRectMake(0, 0, button.frame.size.width, button.frame.size.height);
    border.borderWidth = borderWidth;
    border.borderColor = [[UIColor blueColor]CGColor];
    [button.layer addSublayer:border];
    [button.layer setMasksToBounds:YES];
    [button sizeToFit];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end

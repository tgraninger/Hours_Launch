//
//  AddEventViewController.m
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

/*
 Needs UIDatePicker to select time manually...
 */

#import "AddNewShiftViewController.h"
#import "NSDate+NSDate_StringMethods.h"

@interface AddNewShiftViewController ()

@property (nonatomic, retain) DAO *dao;

@end

@implementation AddNewShiftViewController
{
  UIDatePicker *datePicker;
  UIBarButtonItem *doneButton;
}

- (void)viewDidLoad {
   [super viewDidLoad];
    self.dao = [DAO sharedInstance];
    [self setupJobPicker];
    [self setupLabels];
    [self styleButtons];
    self.currentJob = [self.dao.managedJobs objectAtIndex:0];
    self.currentShift = [self.dao checkForIncompleteShiftForJob:self.currentJob];
    [self handleIncompleteShift];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:YES];
  [self.jobPicker reloadComponent:0];
}

- (void)handleIncompleteShift {
  if (self.currentShift) {
    self.handlingOutTimeForCurrentShift = YES;
      [self completingExistingShift];
  } else {
    self.handlingOutTimeForCurrentShift = NO;
    [self creatingNewShift];
  }
}

- (void)setupJobPicker {
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.currentJob = [self.dao.managedJobs objectAtIndex:[self.jobPicker selectedRowInComponent:0]];
	self.currentShift = [self.dao checkForIncompleteShiftForJob:self.currentJob];
	[self handleIncompleteShift];
}

- (void)styleButtons {
	NSArray *buttons = [NSArray arrayWithObjects:self.useCurrentTime, self.selectTime, nil];
	for (UITextField *button in buttons) {
		[button.layer setBorderWidth:1.0];
		[button.layer setBorderColor:[[UIColor blueColor]CGColor]];
		[button.layer setMasksToBounds:YES];
		[button sizeToFit];
	}
}

- (void)creatingNewShift {
  [self.dateTitleLabel setHidden:YES];
  [self.startTitleLabel setHidden:YES];
  [self.endTitleLabel setHidden:YES];
  [self.dateLabel setHidden:YES];
  [self.startLabel setHidden:YES];
  [self.endLabel setHidden:YES];
  [self.jobPickerTitleLabel setText:@"Ready to clock in!"];
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
  } else {
    [self createShiftWithStartDate];
  }
}

- (void)popToHistoryView {
  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  ShiftDetailsViewController *sdvc = (ShiftDetailsViewController *)[sb instantiateViewControllerWithIdentifier:@"shiftDetails"];
  sdvc.selectedJob = self.currentJob;
  sdvc.selectedShift = self.currentShift;
  self.currentShift = nil;
  [self.navigationController pushViewController:sdvc animated:YES];
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
  [self popToHistoryView];
}

#pragma mark - DatePickerViewMethods

- (IBAction)manuallySelectTime:(id)sender {
	[self.useCurrentTime setHidden:YES];
	[self.selectTime setHidden:YES];
	datePicker = [[UIDatePicker alloc] init];
	[datePicker addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
	CGRect screenRect = [self.view frame];
	CGSize pickerSize = [datePicker sizeThatFits:CGSizeZero];
	CGRect pickerRect = CGRectMake(0.0,
								   screenRect.origin.y + screenRect.size.height - pickerSize.height,
								   pickerSize.width,
								   pickerSize.height);
	datePicker.frame = pickerRect;
	[self.view addSubview:datePicker];
	if (doneButton == nil){
		doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(dateSelected:)];
	}
	self.navigationItem.rightBarButtonItem = doneButton;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
								   initWithTarget:self
								   action:@selector(dismissPicker)];
	[self.view addGestureRecognizer:tap];
}

- (void)datePickerDateChanged:(UIDatePicker *)dp{
	
}

- (void)dateSelected:(id)sender {
	if (self.handlingOutTimeForCurrentShift) {
		[self setHandlingOutTimeForCurrentShift:NO];
		[self.dao completeShift:self.currentShift endDate:datePicker.date];
		[self creatingNewShift];
		[self popToHistoryView];
	} else {
		[self setHandlingOutTimeForCurrentShift:YES];
		self.currentShift = [self.dao addNewShiftForJob:self.currentJob startDate:datePicker.date];
		[self completingExistingShift];
	}
	self.navigationItem.rightBarButtonItem = nil;
	[self.useCurrentTime setHidden:NO];
	[self.selectTime setHidden:NO];
	[datePicker removeFromSuperview];
}

- (void)dismissPicker {
	self.navigationItem.rightBarButtonItem = nil;
	[datePicker removeFromSuperview];
	[self.useCurrentTime setHidden:NO];
	[self.selectTime setHidden:NO];
}

#pragma mark - JobPickerViewDelegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.dao.managedJobs.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	if ([self checkIfHardcodedJobDetails]) {
    [self.jobPickerTitleLabel setText:@"Edit job details in job tab."];
	}
	[self handleIncompleteShift];
	return [NSString stringWithFormat:@"%@: %@", [[self.dao.managedJobs objectAtIndex:row]employer], [[self.dao.managedJobs objectAtIndex:row]jobTitle]];;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return 30;
}

@end

//
//  EditShiftViewController.m
//  HRS
//
//  Created by Thomas on 9/28/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "EditShiftViewController.h"

@interface EditShiftViewController ()

@property (nonatomic, retain) DAO *dao;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIToolbar *toolbar;
@end

@implementation EditShiftViewController
{
  NSDate *date1;
  NSDate *date2;
  UITextField *currentField;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.updatedStartTime.delegate = self;
  self.updatedStartTime.tag = 0;
  self.updatedEndTime.delegate = self;
  self.updatedEndTime.tag = 1;
  self.dao = [DAO sharedInstance];
  if (self.shiftToEdit.startTime) {
     self.updatedStartTime.text = [NSString stringWithFormat:@"%@ %@",[self.shiftToEdit.startTime getStartDate:self.shiftToEdit.startTime],[self.shiftToEdit.startTime getStartTime:self.shiftToEdit.startTime]];
  }
  if (self.shiftToEdit.endTime) {
    self.updatedEndTime.text = [NSString stringWithFormat:@"%@ %@",[self.shiftToEdit.endTime getEndDate:self.shiftToEdit.endTime],[self.shiftToEdit.endTime getEndTime:self.shiftToEdit.endTime]];
  }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (textField.tag == 0) {
    currentField = self.updatedStartTime;
  } else if (textField.tag == 1) {
    currentField = self.updatedEndTime;
  }
  self.datePicker = [[UIDatePicker alloc] init];
  self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
  [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
  CGRect screenRect = [self.view frame];
  CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
  CGRect pickerRect = CGRectMake(0.0,
                                 screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                 pickerSize.width,
                                 pickerSize.height);
  self.datePicker.frame = pickerRect;
  textField.inputView = self.datePicker;
  self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
  UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(dismissPicker)];
  NSArray* barItems = [NSArray arrayWithObjects:fixedItem, doneButton, nil];
  [self.toolbar setItems:barItems animated:YES];
  textField.inputAccessoryView = self.toolbar;
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(dismissPicker)];
  [self.view addGestureRecognizer:tap];
  [self.datePicker becomeFirstResponder];
  return YES;
}

- (void)dateChanged:(id)sender {
  NSDate *date = self.datePicker.date;
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"MM/dd/YYYY HH:mm"];
  [currentField setText:[df stringFromDate:date]];
}

- (void)dismissPicker {
  NSDate *date = self.datePicker.date;
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"MM/dd/YYYY HH:mm"];
  [currentField setText:[df stringFromDate:date]];
  [self.toolbar removeFromSuperview];
  [self.datePicker removeFromSuperview];
  [self resignFirstResponder];
//  [self textFieldShouldReturn:currentField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  [self resignFirstResponder];
  return YES;
}

//-(BOOL)textFieldShouldReturn:(UITextField*)textField {
//  NSInteger nextTag = textField.tag + 1;
//  UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
//  if (nextResponder) {
//    [nextResponder becomeFirstResponder];
//  } else {
//    [textField resignFirstResponder];
//  }
//  return NO;
//}

- (IBAction)saveButtonPressed:(id)sender {
  date1 = [self.dao formatStringToDate:self.updatedStartTime.text];
  date2 = [self.dao formatStringToDate:self.updatedEndTime.text];
  self.shiftToEdit = [self.dao editShift:self.shiftToEdit start:date1 end:date2];
  self.shiftDetailsViewController.selectedShift = self.shiftToEdit;
//  [self.delegate passDataToParent:self.shiftToEdit];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

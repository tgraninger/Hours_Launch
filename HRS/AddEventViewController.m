//
//  AddEventViewController.m
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "AddEventViewController.h"

@interface AddEventViewController ()
@property (nonatomic, retain) DAO *dao;
@end

@implementation AddEventViewController
{
  NSDate *date1;
  NSDate *date2;
  UIImage *image;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.dao = [DAO sharedInstance];
  [self styleButtons];
  if (_edit) {
    self.eventNameField.text = self.event.name;
    self.eventDate.text = self.event.date;
    self.callTime.text = self.event.callTime;
    self.outtime.text = self.event.outTime;
    image = [UIImage imageNamed:@"update"];
    [self.submitButton setImage:image forState:UIControlStateNormal];
  } else {
    self.event = [[Events alloc]init];
    image = [UIImage imageNamed:@"plus"];
    [self.submitButton setImage:image forState:UIControlStateNormal];
  }
}

- (void)showPicker {
  self.datePicker = [[UIDatePicker alloc]init];
  [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
  [self.datePicker reloadInputViews];
}

- (void)styleButtons {
  NSArray *buttons = [NSArray arrayWithObjects:self.eventNameField, self.eventDate, self.callTime, self.outtime, nil];
  for (UITextField *field in buttons) {
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1.0;
    border.frame = CGRectMake(0, field.frame.size.height - borderWidth, field.frame.size.width, field.frame.size.height);
    border.borderWidth = borderWidth;
    border.borderColor = [[UIColor blueColor]CGColor];
    [field.layer addSublayer:border];
    [field.layer setMasksToBounds:YES];
    if (field.tag > 0) {
      [self.datePicker removeFromSuperview];
      [field setInputView:self.datePicker];
    }
  }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (textField.tag > 0) {
    [self showPicker];
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(closePicker)];
    NSArray* barItems = [NSArray arrayWithObjects:doneButton, nil];
    [toolBar setItems:barItems animated:YES];
    textField.inputView = self.datePicker;
    textField.inputAccessoryView = toolBar;
  }
  return YES;
}

- (void)closePicker {
  
  [self.datePicker resignFirstResponder];
}

- (void)setDate:(NSDate *)date forField:(UITextField *)textField {
  if (textField.tag == 0) {
    self.event.name = self.eventNameField.text;
    self.eventNameField.text = textField.text;
  } else if (textField.tag == 1) {
    [self showPicker];
    self.eventDate.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date
                                                         dateStyle:NSDateFormatterShortStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    self.event.date = self.eventDate.text;
  } else if (textField.tag == 2) {
    date1 = self.datePicker.date;
    self.callTime.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date
                                                        dateStyle:NSDateFormatterShortStyle
                                                        timeStyle:NSDateFormatterShortStyle];
    self.event.callTime = self.callTime.text;
  } else if (textField.tag == 3) {
    date2 = self.datePicker.date;
    self.outtime.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date
                                                       dateStyle:NSDateFormatterShortStyle
                                                       timeStyle:NSDateFormatterShortStyle];
    NSLog(@"%@",self.outtime.text);
    self.event.outTime = self.outtime.text;
  }
  [self resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  if (textField.tag == 0) {
    self.event.name = self.eventNameField.text ;
    self.eventNameField.text = textField.text;
  } else if (textField.tag == 1) {
    self.eventDate.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date
                                   dateStyle:NSDateFormatterShortStyle
                                   timeStyle:NSDateFormatterShortStyle];
    self.event.date = self.eventDate.text;
  } else if (textField.tag == 2) {
    date1 = self.datePicker.date;
    self.callTime.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date
                                                         dateStyle:NSDateFormatterShortStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    self.event.callTime = self.callTime.text;
  } else if (textField.tag == 3) {
    date2 = self.datePicker.date;
    self.outtime.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date
                                                         dateStyle:NSDateFormatterShortStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    NSLog(@"%@",self.outtime.text);
    self.event.outTime = self.outtime.text;
  }
  [self resignFirstResponder];
  return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
  NSInteger nextTag = textField.tag + 1;
  UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
  if (nextResponder) {
    [nextResponder becomeFirstResponder];
  } else {
    [textField resignFirstResponder];
  }
  return NO;
}

- (IBAction)addEvent:(id)sender {
  self.event.hours = [NSString stringWithFormat:@"%.02f",[self.dao hoursBetween:date1 and:date2]];
  if (_edit) {
    [self.dao editEvent:self.event];
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self.navigationController popViewControllerAnimated:YES];
    [self.dao addNewEvent:self.event];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}




@end

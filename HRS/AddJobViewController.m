//
//  AddJobViewController.m
//  HRS
//
//  Created by Thomas on 8/27/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "AddJobViewController.h"
#import "DAO.h"

@interface AddJobViewController ()

@end

@implementation AddJobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(id)sender {
  NSNumber *wage = [[DAO sharedInstance]createNumberFromString:self.wageField.text];
  NSNumber *otWage = [self calculateOvertimePay:wage];
  [[DAO sharedInstance]addJob:self.employerField.text title:self.jobTitleField.text wageRate:wage otWage:otWage];
  [self.navigationController popViewControllerAnimated:YES];
}

- (NSNumber *)calculateOvertimePay:(NSNumber *)wage {
  NSNumber *otWage;
  if (self.otSegCtrl.selectedSegmentIndex == 0) {
    otWage = wage;
  } else if (self.otSegCtrl.selectedSegmentIndex == 1) {
    otWage = [NSNumber numberWithInt:[wage intValue] * 1.5];
  } else if (self.otSegCtrl.selectedSegmentIndex == 2) {
    otWage = [NSNumber numberWithInt:[wage intValue] * 2];
  }
  return otWage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

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
  if (self.isEditingJob) {
    [self.employerField setText:self.jobToEdit.employer];
    [self.jobTitleField setText:self.jobToEdit.jobTitle];
    [self.wageField setText:[NSString stringWithFormat:@"%@", self.jobToEdit.hourlyWage]];
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(id)sender {
  NSNumber *wage = [[DAO sharedInstance]createNumberFromString:self.wageField.text];
  if (self.isEditingJob) {
    [[DAO sharedInstance]editExistingJob:self.jobToEdit employer:self.employerField.text jobTitle:self.jobTitleField.text wage:wage];
  } else {
    [[DAO sharedInstance]addJob:self.employerField.text title:self.jobTitleField.text wage:wage];
  }
  [self.navigationController popViewControllerAnimated:YES];
}

@end

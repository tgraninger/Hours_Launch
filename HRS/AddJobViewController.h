//
//  AddJobViewController.h
//  HRS
//
//  Created by Thomas on 8/27/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"

@interface AddJobViewController : UIViewController
@property BOOL isEditingJob;
@property (nonatomic, retain) Job *jobToEdit;
@property (weak, nonatomic) IBOutlet UITextField *employerField;
@property (weak, nonatomic) IBOutlet UITextField *jobTitleField;
@property (weak, nonatomic) IBOutlet UITextField *wageField;

@end

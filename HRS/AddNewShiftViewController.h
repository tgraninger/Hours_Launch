//
//  AddEventViewController.h
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAO.h"
#import "Job.h"
#import "Shift.h"

@interface AddNewShiftViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) Job *currentJob;
@property (nonatomic, retain) Shift *currentShift;
@property (weak, nonatomic) IBOutlet UILabel *jobPickerTitleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *jobPicker;
@property (weak, nonatomic) IBOutlet UILabel *dateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UIButton *useCurrentTime;
@property (weak, nonatomic) IBOutlet UIButton *selectTime;
@property BOOL handlingOutTimeForCurrentShift;

@end

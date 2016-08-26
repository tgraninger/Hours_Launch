//
//  AddEventViewController.h
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAO.h"
#import "Events.h"

@interface AddEventViewController : UIViewController <UITextFieldDelegate>

@property BOOL edit;
@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UITextField *callTime;
@property (weak, nonatomic) IBOutlet UITextField *eventDate;
@property (weak, nonatomic) IBOutlet UITextField *outtime;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) UIDatePicker *datePicker;
@property (nonatomic, retain) Events *event;

- (void)showPicker;
- (void)closePicker;

@end

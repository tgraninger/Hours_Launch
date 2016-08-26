//
//  AddEventViewController.h
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAO.h"
#import "ShiftObject.h"

@interface AddNewShiftViewController : UIViewController <UITextFieldDelegate>

@property BOOL edit;
@property (nonatomic, retain) ShiftObject *shift;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UIButton *clockInOutButton;

//- (void)showPicker;
//- (void)closePicker;

@end

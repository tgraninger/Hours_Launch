//
//  EditShiftViewController.h
//  HRS
//
//  Created by Thomas on 9/28/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+NSDate_StringMethods.h"
#import "Shift.h"
#import "DAO.h"
#import "ShiftDetailsViewController.h"

//@protocol EditShiftViewControllerDelegate <NSObject>
//
//- (void)passDataToParent:(Shift *)shift;

@interface EditShiftViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) ShiftDetailsViewController *shiftDetailsViewController;
//@property (nonatomic, retain) id <EditShiftViewControllerDelegate>delegate;
@property (nonatomic, retain) Shift *shiftToEdit;
@property (weak, nonatomic) IBOutlet UITextField *updatedStartTime;
@property (weak, nonatomic) IBOutlet UITextField *updatedEndTime;


@end

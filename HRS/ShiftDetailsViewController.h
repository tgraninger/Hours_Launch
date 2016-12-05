//
//  EventDetailsViewController.h
//  HRS
//
//  Created by Thomas on 7/18/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAO.h"
#import "Job.h"
#import "Shift.h"

@interface ShiftDetailsViewController : UIViewController 

@property (nonatomic, retain) Job *selectedJob;
@property (nonatomic, retain) Shift *selectedShift;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *outLabel;
//@property (weak, nonatomic) IBOutlet UILabel *payLabel;

@end

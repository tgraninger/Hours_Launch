//
//  ShiftsTableViewController.h
//  HRS
//
//  Created by Thomas on 9/28/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAO.h"
#import "Job.h"

@interface ShiftsTableViewController : UITableViewController

@property (nonatomic, retain) Job *selectedjob;
@property (nonatomic, retain) Shift *selectedShift;

@end

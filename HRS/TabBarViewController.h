//
//  TabBarViewController.h
//  HRS
//
//  Created by Thomas on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"

@interface TabBarViewController : UITabBarController

@property (nonatomic, retain) Job *selectedJob;

@end

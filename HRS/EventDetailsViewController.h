//
//  EventDetailsViewController.h
//  HRS
//
//  Created by Thomas on 7/18/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Events.h"

@interface EventDetailsViewController : UIViewController

@property (nonatomic, retain) Events *selectedEvent;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *outLabel;

@end

//
//  EventDetailsViewController.m
//  HRS
//
//  Created by Thomas on 7/18/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "EventDetailsViewController.h"

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  NSArray *labels = @[self.dateLabel, self.hoursLabel, self.startLabel, self.outLabel];
  for (UILabel *label in labels) {
    CALayer *layer = [label layer];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, label.frame.size.height-1, label.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor blueColor].CGColor];
    [layer addSublayer:bottomBorder];
  }
  // DAO method to parse date data...
  // Parse dates into strings..
  NSMutableDictionary *shiftData = [[DAO sharedInstance]parseDatesForShift:self.selectedShift];
  self.dateLabel.text = [shiftData objectForKey:@"date"];
  self.hoursLabel.text = [shiftData objectForKey:@"hours"];
  self.startLabel.text = [shiftData objectForKey:@"start"];
  self.outLabel.text = [shiftData objectForKey:@"end"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

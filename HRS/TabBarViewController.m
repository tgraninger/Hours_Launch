//
//  TabBarViewController.m
//  HRS
//
//  Created by Thomas on 9/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self.tabBarController setDelegate:self];
}

- (void)popToHistoryTab {
  [self setSelectedIndex:0];
}

- (void)popToClockInTab {
  [self setSelectedIndex:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

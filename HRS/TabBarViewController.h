//
//  TabBarViewController.h
//  HRS
//
//  Created by Thomas on 9/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarViewController : UITabBarController <UITabBarControllerDelegate, UITabBarDelegate>

- (void)popToHistoryTab;
- (void)popToClockInTab;

@end

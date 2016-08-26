//
//  CustomTableViewCell.h
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *statusView;

@end

//
//  TabBarDataHandler.h
//  HRS
//
//  Created by Thomas on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JobObject.h"
#import "DAO.h"

@interface TabBarDataHandler : NSObject

@property (nonatomic, retain) JobObject *selectedJob;

+ (instancetype) sharedInstance;


@end

//
//  ShiftObject.h
//  HRS
//
//  Created by Thomas on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShiftObject : NSObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, retain) NSNumber *hours;

@end

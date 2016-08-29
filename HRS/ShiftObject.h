//
//  ShiftObject.h
//  HRS
//
//  Created by Thomas on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShiftObject : NSObject

@property (nonatomic, retain) NSDate *dateAndStart;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *startTime;
@property (nonatomic, retain) NSString *endTime;
@property (nonatomic, retain) NSNumber *hours;

@end

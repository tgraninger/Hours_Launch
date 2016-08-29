//
//  DAO.h
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Job.h"
#import "Shift.h"
#import "JobObject.h"
#import "ShiftObject.h"

@interface DAO : NSObject

@property (nonatomic, retain) NSMutableArray *managedJobs;
@property (nonatomic, retain) NSMutableArray *arrayOfJobs;
@property (nonatomic, retain) NSManagedObjectModel *model;
@property (nonatomic, retain) NSManagedObjectContext *context;

+ (instancetype) sharedInstance;
- (void)addJob:(NSString *)employer title:(NSString *)jobTitle wageRate:(NSNumber *)wage otWage:(NSNumber *)otWage;
- (void)addNewShiftForJob:(JobObject *)job;
- (NSNumber *)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate;
- (NSString *)formatDateToString:(NSDate *)date;
- (NSNumber *)createNumberFromString:(NSString *)string;
- (void)recordCurrentTimeForClockOutForShift:(ShiftObject *)shift forJob:(JobObject *)job;

@end

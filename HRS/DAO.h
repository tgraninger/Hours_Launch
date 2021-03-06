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

@interface DAO : NSObject

@property (nonatomic, retain) NSMutableArray *managedJobs;
@property (nonatomic, retain) NSManagedObjectModel *model;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSMutableArray *incompleteShifts;
@property BOOL hasIncompleteShifts;

+ (instancetype) sharedInstance;
- (void)addJob:(NSString *)employer title:(NSString *)jobTitle wage:(NSNumber *)wage;
- (Job *)passJobToView;
- (Shift *)checkForIncompleteShiftForJob:(Job *)job;
- (void)editExistingJob:(Job *)job employer:(NSString *)emp jobTitle:(NSString *)jt wage:(NSNumber *)wage;
- (void)deleteJob:(Job *)job;
- (Shift *)addNewShiftForJob:(Job *)job startDate:(NSDate *)date;
- (NSNumber *)createNumberFromString:(NSString *)string;
- (void)completeShift:(Shift *)shift endDate:(NSDate *)endDate;
- (Shift *)editShift:(Shift *)shift start:(NSDate *)start end:(NSDate *)end;
- (void)deleteShift:(Shift *)shift;
- (NSDate *)getCurrentDate;
- (NSNumber *)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate;
- (NSMutableArray *)sortByDate:(NSMutableArray *)shifts;
- (NSUInteger)fetchTotalShiftCount;
- (NSNumber *)calculateShiftPay:(Shift *)shift forJob:(Job *)job;
- (NSDate *)formatStringToDate:(NSString *)string;

@end

//
//  DAO.m
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "DAO.h"

@implementation DAO
{
  NSString *databaseFileName;
}

+ (instancetype) sharedInstance {
  static DAO *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[DAO alloc] customInit];         //Implement CoreData instead of SQLite
  });
  
  return _sharedInstance;
};

- (instancetype)customInit {
  self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
  NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.model];
  NSString *path = [self archivePath];
  //  NSLog(@"%@", path);
  NSURL *storeUrl = [NSURL fileURLWithPath:path];
  NSError *error;
  if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
    [NSException raise:@"error" format:[error localizedDescription]];
  }
  self.context = [[NSManagedObjectContext alloc]init];
  //  self.context.undoManager
  [self.context setPersistentStoreCoordinator:psc];
  self.arrayOfJobs = [NSMutableArray array];
  self.managedJobs = [NSMutableArray array];
  [self fetchDataFromContext];
  
  return self;
}

- (NSString *)archivePath {
  NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [documentDirectories objectAtIndex:0];
  return [documentDirectory stringByAppendingString:@"store.data"];
}


- (void)fetchDataFromContext{
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"employer MATCHES '.*'"];
  [fetchRequest setPredicate:predicate];
//  NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"date" ascending:YES];
//  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
  NSEntityDescription *entity = [[self.model entitiesByName]objectForKey:@"Job"];
  [fetchRequest setEntity:entity];
  NSError *error = nil;
  NSArray *result = [[self context] executeFetchRequest:fetchRequest error:&error];;
  if (!result) {
    NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
    abort();
  }
//  Handle result...
  [self createObjectFromMO:result];
}

- (void)createObjectFromMO:(NSArray *)jobs {
  for (Job *job in jobs) {
    JobObject *jobObject = [[JobObject alloc]init];
    jobObject.employer = job.employer;
    jobObject.jobTitle = job.jobTitle;
    jobObject.wage = job.hourlyWage;
    jobObject.otWage = job.overtimeWage;
    jobObject.shifts = [NSMutableArray arrayWithArray:[job.shifts allObjects]];
    [self checkForIncompleteShifts:jobObject];
    [self.arrayOfJobs addObject:jobObject];
  }
}

- (NSMutableArray * )checkForIncompleteShifts:(JobObject *)job {
  NSMutableArray *jobsWithIncompleteShifts = [NSMutableArray array];
  job.incompleteShifts = [NSMutableArray array];
  for (ShiftObject *shift in job.shifts) {
    if (!shift.endTime) {
      [job.incompleteShifts addObject:shift];
    }
  }
  if (job.incompleteShifts.count > 0) {
    [jobsWithIncompleteShifts addObject:job];
    job.incompleteShifts = [self sortByDate:job.incompleteShifts];
  } else {
    job.incompleteShifts = nil;
  }
  return jobsWithIncompleteShifts;
}

- (NSMutableArray *)sortByDate:(NSMutableArray *)incompleteShifts {
  NSMutableArray *sortedArray = [NSMutableArray array];
  NSSortDescriptor *sd = [[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO];
  sortedArray = (NSMutableArray *)[incompleteShifts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
  return sortedArray;
}

- (void)hardcodeValues {
  NSNumber *wr = [NSNumber numberWithInt:30];
  NSNumber *ot = [NSNumber numberWithInt:45];
  [self addJob:@"TurnToTech" title:@"Developer" wageRate:wr otWage:ot];
}

- (void)addJob:(NSString *)employer title:(NSString *)jobTitle wageRate:(NSNumber *)wage otWage:(NSNumber *)otWage {
  Job *newJob = [NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:self.context];
  [newJob setEmployer:employer];
  [newJob setJobTitle:jobTitle];
  [newJob setHourlyWage:wage];
  [newJob setOvertimeWage:otWage];
  [self createNewJobObjectFromMO:newJob];
  [self saveChanges];
}

- (void)createNewJobObjectFromMO:(Job *)job {
  JobObject *newJob = [[JobObject alloc]init];
  newJob.employer = job.employer;
  newJob.jobTitle = job.jobTitle;
  newJob.wage = job.hourlyWage;
  newJob.otWage = job.overtimeWage;
  [self.arrayOfJobs addObject:newJob];
}

- (void)addNewShiftForJob:(JobObject *)job {
  NSUInteger index = [self.arrayOfJobs indexOfObject:job];
  Job *jobToAddShift = [self.managedJobs objectAtIndex:index];
  Shift *shift = [NSEntityDescription insertNewObjectForEntityForName:@"Shift" inManagedObjectContext:self.context];
  [shift setStartTime:[[self getCurrentDate]objectAtIndex:0]];
  [jobToAddShift addShiftsObject:shift];
  [self saveChanges];
  [self createShiftObjectForJob:job fromMO:shift];
}

- (void)createShiftObjectForJob:(JobObject *)job fromMO:(Shift *)shiftMO {
  // Parse dates and calculate hours
  NSNumber *hours = [self hoursBetween:shiftMO.startTime and:shiftMO.endTime];
  NSString *start = [self formatDateToString:shiftMO.startTime];
//  NSString *end = [self formatDateToString:shiftMO.endTime];
  NSArray *array = [start componentsSeparatedByString:@" "];
  NSString *date = [array firstObject];
  start = [array lastObject];
  array = nil;
//  array = [end componentsSeparatedByString:@" "];
//  end = [array lastObject];
  
  ShiftObject *shift = [[ShiftObject alloc]init];
  shift.dateAndStart = shiftMO.startTime;
  shift.date = date;
  shift.hours = hours;
  shift.startTime = start;
//  shift.endTime = end;
  [job.shifts addObject:shift];
}

// invoke in addNewShiftVC if currentTimeButton selected to store currentTime as outTime...
- (void)recordCurrentTimeForClockOutForShift:(ShiftObject *)shift forJob:(JobObject *)job {
  NSArray *times = [self getCurrentDate];
  shift.endTime = [times objectAtIndex:1];
  NSUInteger index = [self.arrayOfJobs indexOfObject:job];
  Job *jobWithShiftToUpdate = [self.managedJobs objectAtIndex:index];
  NSArray *managedShifts = [NSArray arrayWithArray:[jobWithShiftToUpdate.shifts allObjects]];
  for (Shift *managedShift in managedShifts) {
    if (managedShift.startTime == shift.dateAndStart) {
      [managedShift setEndTime:[times objectAtIndex:0]];
    }
  }
}

//  Method to set time from date picker...

- (NSString *)formatDateToString:(NSDate *)date {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"MM-dd-yyyy HH:mm"];
  NSString *stringFromDate = [formatter stringFromDate:date];
  return stringFromDate;
}

- (NSNumber *)createNumberFromString:(NSString *)string {
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  nf.numberStyle = NSNumberFormatterDecimalStyle;
  NSNumber *wage = [nf numberFromString:string];
  return wage;
}

- (void)saveChanges {
  NSError *err = nil;
  BOOL successful = [[self context] save:&err];
  if(!successful) {
    NSLog(@"Error saving: %@", [err localizedDescription]);
  }
  NSLog(@"Data Saved");
}

- (NSNumber *)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
  NSTimeInterval distanceBetweenDates = [secondDate timeIntervalSinceDate:firstDate];
  double secInHr = 3600;
  double hrs = distanceBetweenDates / secInHr;
  NSNumber *hours = [NSNumber numberWithDouble:hrs];
  return hours;
}

- (NSArray *)getCurrentDate {
  NSDate *today = [NSDate date];
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"dd/MM/yyyy"];
  NSString *dateString = [dateFormat stringFromDate:today];
  NSLog(@"date: %@", dateString);
  return @[today, dateString];
}


- (void)timeClock:(NSString *)status {
  if ([status isEqualToString:@"Clock In!"]) {
//    Set Start Time
  } else {
//    Set End Time
  }
}

//- (void)markAsPaid:(Events *)event {
//  
////  if (!event.paid) {
////    event.paid = YES;
////    NSDate *date = [NSDate date];
////    event.paidDate = date;
////  } else if (event.paid) {
////    event.paid = NO;
////    event.paidDate = nil;
////  }
//  
//}
//
//- (void)estPayment:(Events *)event {
//  //  Calculate payment based on hrs w/ avg taxes
//  
//}



@end

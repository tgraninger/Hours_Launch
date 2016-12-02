//
//  DAO.m
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "DAO.h"
#import "NSDate+NSDate_StringMethods.h"

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
//    NSLog(@"%@", path);
  NSURL *storeUrl = [NSURL fileURLWithPath:path];
  NSError *error;
  if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
    [NSException raise:@"error" format:[error localizedDescription]];
  }
  self.context = [[NSManagedObjectContext alloc]init];
  //  self.context.undoManager
  [self.context setPersistentStoreCoordinator:psc];
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
  if ([result count] != 0) {
	  NSLog(@"%@", result);
    self.managedJobs = [NSMutableArray arrayWithArray:result];
  } else {
    [self addJob:@"Employer" title:@"JobTitle" wage:nil];
  }
}

- (Job *)passJobToView {
	return [self.managedJobs objectAtIndex:0];
}

- (Shift *)checkForIncompleteShiftForJob:(Job *)job {
  //  Add shifts without end time to array and sort by most recent...
  NSMutableArray *incShifts = [NSMutableArray array];
	NSArray *shifts = [job.shifts allObjects];
  for (Shift *shift in shifts) {
    NSLog(@"%@", shift.startTime);
    if (!shift.endTime) {
      [incShifts addObject:shift];
    }
  }
	
  if ([incShifts count] > 0) {
    self.hasIncompleteShifts = YES;
    [self sortByDate:incShifts];
    return [incShifts objectAtIndex:0];
  } else {
    return nil;
  }
}

- (NSMutableArray *)sortByDate:(NSMutableArray *)shifts {
  NSMutableArray *sortedArray = [NSMutableArray array];
  NSSortDescriptor *sd = [[NSSortDescriptor alloc]initWithKey:@"startTime" ascending:NO];
  sortedArray = (NSMutableArray *)[shifts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
  return sortedArray;
}

- (void)addJob:(NSString *)employer title:(NSString *)jobTitle wage:(NSNumber *)wage {
  Job *newJob = [NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:self.context];
  [newJob setEmployer:employer];
  [newJob setJobTitle:jobTitle];
  [newJob setHourlyWage:wage];
  [self.managedJobs addObject:newJob];
  [self saveChanges];
}

- (void)editExistingJob:(Job *)job employer:(NSString *)emp jobTitle:(NSString *)jt wage:(NSNumber *)wage {
  if (emp) {
    job.employer = emp;
  }
  if (jt) {
    job.jobTitle = jt;
  }
  if (wage) {
    job.hourlyWage = wage;
  }
  [self saveChanges];
}

- (void)deleteJob:(Job *)job {
  [self.managedJobs removeObject:job];
  [self.context deleteObject:job];
  [self saveChanges];
}

- (Shift *)addNewShiftForJob:(Job *)job startDate:(NSDate *)date {
  Shift *shift = [NSEntityDescription insertNewObjectForEntityForName:@"Shift" inManagedObjectContext:self.context];
  [shift setStartTime:date];
  [job addShiftsObject:shift];
  [self saveChanges];
  return shift;
}

// invoke in addNewShiftVC if currentTimeButton selected to store currentTime as outTime...
- (void)completeShift:(Shift *)shift endDate:(NSDate *)endDate {
  [shift setEndTime:endDate];
  [self saveChanges];
}

- (Shift *)editShift:(Shift *)shift start:(NSDate *)start end:(NSDate *)end {
  [shift setStartTime:start];
  [shift setEndTime:end];
  [self saveChanges];
  return shift;
}

- (void)deleteShift:(Shift *)shift {
  [self.context deleteObject:shift];
  [self saveChanges];
}

- (NSUInteger)fetchTotalShiftCount {
  NSUInteger shiftCount;
  for (Job *job in self.managedJobs) {
    shiftCount += [[job.shifts allObjects]count];
  }
  return shiftCount;
}

- (void)saveChanges {
  NSError *err = nil;
  BOOL successful = [[self context] save:&err];
  if(!successful) {
    NSLog(@"Error saving: %@", [err localizedDescription]);
  }
  NSLog(@"Data Saved");
}

//  Methods to calculate / convert...

- (NSNumber *)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
  NSTimeInterval distanceBetweenDates = [secondDate timeIntervalSinceDate:firstDate];
  double secInHr = 3600;
  double hrs = distanceBetweenDates / secInHr;
  NSNumber *hours = [NSNumber numberWithDouble:hrs];
  return hours;
}

- (NSString *)createStringFromNumber:(NSNumber *)number {
  NSString *string = [NSString stringWithFormat:@"%@", number];
  return string;
}

- (NSNumber *)createNumberFromString:(NSString *)string {
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  nf.numberStyle = NSNumberFormatterDecimalStyle;
  NSNumber *wage = [nf numberFromString:string];
  return wage;
}

- (NSDate *)getCurrentDate {
  NSDate *today = [NSDate date];
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm"];
  return today;
}

- (NSNumber *)calculateShiftPay:(Shift *)shift forJob:(Job *)job {
  float hours = [[self hoursBetween:shift.startTime and:shift.endTime]floatValue];
  float wage = [job.hourlyWage floatValue];
  float estPay = hours * wage;
  NSNumber *pay = [NSNumber numberWithFloat:estPay];
  return pay;
}

- (NSDate *)formatStringToDate:(NSString *)string {
  NSDateFormatter *df = [[NSDateFormatter alloc]init];
  [df setDateFormat:@"MM-dd-yyyy HH:mm"];
  NSDate *date = [df dateFromString:string];
  NSLog(@"%@", date);
  return date;
}

@end

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
  //  NSLog(@"%@", path);
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
    self.managedJobs = [NSMutableArray arrayWithArray:result];
    [self checkForIncompleteShifts];
  } else {
    [self addJob:@"(Employer)" title:@"(JobTitle)" wage:nil];
  }
}



- (void)checkForIncompleteShifts {
  for (Job *job in self.managedJobs) {
    for (Shift *shift in [job.shifts allObjects]) {
      if (!shift.endTime) {
        if (!self.incompleteShifts) {
          self.incompleteShifts = [NSMutableArray array];
        }
        [self.incompleteShifts addObject:shift];
      }
    }
  }
  if (self.incompleteShifts) {
    self.incompleteShifts = [self sortByDate:self.incompleteShifts];
  } else {
    self.incompleteShifts = nil;
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

- (Shift *)addNewShiftForJob:(Job *)job startDate:(NSDate *)currentDate {
  Shift *shift = [NSEntityDescription insertNewObjectForEntityForName:@"Shift" inManagedObjectContext:self.context];
  [shift setStartTime:currentDate];
  [job addShiftsObject:shift];
  [self saveChanges];
  return shift;
}

// invoke in addNewShiftVC if currentTimeButton selected to store currentTime as outTime...
- (void)completeShift:(Shift *)shift endDate:(NSDate *)endDate {
  [shift setEndTime:endDate];
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

- (NSString *)calculatePay:(Shift *)shift {
  float hours = [[self hoursBetween:shift.startTime and:shift.endTime]floatValue];
  float wage = [shift.hourlyWage floatValue];
  float estPay = hours * wage;
  NSNumber *pay = [NSNumber numberWithFloat:estPay];
  return [self createStringFromNumber:pay];
}



@end

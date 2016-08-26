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
  [self hardcodeValues];
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
}

- (void)createObjectForJobInContext:(NSArray *)jobs {
  for (Job *job in jobs) {
    JobObject *jobToAdd = [[JobObject alloc]init];
    jobToAdd.employer = job.employer;
    jobToAdd.jobTitle = job.jobTitle;
    jobToAdd.wage = job.hourlyWage;
    jobToAdd.otWage = job.overtimeWage;;
    jobToAdd.shifts = [NSMutableArray arrayWithArray:[job.shifts allObjects]];
    NSLog(@"%@",jobToAdd.employer);
    [self.arrayOfJobs addObject:jobToAdd];
  }
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
  NSArray *array = [NSArray arrayWithObject:newJob];
  [self createObjectForJobInContext:array];
  [self saveChanges];
}

- (void)addNewShift:(NSString *)name start:(NSDate *)start end:(NSDate *)end {
  Shift *shift = [NSEntityDescription insertNewObjectForEntityForName:@"Shift" inManagedObjectContext:self.context];
  [shift setStartTime:start];
  [shift setEndTime:end];
  [self saveChanges];
}

//  Invoke this method in shift details view to display dates and times for shift...
- (NSMutableDictionary *)parseDatesForShift:(Shift *)selectedShift {
  NSMutableDictionary *parsedData = [[NSMutableDictionary alloc]init];
  NSArray *array;
  NSNumber *hours = [self hoursBetween:selectedShift.startTime and:selectedShift.endTime];
  NSString *date;
  NSString *start = [self formatDateToString:selectedShift.startTime];
  NSString *end = [self formatDateToString:selectedShift.endTime];
  
  array = [start componentsSeparatedByString:@" "];
  date = [array firstObject];
  start = [array lastObject];
  array = nil;
  array = [end componentsSeparatedByString:@" "];
  end = [array lastObject];

  [parsedData setObject:date forKey:@"date"];
  [parsedData setObject:start forKey:@"start"];
  [parsedData setObject:end forKey:@"end"];
  [parsedData setObject:hours forKey:@"hours"];

  return parsedData;
}

- (NSString *)formatDateToString:(NSDate *)date {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"MM-dd-yyyy HH:mm"];
  NSString *stringFromDate = [formatter stringFromDate:date];
  return stringFromDate;
}


- (void)saveChanges {
  NSError *err = nil;
  BOOL successful = [[self context] save:&err];
  if(!successful) {
    NSLog(@"Error saving: %@", [err localizedDescription]);
  }
  NSLog(@"Data Saved");
}

- (void)sortByDate {
//  sort stored events by date - ascending.
}

- (NSNumber *)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
  NSTimeInterval distanceBetweenDates = [secondDate timeIntervalSinceDate:firstDate];
  double secInHr = 3600;
  double hrs = distanceBetweenDates / secInHr;
  NSNumber *hours = [NSNumber numberWithDouble:hrs];
  return hours;
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

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
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name MATCHES '.*'"];
  [fetchRequest setPredicate:predicate];
  NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"date" ascending:YES];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
  NSEntityDescription *entity = [[self.model entitiesByName]objectForKey:@"Events"];
  [fetchRequest setEntity:entity];
  NSError *error = nil;
  NSArray *result = [[self context] executeFetchRequest:fetchRequest error:&error];;
  if (!result) {
    NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
    abort();
  }
//  Handle result...
}

- (void)addJob:(NSString *)employer title:(NSString *)jobTitle wageRate:(NSNumber *)wage otWage:(NSNumber *)otWage {
  Job *newJob = [NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:self.context];
  [newJob setEmployer:employer];
  [newJob setJobTitle:jobTitle];
  [newJob setHourlyWage:wage];
  [newJob setOvertimeWage:otWage];
  [self.arrayOfJobs addObject:newJob];
  [self saveChanges];
}

- (void)addNewShift:(NSString *)name start:(NSDate *)start end:(NSDate *)end {
  Shift *shift = [NSEntityDescription insertNewObjectForEntityForName:@"Shift" inManagedObjectContext:self.context];
  [shift setStartTime:start];
  [shift setEndTime:end];
  [self saveChanges];
}

- (NSMutableDictionary *)parseDatesForShift:(Shift *)selectedShift {
  NSMutableDictionary *parsedData = [[NSMutableDictionary alloc]init];
  
  
  return 0;
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


- (double)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
  NSTimeInterval distanceBetweenDates = [secondDate timeIntervalSinceDate:firstDate];
  double secInHr = 3600;
  double hours = distanceBetweenDates / secInHr;
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

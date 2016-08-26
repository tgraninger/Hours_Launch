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
  if (self) {
    self.storedEventsArray = [NSMutableArray array];
    databaseFileName = [self createDatabaseWithFileName];
    [self createDatabaseIfNotExists:databaseFileName];
  }
  return self;
}

- (NSString *)createDatabaseWithFileName {
  NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *docPath = [path objectAtIndex:0];
  NSString *dbFileName = [docPath stringByAppendingPathComponent:@"StoredEvents.db"];
  NSLog(@"%@",dbFileName);
  return dbFileName;
}

- (void)createDatabaseIfNotExists:(NSString *)fileName {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:databaseFileName]) {
    NSError *error;
    NSString *databasePath = [[NSBundle mainBundle]pathForResource:@"StoredEvents" ofType:@"db"];
    [[NSFileManager defaultManager]copyItemAtPath:databasePath toPath:databaseFileName error:&error];
    [self createTableIfNotExists];
  } else {
    [self selectQuery];
  }
}

-(void)createTableIfNotExists {
  if (sqlite3_open([databaseFileName UTF8String], &storedEvents)== SQLITE_OK){
    char *err;
    const char *sqlstmt = "CREATE TABLE IF NOT EXISTS events(pk INTEGER, name TEXT, date TEXT, callTime TEXT, outTime TEXT, hours TEXT)";
    if(sqlite3_exec(storedEvents, sqlstmt, NULL, NULL, &err) != SQLITE_OK) {
      NSAssert(0, @"Table failed to create, %s",sqlite3_errmsg(storedEvents));
    }
  }
    sqlite3_close(storedEvents);
}

- (void)selectQuery {
  const char *dbPath = [databaseFileName UTF8String];
  if (sqlite3_open(dbPath, &storedEvents) == SQLITE_OK) {
    [self.storedEventsArray removeAllObjects];
  }
  sqlite3_stmt *statement;
  NSString *query = [NSString stringWithFormat:@"SELECT * FROM events"];
  const char *sqlQuery = [query UTF8String];
  if (sqlite3_prepare(storedEvents, sqlQuery, -1, &statement, NULL) == SQLITE_OK) {
    while (sqlite3_step(statement) == SQLITE_ROW) {
      NSString *name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
      NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
      NSString *callTime = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
      NSString *outTime = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
      NSString *pk = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
      NSString *hours = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
      Events *event = [[Events alloc]initName:name date:date callTime:callTime outTime:outTime];
      event.pk = [pk intValue];
      event.hours = hours;
      [self.storedEventsArray addObject:event];
    }
  }
  sqlite3_close(storedEvents);
}

- (void)sortByDate {
//  sort stored events by date - ascending.
}

- (void)addNewEvent:(Events *)event {
  char *error;
  const char *dbPath = [databaseFileName UTF8String];
  int pk = [self createPrimaryKey];
  NSLog(@"%@", event.hours);
  if (sqlite3_open(dbPath, &storedEvents) == SQLITE_OK) {
    NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO events(pk, name, date, callTime, outTime, hours) VALUES ('%d', '%s', '%s', '%s', '%s', '%s')", pk, [event.name UTF8String], [event.date UTF8String],[event.callTime UTF8String], [event.outTime UTF8String],[event.hours UTF8String]];
    const char *insertStmt = [insertStatement UTF8String];
    if (sqlite3_exec(storedEvents, insertStmt, NULL, NULL, &error) == SQLITE_OK) {
      [self.storedEventsArray addObject:event];
    } else {
      NSLog(@"%s",error);
    }
  }
  sqlite3_close(storedEvents);
}

- (int)createPrimaryKey {
  int newPK;
  NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"pk" ascending:YES];
  NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
  NSArray *sortedArray = [self.storedEventsArray sortedArrayUsingDescriptors:sortDescriptors];
  Events *highestPk = [sortedArray lastObject];
  newPK = highestPk.pk + 1;
  return newPK;
}


- (double)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
  NSTimeInterval distanceBetweenDates = [secondDate timeIntervalSinceDate:firstDate];
  double secInHr = 3600;
  double hours = distanceBetweenDates / secInHr;
  return hours;
}

- (void)deleteEvent:(Events *)event atIndex:(NSUInteger)index {
  char *error;
  [self.storedEventsArray removeObjectAtIndex:index];
  NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM events WHERE pk IS '%d'", event.pk];
  if (sqlite3_exec(storedEvents, [deleteQuery UTF8String], NULL, NULL, &error) == SQLITE_OK) {
  }
}

- (void)editEvent:(Events *)event {
  NSLog(@"%@", event.hours);
  char *error;
  NSString *query = [NSString stringWithFormat:@"UPDATE events WHERE pk IS '%d'", event.pk];
  if (sqlite3_exec(storedEvents, [query UTF8String], NULL, NULL, &error) == SQLITE_OK) {
    NSLog(@"updated");
  }
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

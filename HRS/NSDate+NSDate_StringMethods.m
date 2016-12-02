//
//  NSDate+NSDate_StringMethods.m
//  HRS
//
//  Created by Thomas on 8/31/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "NSDate+NSDate_StringMethods.h"

@implementation NSDate (NSDate_StringMethods)

- (NSString *)getStartDate:(NSDate *)date {
  NSString *dateString = [self formatDateToString:date];
  NSArray *components = [dateString componentsSeparatedByString:@" "];
  NSString *startDate = [NSString stringWithFormat:@"%@ %@ %@", [components firstObject],[components objectAtIndex:1],[components objectAtIndex:2]];
  return startDate;
}

- (NSString *)getStartTime:(NSDate *)date {
  NSString *dateString = [self formatDateToString:date];
  NSArray *components = [dateString componentsSeparatedByString:@" "];
  NSString *startTime = [NSString stringWithFormat:@"%@ %@", [components objectAtIndex:3], [components lastObject]];
  return startTime;
}

- (NSString *)getEndDate:(NSDate *)date {
  NSString *dateString = [self formatDateToString:date];
  NSArray *components = [dateString componentsSeparatedByString:@" "];
  NSString *endDate = [NSString stringWithFormat:@"%@ %@ %@", [components firstObject],[components objectAtIndex:1],[components objectAtIndex:2]];
  return endDate;
}

- (NSString *)getEndTime:(NSDate *)date {
  NSString *dateString = [self formatDateToString:date];
  NSArray *components = [dateString componentsSeparatedByString:@" "];
  NSString *endTime = [NSString stringWithFormat:@"%@ %@", [components objectAtIndex:3], [components lastObject]];
  return endTime;
}

- (NSString *)formatDateToString:(NSDate *)date {
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"MMMM dd, yyyy hh:mm a"];
  NSString *stringFromDate = [df stringFromDate:date];
  return stringFromDate;
}

@end

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
  NSString *startDate = [components firstObject];
  return startDate;
}

- (NSString *)getStartTime:(NSDate *)date {
  NSString *dateString = [self formatDateToString:date];
  NSArray *components = [dateString componentsSeparatedByString:@" "];
  NSString *startTime = [components lastObject];
  return startTime;
}

- (NSString *)getEndDate:(NSDate *)date {
  NSString *dateString = [self formatDateToString:date];
  NSArray *components = [dateString componentsSeparatedByString:@" "];
  NSString *endDate = [components firstObject];
  return endDate;
}

- (NSString *)getEndTime:(NSDate *)date {
  NSString *dateString = [self formatDateToString:date];
  NSArray *components = [dateString componentsSeparatedByString:@" "];
  NSString *endTime = [components lastObject];
  return endTime;
}

- (NSString *)formatDateToString:(NSDate *)date {
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"MM-dd-yyyy HH:mm"];
  NSString *stringFromDate = [df stringFromDate:date];
  return stringFromDate;
}

- (NSDate *)formatStringToDate:(NSString *)string {
  NSDateFormatter *df = [[NSDateFormatter alloc]init];
  [df setDateFormat:@"MM-dd-yyyy HH:mm"];
  NSDate *date = [df dateFromString:string];
  return date;
}

@end

//
//  NSDate+NSDate_StringMethods.h
//  HRS
//
//  Created by Thomas on 8/31/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDate_StringMethods)

- (NSString *)getStartDate:(NSDate *)date;
- (NSString *)getStartTime:(NSDate *)date;
- (NSString *)getEndDate:(NSDate *)date;
- (NSString *)getEndTime:(NSDate *)date;

@end

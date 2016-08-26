//
//  DAO.h
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Events.h"
#import <CoreData/CoreData.h>


@interface DAO : NSObject

@property (nonatomic, retain) NSMutableArray *storedEventsArray;

+ (instancetype) sharedInstance;
- (void)addNewEvent:(Events *)event;
- (double)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate;
- (void)editEvent:(Events *)event;
- (void)deleteEvent:(Events *)event atIndex:(NSUInteger)index;
//- (void)markAsPaid:(Events *)event;

@end

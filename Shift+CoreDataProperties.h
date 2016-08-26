//
//  Shift+CoreDataProperties.h
//  HRS
//
//  Created by Pratap Pandit on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Shift.h"

NS_ASSUME_NONNULL_BEGIN

@interface Shift (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *startTime;
@property (nullable, nonatomic, retain) NSDate *endTime;
@property (nullable, nonatomic, retain) Job *job;

@end

NS_ASSUME_NONNULL_END

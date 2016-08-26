//
//  Job+CoreDataProperties.h
//  HRS
//
//  Created by Pratap Pandit on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Job.h"

NS_ASSUME_NONNULL_BEGIN

@interface Job (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *employer;
@property (nullable, nonatomic, retain) NSString *jobTitle;
@property (nullable, nonatomic, retain) NSNumber *hourlyWage;
@property (nullable, nonatomic, retain) NSNumber *overtimeWage;
@property (nullable, nonatomic, retain) NSManagedObject *shifts;

@end

NS_ASSUME_NONNULL_END

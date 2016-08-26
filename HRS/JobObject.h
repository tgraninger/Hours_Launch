//
//  JobObject.h
//  HRS
//
//  Created by Thomas on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JobObject : NSObject

@property (nonatomic, retain) NSString *employer;
@property (nonatomic, retain) NSString *jobTitle;
@property (nonatomic, retain) NSNumber *wage;
@property (nonatomic, retain) NSNumber *otWage;
@property (nonatomic, retain) NSMutableArray *shifts;

@end

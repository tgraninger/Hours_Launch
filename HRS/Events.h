//
//  Events.h
//  HRS
//
//  Created by Thomas on 7/18/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Events : NSObject
@property (nonatomic) int pk;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *callTime;
@property (nonatomic, retain) NSString *outTime;
@property (nonatomic, retain) NSString *hours;

- (instancetype)initName:(NSString *)name date:(NSString *)date callTime:(NSString *)callTime outTime:(NSString *)outTime;

@end

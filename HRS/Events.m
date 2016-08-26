//
//  Events.m
//  HRS
//
//  Created by Thomas on 7/18/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "Events.h"

@implementation Events

- (instancetype)initName:(NSString *)name date:(NSString *)date callTime:(NSString *)callTime outTime:(NSString *)outTime {
  self.name = name;
  self.date = date;
  self.callTime = callTime;
  self.outTime = outTime;
  return self;
}

@end

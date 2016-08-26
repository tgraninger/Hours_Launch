//
//  TabBarDataHandler.m
//  HRS
//
//  Created by Thomas on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "TabBarDataHandler.h"

@implementation TabBarDataHandler

+ (instancetype) sharedInstance {
  static TabBarDataHandler *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[TabBarDataHandler alloc] customInit];         //Implement CoreData instead of SQLite
  });
  
  return _sharedInstance;
};

- (instancetype)customInit {
  
  return self;
}

@end

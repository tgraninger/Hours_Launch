//
//  ViewController.m
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "JobsViewController.h"
#import "DAO.h"
#import "Events.h"
#import "CustomTableViewCell.h"
#import "ShiftDetailsViewController.h"
#import "AddNewShiftViewController.h"
#import "TabBarDataHandler.h"

@interface JobsViewController ()

@property (nonatomic, retain) DAO *dao;
@property (nonatomic, retain) NSIndexPath *objectIndex;
@property (nonatomic, retain) AddNewShiftViewController *addEventVC;

@end

@implementation JobsViewController
{
  UIAlertController *actionSheet;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.dao = [DAO sharedInstance];
  self.addEventVC.edit = NO;
}
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.dao.arrayOfJobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  JobObject *job = [self.dao.arrayOfJobs objectAtIndex:indexPath.row];
//  NSArray *day = [job.employer componentsSeparatedByString:@","];
//  NSArray *call = [job.jobTitle componentsSeparatedByString:@","];
  cell.nameLabel.text = job.employer;
  cell.dateLabel.text = job.jobTitle;

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:@"showTabBar" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
  TabBarDataHandler *tbdh = [[TabBarDataHandler alloc]init];
  tbdh.selectedJob = [self.dao.arrayOfJobs objectAtIndex:indexPath.row];
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//  if (editingStyle == UITableViewCellEditingStyleDelete) {
//    [self.dao deleteEvent:[self.dao.storedEventsArray objectAtIndex:indexPath.row]];
//    [self.dao.storedEventsArray removeObjectAtIndex:indexPath.row];
//    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//  }
//}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end

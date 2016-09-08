//
//  ViewController.m
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "JobsViewController.h"
#import "DAO.h"
#import "AddJobViewController.h"
#import "ShiftDetailsViewController.h"
#import "AddNewShiftViewController.h"
#import "NSDate+NSDate_StringMethods.h"

@interface JobsViewController ()

@property (nonatomic, retain) DAO *dao;

@end

@implementation JobsViewController
{
  UIAlertController *actionSheet;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.dao = [DAO sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.dao.managedJobs.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NSString *str = @"Select a job to edit details.";
  return str;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  if (cell == nil) {
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
  }
  Job *job = [self.dao.managedJobs objectAtIndex:indexPath.row];
  cell.textLabel.text = job.employer;
  cell.detailTextLabel.text = job.jobTitle;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:@"editJobDetails" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  AddJobViewController *vc = (AddJobViewController *)[segue destinationViewController];
  if ([segue.identifier isEqualToString:@"editJobDetails"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    vc.jobToEdit = [self.dao.managedJobs objectAtIndex:indexPath.row];
    vc.isEditingJob = YES;
  } else if ([segue.identifier isEqualToString:@"addNewJob"]){
    vc.isEditingJob = NO;
  }
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

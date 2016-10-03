//
//  ShiftTableViewController.m
//  HRS
//
//  Created by Thomas on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

/*
Only show 4-5 shifts per job and have a "More" option...
 
 */

#import "JobsTableViewController.h"
#import "AddJobViewController.h"
#import "ShiftsTableViewController.h"
#import "NSDate+NSDate_StringMethods.h"
#import "DAO.h"
#import "Job.h"

@interface JobsTableViewController ()

@property (nonatomic, retain) DAO *dao;
@property (nonatomic, retain) Job *selJob;

@end

@implementation JobsTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.dao = [DAO sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:YES];
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.dao.managedJobs count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return @"Swipe a row to edit or delete the job";

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sdCell" forIndexPath:indexPath];
  if (cell == nil) {
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sdCell"];
  }
  Job *job = [self.dao.managedJobs objectAtIndex:indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"%@", job.employer];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",job.jobTitle];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.selJob = [self.dao.managedJobs objectAtIndex:indexPath.section];
  [self performSegueWithIdentifier:@"showShiftsForJob" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"showShiftsForJob"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    ShiftsTableViewController *stvc = (ShiftsTableViewController *)segue.destinationViewController;
    stvc.selectedjob = [self.dao.managedJobs objectAtIndex:indexPath.row];
  } else if ([segue.identifier isEqualToString:@"editJob"]) {
    AddJobViewController *vc = (AddJobViewController *)[segue destinationViewController];
    vc.jobToEdit = self.selJob;
    vc.isEditingJob = YES;
  } else if ([segue.identifier isEqualToString:@"addNewJob"]) {
    AddJobViewController *vc = (AddJobViewController *)[segue destinationViewController];
    vc.isEditingJob = NO;
  }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
    self.selJob = [self.dao.managedJobs objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"editJob" sender:self];
  }];
  editAction.backgroundColor = [UIColor blueColor];
  UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm delete" message:@"Pressing ok will delete this job and all of its data." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      [self.dao deleteJob:[self.dao.managedJobs objectAtIndex:indexPath.row]];
      [self.tableView reloadData];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
      [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:confirm];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
  }];
  deleteAction.backgroundColor = [UIColor redColor];
  return @[deleteAction,editAction];
}

@end

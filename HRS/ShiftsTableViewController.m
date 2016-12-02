//
//  ShiftsTableViewController.m
//  HRS
//
//  Created by Thomas on 9/28/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "ShiftsTableViewController.h"
#import "ShiftDetailsViewController.h"
#import "NSDate+NSDate_StringMethods.h"
#import "Shift.h"

@interface ShiftsTableViewController ()

@property (nonatomic, retain) DAO *dao;
@property (nonatomic, retain) NSMutableArray *shifts;

@end

@implementation ShiftsTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.dao = [DAO sharedInstance];
	self.tableView.backgroundView = nil;
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

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
  return [[[[self.dao.managedJobs objectAtIndex:0]shifts] allObjects]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shiftCell" forIndexPath:indexPath];
  self.shifts = [self.dao sortByDate:[NSMutableArray arrayWithArray:[[[self.dao.managedJobs objectAtIndex:0]shifts] allObjects]]];
  Shift *shift = [self.shifts objectAtIndex:indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"Shift date: %@",[shift.startTime getStartDate:shift.startTime]];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"Hours worked: %.2f", [[self.dao hoursBetween:shift.startTime and:shift.endTime]floatValue]];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.selectedShift = [self.shifts objectAtIndex:indexPath.row];
  [self performSegueWithIdentifier:@"showShiftDetails" sender:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [self.dao deleteShift:[self.shifts objectAtIndex:indexPath.row]];
    [self.tableView reloadData];
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  ShiftDetailsViewController *sdvc = (ShiftDetailsViewController *)segue.destinationViewController;
  sdvc.selectedJob = self.selectedjob;
  sdvc.selectedShift = self.selectedShift;
}


@end

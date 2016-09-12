//
//  ShiftTableViewController.m
//  HRS
//
//  Created by Thomas on 8/26/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "ShiftTableViewController.h"
#import "NSDate+NSDate_StringMethods.h"

@interface ShiftTableViewController ()

@property (nonatomic, retain) DAO *dao;

@end

@implementation ShiftTableViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  self.dao = [DAO sharedInstance];
//  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"sdCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dao.managedJobs count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
  NSString *str = [NSString stringWithFormat:@"%@: %@", [[self.dao.managedJobs objectAtIndex:section]employer], [[self.dao.managedJobs objectAtIndex:section]jobTitle]];
  return str;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger shiftCount = [[[[self.dao.managedJobs objectAtIndex:section]shifts]allObjects]count];
  return shiftCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sdCell" forIndexPath:indexPath];
  if (cell == nil) {
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sdCell"];
  }
  Job *job = [self.dao.managedJobs objectAtIndex:indexPath.section];
  NSMutableArray *shifts = [self.dao sortByDate:[NSMutableArray arrayWithArray:[job.shifts allObjects]]];
  Shift *aShift = [shifts objectAtIndex:indexPath.row];
  UIFont *cellFont = [UIFont systemFontOfSize:14.0];
  cell.textLabel.font = cellFont;
  cell.textLabel.text = [NSString stringWithFormat:@"Shift date: %@",[aShift.startTime getStartDate:aShift.startTime]];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"Hours worked: %.2f", [[self.dao hoursBetween:aShift.startTime and:aShift.endTime]floatValue]];
  if (!aShift.endTime) {
    cell.backgroundColor = [UIColor redColor];
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:@"showShiftDetails" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
  ShiftDetailsViewController *sdvc = (ShiftDetailsViewController *)[segue destinationViewController];
  sdvc.selectedJob = [self.dao.managedJobs objectAtIndex:indexPath.section];
  sdvc.selectedShift = [[sdvc.selectedJob.shifts allObjects] objectAtIndex:indexPath.row];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

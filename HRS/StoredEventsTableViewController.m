//
//  ViewController.m
//  HRS
//
//  Created by Thomas on 7/13/16.
//  Copyright © 2016 ThomasGraninger. All rights reserved.
//

#import "StoredEventsTableViewController.h"
#import "DAO.h"
#import "Events.h"
#import "CustomTableViewCell.h"
#import "EventDetailsViewController.h"
#import "AddEventViewController.h"

@interface StoredEventsTableViewController ()

@property (nonatomic, retain) DAO *dao;
@property (nonatomic, retain) NSIndexPath *objectIndex;
@property (nonatomic, retain) AddEventViewController *addEventVC;

@end

@implementation StoredEventsTableViewController
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
  return self.dao.storedEventsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  Events *event = [self.dao.storedEventsArray objectAtIndex:indexPath.row];
  NSArray *day = [event.date componentsSeparatedByString:@","];
  NSArray *call = [event.callTime componentsSeparatedByString:@","];
  cell.nameLabel.text = event.name;
  cell.dateLabel.text = [NSString stringWithFormat:@"%@, %@", [day firstObject],[call lastObject]];
  
  if (self) {
//    Set imageView status paid
  } else {
//    Set imageView status pending
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  actionSheet = [UIAlertController alertControllerWithTitle:@"Options" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  [actionSheet addAction:[UIAlertAction actionWithTitle:@"View details"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                  [self performSegueWithIdentifier:@"ShowEventDetails" sender:self];
                                                }]];
  [actionSheet addAction:[UIAlertAction actionWithTitle:@"Edit details"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                  [self performSegueWithIdentifier:@"AddEvent" sender:self];
                                                }]];
  [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete event"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                  [self.dao deleteEvent:[self.dao.storedEventsArray objectAtIndex:indexPath.row]
                                                                atIndex:indexPath.row];
                                                  [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                }]];
  [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                                }]];
  [self presentViewController:actionSheet animated:YES completion:nil];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ShowEventDetails"]){
    EventDetailsViewController *eventDetailsViewController = (EventDetailsViewController *)segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    eventDetailsViewController.selectedEvent = [self.dao.storedEventsArray objectAtIndex:indexPath.row];
  } else if ([segue.identifier isEqualToString:@"AddEvent"]) {
    self.addEventVC = (AddEventViewController *)segue.destinationViewController;
    if ([sender isKindOfClass:[UITableViewController class]]) {
      self.addEventVC.edit = YES;
      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      self.addEventVC.event = [self.dao.storedEventsArray objectAtIndex:indexPath.row];
    } else {
      self.addEventVC.edit = NO;
    }
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

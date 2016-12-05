/*
 File: MyTableViewController.m
 Abstract: The main table view controller of this app.
 Version: 1.6
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "AddShiftTableViewController.h"
#import "DAO.h"
#import "Job.h"
#import "Shift.h"
#import "NSDate+NSDate_StringMethods.h"
#import "ShiftDetailsViewController.h"

#define kPickerAnimationDuration    0.20   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view

#define kMainLabelKey       @"title"   // key for obtaining the data source item's title
#define kDateKey        @"date"    // key for obtaining the data source item's date value

// keep track of which rows have date cells
#define kDateStartRow   1

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end

#pragma mark -

@interface AddShiftTableViewController ()

@property (nonatomic, strong) DAO *dao;
@property (nonatomic, strong) Job *currentJob;
@property (nonatomic, strong) Shift *currentShift;

@property (nonatomic, strong) NSMutableDictionary *dataForCurrentTime;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

@property (assign) NSInteger pickerCellRowHeight;

@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView;

@property (nonatomic, strong) NSDate *currentDateInDatePicker;

// this button appears only when the date picker is shown (iOS 6.1.x or earlier)

@end


#pragma mark -

@implementation AddShiftTableViewController

/*! Primary view has been loaded for this view controller
 */
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.dao = [DAO sharedInstance];
	
	self.currentJob = [self.dao passJobToView];
		
	self.currentShift = [self.dao checkForIncompleteShiftForJob:self.currentJob];
	
	// setup our data source
	
	self.dataForCurrentTime = [@{ kMainLabelKey : @"With current time",
										kDateKey : [NSDate date] } mutableCopy];
	NSMutableDictionary *itemTwo = [@{ kMainLabelKey : @"Tap to select date",
										kDateKey : [NSDate date]} mutableCopy];
	
	self.dataArray = [NSMutableArray array];
	[self.dataArray addObject:itemTwo];
	
	self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];    // show short-style date format
	[self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	// obtain the picker view cell's height, works because the cell was pre-defined in our storyboard
	UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
	self.pickerCellRowHeight = CGRectGetHeight(pickerViewCellToCheck.frame);
	
	// if the local changes while in the background, we need to be notified so we can update the date
	// format in the table view cells
	//
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(localeChanged:)
												 name:NSCurrentLocaleDidChangeNotification
											   object:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSCurrentLocaleDidChangeNotification
												  object:nil];
}


#pragma mark - Locale

/*! Responds to region format or locale changes.
 */
- (void)localeChanged:(NSNotification *)notif {
	// the user changed the locale (region format) in Settings, so we are notified here to
	// update the date format in the table view cells
	//
	[self.tableView reloadData];
}


#pragma mark - Utilities

/*! Returns the major version of iOS, (i.e. for iOS 6.1.3 it returns 6)
 */
NSUInteger DeviceSystemMajorVersion() {
	static NSUInteger _deviceSystemMajorVersion = -1;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		_deviceSystemMajorVersion =
		[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] integerValue];
	});
	
	return _deviceSystemMajorVersion;
}

#define EMBEDDED_DATE_PICKER (DeviceSystemMajorVersion() >= 7)

/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath {
	BOOL hasDatePicker = NO;
	
	NSInteger targetedRow = indexPath.row;
	targetedRow++;
	
	UITableViewCell *checkDatePickerCell =
	[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:1]];
	UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerTag];
	
	hasDatePicker = (checkDatePicker != nil);
	
	return hasDatePicker;
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
- (void)updateDatePicker {

	if (self.datePickerIndexPath != nil) {
		UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
		
		UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
		
		if (targetedDatePicker != nil) {
			// we found a UIDatePicker in this cell, so update it's date value
			//
			NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
			[targetedDatePicker setDate:[itemData valueForKey:kDateKey] animated:NO];
		}
	}
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineDatePicker {
	return (self.datePickerIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
 
 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath {
	return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.
 
 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath {
	BOOL hasDate = NO;
	
	// identify the cells that should have a picker...
	if (indexPath.section == 1 && indexPath.row == 0) {
		hasDate = YES;
	}
	
	return hasDate;
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// accomodate picker size in row height if applicable.
	return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// create another section to display current shift
	if (self.currentShift) {
		return 3;
	}
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (self.currentShift) {
		if (section == 0) {
			return @"Clock out with current time:";
		} else if (section == 2) {
			return @"Current Shift:";
		}
	} else if (section == 0) {
		return @"Clock in with current time:";
	}
	
	return @"Select time manually:";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	// if we already have a shift in our data store, we want to display it in a second section
	if (section == 1) {
		if ([self hasInlineDatePicker]) {
			// we have a date picker, so allow for it in the number of rows in this section
			NSInteger numRows = self.dataArray.count;
			return ++numRows;
		}
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	NSString *cellID = kOtherCell;
	
	if ([self indexPathHasPicker:indexPath]) {
		// the indexPath is the one containing the inline date picker
		cellID = kDatePickerID;     // the current/opened date picker cell
	}
	else if ([self indexPathHasDate:indexPath]) {
		// the indexPath is one that contains the date information
		cellID = kDateCellID;       // the start/end date cells
	}
	
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	
//	if (indexPath.row == 0) {
//		// we decide here that first cell in the table is not selectable (it's just an indicator)
//		cell.selectionStyle = UITableViewCellSelectionStyleNone;
//	}
	
	// if we have a date picker open whose cell is above the cell we want to update,
	// then we have one more cell than the model allows
	
	NSInteger modelRow = indexPath.row;
	if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row <= indexPath.row)
	{
		modelRow--;
	}
	
	NSMutableDictionary *itemData = self.dataArray[modelRow];

	if (indexPath.section == 0) {
		// display current date in current date cell
		NSDate *currentDate = [NSDate date];
		cell.textLabel.text = [currentDate getStartDate:currentDate];
		cell.detailTextLabel.text = [currentDate getStartTime:currentDate];
	}

	// proceed to configure our cell
	if ([cellID isEqualToString:kDateCellID] && (indexPath.section != 0)) {
		// we have either start or end date cells, populate their date field
		//
		cell.textLabel.text = [itemData objectForKey:kMainLabelKey];
		cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kDateKey]];
	}
	else if ([cellID isEqualToString:kOtherCell] && (indexPath.section != 0)) {
		// this cell is a non-date cell, just assign it's text label
		//
		cell.textLabel.text = [itemData objectForKey:kMainLabelKey];
		cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kDateKey]];
		cell.accessoryType = UITableViewCellAccessoryNone;

	}
	
	// show details of the current shift in the new section
	if (indexPath.section == 2) {
		cell.textLabel.text = [NSString stringWithFormat:@"Shift Date: %@",[self.currentShift.startTime getStartDate:self.currentShift.startTime]];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"Clocked in: %@", [self.currentShift.startTime getStartTime:self.currentShift.startTime]];
	}
	
	return cell;
}

/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath {
	[self.tableView beginUpdates];
	
	NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:1]];
	
	// check if 'indexPath' has an attached date picker below it
	if ([self hasPickerForIndexPath:indexPath]) {
		// found a picker below it, so remove it
		[self.tableView deleteRowsAtIndexPaths:indexPaths
							  withRowAnimation:UITableViewRowAnimationFade];
	}
	else {
		// didn't find a picker below it, so we should insert it
		[self.tableView insertRowsAtIndexPaths:indexPaths
							  withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[self.tableView endUpdates];
}

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// display the date picker inline with the table content
	[self.tableView beginUpdates];
	
	BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
	if ([self hasInlineDatePicker]) {
		before = self.datePickerIndexPath.row < indexPath.row;
	}
	
	BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
	
	// remove any date picker cell if it exists
	if ([self hasInlineDatePicker]) {
		
		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:1]]
							  withRowAnimation:UITableViewRowAnimationFade];
		self.datePickerIndexPath = nil;
		
	}
	
	if (!sameCellClicked) {
		// hide the old date picker and display the new one
		NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
		NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:1];
		[self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
		self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:1];
	}
	
	// always deselect the row containing the start or end date
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self.tableView endUpdates];
	
	[self updateDatePicker];
	
	// inform our date picker of the current date to match the current cell

}

/*! Reveals the UIDatePicker as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath used to display the UIDatePicker.
 */
- (void)displayExternalDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath {
	// first update the date picker's date value according to our model
	NSDictionary *itemData = self.dataArray[indexPath.row];
	[self.pickerView setDate:[itemData valueForKey:kDateKey] animated:YES];
	
	// the date picker might already be showing, so don't add it to our view
	if (self.pickerView.superview == nil) {
		CGRect startFrame = self.pickerView.frame;
		CGRect endFrame = self.pickerView.frame;
		
		// the start position is below the bottom of the visible frame
		startFrame.origin.y = CGRectGetHeight(self.view.frame);
		
		// the end position is slid up by the height of the view
		endFrame.origin.y = startFrame.origin.y - CGRectGetHeight(endFrame);
		
		self.pickerView.frame = startFrame;
		
		[self.view addSubview:self.pickerView];
		
		// animate the date picker into view
		[UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = endFrame; }
						 completion:^(BOOL finished) {
							 // add the "Done" button to the nav bar
							 
						 }];
	}
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.reuseIdentifier == kDateCellID) {
		if (indexPath.section == 2) {
			//	deselect the cell if user taps current shift cell
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		} else {
			
		NSDictionary *itemData;
		if (self.datePickerIndexPath == nil) {
			itemData = [self.dataArray objectAtIndex:0];
			[itemData setValue:@"Tap again to clock in" forKey:@"title"];
			
		} else {
			itemData = [self.dataArray objectAtIndex:0];
			[itemData setValue:@"Select time manually" forKey:@"title"];
		}
		
		cell.textLabel.text = [itemData valueForKey:@"title"];

		if (EMBEDDED_DATE_PICKER)
			[self displayInlineDatePickerForRowAtIndexPath:indexPath];
		else
			[self displayExternalDatePickerForRowAtIndexPath:indexPath];
		}
		
	} else if (indexPath.section == 0 && indexPath.row == 0) {

		// tapping this cell passes the current date back to the model
		if (self.currentShift) {
			[self completeShiftAndPushHistoryView:[NSDate date]];
		} else {
			self.currentShift = [self.dao addNewShiftForJob:self.currentJob startDate:[NSDate date]];
			[self addCurrentShiftToTableView];
		}
		
		return;
		
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	// the cell was tapped a second time, releasing the dp indexPath, so we know we can pass the data to the model.
	if ((indexPath.section == 1) && self.datePickerIndexPath == nil) {
		if (self.currentShift) {
			[self completeShiftAndPushHistoryView:[self checkForNullDate]];

		} else {
//			NSLog(@"%@", self.pickerView.date);
			self.currentShift = [self.dao addNewShiftForJob:self.currentJob startDate:[self checkForNullDate]];
			[self addCurrentShiftToTableView];
		}
	}
}

- (NSDate *)checkForNullDate {
	if (!self.currentDateInDatePicker) {
		return [NSDate date];
	} else {
		return self.currentDateInDatePicker;
	}
}

- (void)completeShiftAndPushHistoryView:(NSDate *)endDate {
	
	[self.dao completeShift:self.currentShift endDate:endDate];
	
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	ShiftDetailsViewController *sdvc = (ShiftDetailsViewController *)[sb instantiateViewControllerWithIdentifier:@"shiftDetails"];
	sdvc.selectedJob = self.currentJob;
	sdvc.selectedShift = self.currentShift;
	sdvc.hidesBottomBarWhenPushed = YES;
	
	self.currentShift = nil;
	[self removeCurrentShiftFromTableView];
	
	[self.navigationController pushViewController:sdvc animated:YES];
}

- (void)addCurrentShiftToTableView {
	[self.tableView beginUpdates];
	[self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationBottom];
	[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationBottom];
	[self.tableView endUpdates];
	
	[self.tableView reloadData];

}

- (void)removeCurrentShiftFromTableView {
	[self.tableView beginUpdates];
	[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationBottom];
	[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationTop];
	[self.tableView endUpdates];
	
	[self.tableView reloadData];

}


#pragma mark - Actions

/*! User chose to change the date by changing the values inside the UIDatePicker.
 
 @param sender The sender for this action: UIDatePicker.
 */
- (IBAction)dateAction:(id)sender
{
	NSIndexPath *targetedCellIndexPath = nil;
	
	if ([self hasInlineDatePicker]) {
		// inline date picker: update the cell's date "above" the date picker cell
		//
		targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:1];
	} else {
		// external date picker: update the current "selected" cell's date
		targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
	}
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
	UIDatePicker *targetedDatePicker = sender;
	
	// update our data model
	NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
	[itemData setValue:targetedDatePicker.date forKey:kDateKey];
	
	// update the cell's date string
	cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
	
	self.currentDateInDatePicker = targetedDatePicker.date;
	
}

/*! User chose to finish using the UIDatePicker by pressing the "Done" button
 (used only for "non-inline" date picker, iOS 6.1.x or earlier)
 
 @param sender The sender for this action: The "Done" UIBarButtonItem
 */
- (void)doneButtonPressed {
	CGRect pickerFrame = self.pickerView.frame;
	pickerFrame.origin.y = CGRectGetHeight(self.view.frame);
	
	// animate the date picker out of view
	[UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = pickerFrame; }
					 completion:^(BOOL finished) {
						 [self.pickerView removeFromSuperview];
					 }];
	
	// remove the "Done" button in the navigation bar
	self.navigationItem.rightBarButtonItem = nil;
	
	// deselect the current table cell
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

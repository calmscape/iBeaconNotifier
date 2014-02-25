//
//  NotificationLogViewController.m
//  iBeaconNotifier
//
//  Created by Masahiro Murase on 2014/02/24.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

#import "CLBeaconRegion+LoadPlist.h"
#import "BeaconMonitor.h"
#import "NotificationLogViewController.h"

static NSString * const kNotificationFormat = @"%@: %@..., major:%@, minor:%@";

@interface NotificationLogViewController () <BeaconMonitorDelegate>
@property (nonatomic, strong) BeaconMonitor *beaconMonitor;
@property (nonatomic, assign, getter = isMonitoringEnabled) BOOL monitoringEnabled;
@property (nonatomic ,strong) NSSet *monitoredBeaconRegion;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// Outlets & Actions
@property (weak, nonatomic) IBOutlet UISwitch *monitoringSwitch;
- (IBAction)didChangeMonitoringSwitch:(id)sender;
- (IBAction)didPushTrashButton:(id)sender;
@end

@implementation NotificationLogViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

	_beaconMonitor = [BeaconMonitor new];
	_beaconMonitor.delegate = self;
	_monitoredBeaconRegion = [CLBeaconRegion beaconRegionsFromPlist:@"BeaconList"];
	_monitoringEnabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	self.monitoringSwitch.on = self.monitoringEnabled;
	[self.beaconMonitor stopAllMonitoring];	// 登録されているビーコン領域をすべて解除するために呼ぶ
	if (self.monitoringEnabled) {
		[self.beaconMonitor startMonitoringWithBeaconRegions:self.monitoredBeaconRegion];
	}

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(CLBeaconRegion *)beaconRegion state:(NSString *)stateString
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    [newManagedObject setValue:[beaconRegion.proximityUUID UUIDString] forKey:@"proximityUUID"];
    [newManagedObject setValue:beaconRegion.major forKey:@"major"];
    [newManagedObject setValue:beaconRegion.minor forKey:@"minor"];
    [newManagedObject setValue:stateString forKey:@"state"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

/**
 通知ログを全削除する
 */
- (void)clearAllLogs
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
	NSError *error = nil;
	NSArray *objects = [context executeFetchRequest:request error:&error];
	NSAssert(!error, @"failed fetch request");
	for (NSManagedObject *object in objects) {
		[context deleteObject:object];
	}

    // Save the context.
    if (![context save:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:[object valueForKey:@"timeStamp"]];
	
	NSString *trimmedUUIDString = [[object valueForKey:@"proximityUUID"] substringToIndex:8];

	cell.textLabel.text =[NSString stringWithFormat:kNotificationFormat,
								[object valueForKey:@"state"],
								trimmedUUIDString,
								[object valueForKey:@"major"],
								[object valueForKey:@"minor"]];

}

#pragma mark - Action methods
/**
 ビーコン領域監視の有効/無効が切り替わった
 */
- (IBAction)didChangeMonitoringSwitch:(id)sender
{
	UISwitch *monitoringSwitch = sender;
	self.monitoringEnabled = monitoringSwitch.on;

	NSParameterAssert(self.beaconMonitor);
	if (self.monitoringEnabled) {
		[self.beaconMonitor startMonitoringWithBeaconRegions:self.monitoredBeaconRegion];
	}
	else {
		[self.beaconMonitor stopAllMonitoring];
	}

}

/**
 ログと通知をクリアする
 */
- (IBAction)didPushTrashButton:(id)sender
{
	[self clearAllLogs];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark - BeaconMonitorDelegate protocol method
/**
 リージョンステータスの測定結果
 */
- (void)beaconMonitor:(BeaconMonitor *)beaconMonitor didDetermineState:(CLRegionState)state forBeaconRegion:(CLBeaconRegion *)beaconRegion
{
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	NSString *trimmedUUIDString = [[beaconRegion.proximityUUID UUIDString] substringToIndex:8];

	NSString *stateString;
	if (state == CLRegionStateInside) {
		stateString = @"StateInside";
	}
	else if (state == CLRegionStateOutside) {
		stateString = @"StateOutside";
	}
	else {
		stateString = @"StateUnknown";
	}

	notification.alertBody = [NSString stringWithFormat:kNotificationFormat,
							  stateString,
							  trimmedUUIDString,
							  beaconRegion.major,
							  beaconRegion.minor];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
	
	[self insertNewObject:beaconRegion state:stateString];
}

/**
 ビーコン領域に入った
 */
- (void)beaconMonitor:(BeaconMonitor *)beaconMonitor didEnterBeaconRegion:(CLBeaconRegion *)beaconRegion
{
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	NSString *trimmedUUIDString = [[beaconRegion.proximityUUID UUIDString] substringToIndex:8];
	NSString *stateString = @"Enter";
    notification.alertBody = [NSString stringWithFormat:kNotificationFormat,
							  stateString,
							  trimmedUUIDString,
							  beaconRegion.major,
							  beaconRegion.minor];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
	
	[self insertNewObject:beaconRegion state:stateString];
}

/**
 ビーコン領域から出た
 */
- (void)beaconMonitor:(BeaconMonitor *)beaconMonitor didExitBeaconRegion:(CLBeaconRegion *)beaconRegion
{
    UILocalNotification *notification = [UILocalNotification new];
	NSString *trimmedUUIDString = [[beaconRegion.proximityUUID UUIDString] substringToIndex:8];
	NSString *stateString = @"Exit";
    notification.alertBody = [NSString stringWithFormat:kNotificationFormat,
							  stateString,
							  trimmedUUIDString,
							  beaconRegion.major,
							  beaconRegion.minor];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];

	[self insertNewObject:beaconRegion state:stateString];
}
@end

//
//  NotificationLogViewController.h
//  iBeaconNotifier
//
//  Created by Masahiro Murase on 2014/02/24.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface NotificationLogViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

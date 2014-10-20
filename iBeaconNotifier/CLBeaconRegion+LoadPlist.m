//
//  CLBeaconRegion+LoadPlist.m
//  iBeaconNotifier
//
//  Created by Masahiro Murase on 2014/02/24.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

#import "CLBeaconRegion+LoadPlist.h"

static NSString* const kMyBeaconRegionIdentifier = @"edu.self.myBeacon";


@implementation CLBeaconRegion (LoadPlist)
+ (NSSet *)beaconRegionsFromPlist:(NSString *)plistName;
{
	NSParameterAssert(plistName);
	
	NSMutableSet *beaconRegions = [NSMutableSet set];
	NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
	NSArray *beacons = [NSArray arrayWithContentsOfFile:path];
	[beacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		NSParameterAssert([obj isKindOfClass:[NSDictionary class]]);
		NSDictionary *beaconInfo = obj;
		NSParameterAssert(beaconInfo[@"proximityUUID"]);
		NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconInfo[@"proximityUUID"]];
		NSString *identifier = [NSString stringWithFormat:@"%@.%lu", kMyBeaconRegionIdentifier, (unsigned long)idx];
		
		CLBeaconRegion *beaconRegion;
		if (beaconInfo[@"proximityUUID"] && beaconInfo[@"major"] && beaconInfo[@"minor"]) {
			beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
																   major:[beaconInfo[@"major"] intValue]
																   minor:[beaconInfo[@"minor"] intValue]
															  identifier:identifier];
			
		}
		else if (beaconInfo[@"proximityUUID"] && beaconInfo[@"major"]) {
			beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
																   major:[beaconInfo[@"major"] intValue]
															  identifier:identifier];
		}
		else {
			beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
															  identifier:identifier];
		}
		beaconRegion.notifyOnEntry = beaconInfo[@"notifyOnEntry"] ? [beaconInfo[@"notifyOnEntry"] boolValue] : YES;
		beaconRegion.notifyOnExit = beaconInfo[@"notifyOnExit"] ? [beaconInfo[@"notifyOnExit"] boolValue] : YES;
		beaconRegion.notifyEntryStateOnDisplay = beaconInfo[@"notifyEntryStateOnDisplay"] ? [beaconInfo[@"notifyEntryStateOnDisplay"] boolValue] : YES;
		[beaconRegions addObject:beaconRegion];
	}];
	
	return beaconRegions;
}
@end

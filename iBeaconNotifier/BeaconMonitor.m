//
//  BeaconMonitor.m
//  iBeaconNotifier
//
//  Created by Masahiro Murase on 2014/02/24.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

@import CoreLocation;
#import "BeaconMonitor.h"


@interface BeaconMonitor () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation BeaconMonitor
- (id)init
{
    self = [super init];
    if (self) {
		_locationManager = [CLLocationManager new];
		_locationManager.delegate = self;
    }
    return self;
}

#pragma mark - public instance methods
- (void)startMonitoringWithBeaconRegions:(NSSet *)beaconRegions;
{
	if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
		[self.locationManager requestAlwaysAuthorization];
	}
	
	for (id region in beaconRegions) {
		NSParameterAssert([region isKindOfClass:[CLBeaconRegion class]]);
		if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
			[self.locationManager startMonitoringForRegion:region];
		}
	}
}

- (void)stopAllMonitoring
{
	for (id region in self.locationManager.monitoredRegions) {
		if ([region isKindOfClass:[CLBeaconRegion class]]) {
			CLBeaconRegion *beaconRegion = region;
			[self.locationManager stopMonitoringForRegion:beaconRegion];
		}
	}
}

#pragma mark - CLLocationManagerDelegate protocol method (required)
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	if ([self.delegate respondsToSelector:@selector(beaconMonitor:didDetermineState:forBeaconRegion:)]) {
		[self.delegate beaconMonitor:self
				   didDetermineState:state
					 forBeaconRegion:(CLBeaconRegion *)region
		 ];
	}
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
	NSLog(@"%s, %@", __PRETTY_FUNCTION__, [error localizedDescription]);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - CLLocationManagerDelegate protocol method (optional)
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	NSLog(@"%s, status=%d", __PRETTY_FUNCTION__, status);
	
	if (status == kCLAuthorizationStatusDenied) {
		NSLog(@"アプリの位置情報サービスをONにしてね");
	}
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	if ([self.delegate respondsToSelector:@selector(beaconMonitor:didEnterBeaconRegion:)]) {
		[self.delegate beaconMonitor:self
				didEnterBeaconRegion:(CLBeaconRegion *)region];
	}
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	if ([self.delegate respondsToSelector:@selector(beaconMonitor:didExitBeaconRegion:)]) {
		[self.delegate beaconMonitor:self
				didExitBeaconRegion:(CLBeaconRegion *)region];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"%s, %@", __PRETTY_FUNCTION__, [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
	NSLog(@"%s, %@", __PRETTY_FUNCTION__, region);
	[self.locationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	NSLog(@"%s, %@", __PRETTY_FUNCTION__, [error localizedDescription]);
}
@end

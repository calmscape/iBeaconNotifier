//
//  BeaconMonitor.h
//  iBeaconNotifier
//
//  Created by Masahiro Murase on 2014/02/24.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BeaconMonitor;
@protocol BeaconMonitorDelegate <NSObject>
@optional
- (void)beaconMonitor:(BeaconMonitor *)beaconMonitor didDetermineState:(CLRegionState)state forBeaconRegion:(CLBeaconRegion *)beaconRegion;
- (void)beaconMonitor:(BeaconMonitor *)beaconMonitor didEnterBeaconRegion:(CLBeaconRegion *)beaconRegion;
- (void)beaconMonitor:(BeaconMonitor *)beaconMonitor didExitBeaconRegion:(CLBeaconRegion *)beaconRegion;
@end

@interface BeaconMonitor : NSObject

@property (nonatomic, weak) id<BeaconMonitorDelegate> delegate;

/**
 ビーコン領域監視を開始する
 */
- (void)startMonitoringWithBeaconRegions:(NSSet *)beaconRegions;

/**
 すべてのビーコン領域監視を停止する
 */
- (void)stopAllMonitoring;

@end

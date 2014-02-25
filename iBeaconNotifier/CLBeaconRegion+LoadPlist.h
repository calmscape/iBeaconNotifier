//
//  CLBeaconRegion+LoadPlist.h
//  iBeaconNotifier
//
//  Created by Masahiro Murase on 2014/02/24.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLBeaconRegion (LoadPlist)
/**
 監視するビーコン領域が定義されたplistを読み込んでCLBeacolRegionオブジェクトのセットとして返す
 */
+ (NSSet *)beaconRegionsFromPlist:(NSString *)plistName;

@end

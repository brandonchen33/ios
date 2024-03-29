//
//  BLEDeviceViewController.h
//  Key_chain
//
//  Created by Brandon Chen on 1/8/14.
//  Copyright (c) 2014 Brandon Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SprintronCBPeripheral.h"


@interface BLEDeviceViewController : UITableViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property(nonatomic,strong) CBCentralManager * BLECentralManager;
@property(nonatomic,strong) NSMutableArray* Peripheral_list;
@property(nonatomic,strong) NSMutableArray* Connected_Peripheral_list;
@property(nonatomic,strong) NSMutableArray* registeredPeripherallist;
@property(nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITableView *DeviceTableView;
@property (weak) NSTimer *repeatingTimer;

- (void)startRepeatingTimer;
- (void)targetMethod:(NSTimer*)theTimer;
//- (void)invocationMethod:(NSDate *)date;
- (NSDictionary *)userInfo;



@end


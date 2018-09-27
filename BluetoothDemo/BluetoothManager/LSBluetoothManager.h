//
//  BluetoothManager.h
//  BluetoothDemo
//
//  Created by HSDM10 on 2018/9/4.
//  Copyright © 2018年 HSDM10. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface LSBluetoothModel : NSObject

@property(nonatomic, strong) CBPeripheral *peripheral;
/*
 advertisementData 最小包含三条信息
 {
 kCBAdvDataIsConnectable = 1;
 kCBAdvDataLocalName = "DOGNESS_5_00E012345679";
 kCBAdvDataServiceUUIDs =     (
 FFCC
 );
 }
 */
@property(nonatomic, strong) NSDictionary<NSString *,id> *advertisementData;
@property(nonatomic, strong) NSNumber *RSSI;


@end

@class LSBluetoothManager;

@protocol LSBluetoothManagerDelegate <NSObject>

@optional
// 获取设备数组,会调用多次，需要先调用- (void)startScanDevices;
- (void)manager:(LSBluetoothManager *_Nullable)manager didDiscoverDeveices:(nullable NSMutableArray <LSBluetoothModel *>*)peripheralsArrM error:(nullable NSError *)error;

// 连接某一台设备是否成功的结果，需要先调用- (void)conect:(CBPeripheral *)peripheral;
- (void)manager:(LSBluetoothManager *_Nonnull)manager connectedDevice:(nonnull CBPeripheral *)peripheral state:(BOOL)state;

// 写入数据是否成功结果，需要先调用writeWithSeviceUUID:(NSString *)seviceUUID CharacteristicWriteUUID:(NSString *)characteristicWriteUUID CharacteristicNotifyUUID:(NSString *)characteristicNotifyUUID CMD:(NSString *)CMDString;
- (void)manager:(LSBluetoothManager *_Nullable)manager didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic receiveData:(NSData *_Nullable)receiveData error:(nullable NSError *)error;

@end

@interface LSBluetoothManager : NSObject

@property (nonatomic, weak, nullable) id <LSBluetoothManagerDelegate> delegate;

// 初始化蓝牙,必须
+ (instancetype _Nonnull )shareManager;

// 蓝牙是否打开
//- (BOOL)isAuthorizationOpen;

// 开始扫描,prefix: 只查找某一个前缀开头的设备,传nil默认扫描所有
- (void)startScanDevicesHasNamePrefix:(NSString *_Nullable)nameprefix;

// 结束扫描
- (void)stopScanDevices;

// 连接某一台设备
- (void)conect:(CBPeripheral *_Nonnull)peripheral SeviceUUID:(NSString * _Nonnull )seviceUUID CharacteristicWriteUUID:(NSString *_Nonnull)characteristicWriteUUID CharacteristicNotifyUUID:(NSString *_Nonnull)characteristicNotifyUUID;

// 判断获取某一台设备是否在线,这里凭蓝牙名称判断
- (BOOL)isOnLine:(NSString *_Nonnull)peripheralName  seviceUUID:(NSString *_Nonnull)seviceUUID;
//- (BOOL)isOnLine:(CBPeripheral *_Nonnull)peripheral;

// 断开某一台设备
- (void)disconect:(CBPeripheral *_Nullable)peripheral;

// 写入数据，这里的命令是NSString -> NSData
- (void)writeWithCMD:(NSString *_Nonnull)CMDString;
//- (void)writeWithSeviceUUID:(NSString * _Nonnull )seviceUUID CharacteristicWriteUUID:(NSString *_Nonnull)characteristicWriteUUID CharacteristicNotifyUUID:(NSString *_Nonnull)characteristicNotifyUUID CMD:(NSString *_Nonnull)CMDString;


/*
 问题点1：不能连续写
 [manager writeWithCMD:@"sens0000000000000000"];
 [manager writeWithCMD:@"senr0000000000000000"];
 
 */
@end


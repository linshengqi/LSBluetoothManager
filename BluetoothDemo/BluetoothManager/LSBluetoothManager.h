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
 advertisementData 至少包含三条信息
 {
 kCBAdvDataIsConnectable = 1;
 kCBAdvDataLocalName = "DOGNESS_5_00E012345679";  // kCBAdvDataLocalName有时候会是null
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
// 获取设备,会调用多次，需要先调用- (void)startScanDevices;
- (void)manager:(LSBluetoothManager *_Nullable)manager didDiscoverDeveice:(nonnull LSBluetoothModel *)peripheral error:(nullable NSError *)error;

// 连接某一台设备是否成功的结果，需要先调用- (void)conect:(CBPeripheral *)peripheral;
- (void)manager:(LSBluetoothManager *_Nonnull)manager connectedDevice:(nonnull CBPeripheral *)peripheral state:(BOOL)state;

// 写入数据是否成功结果，需要先调用writeWithPeripheral:(CBPeripheral *_Nonnull)peripheral ServiceUUID:(NSString * _Nonnull )ServiceUUID CharacteristicWriteUUID:(NSString *_Nonnull)characteristicWriteUUID CharacteristicNotifyUUID:(NSString *_Nonnull)characteristicNotifyUUID CMD:(NSString *_Nonnull)CMDString;
- (void)manager:(LSBluetoothManager *_Nullable)manager didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic receiveData:(NSData *_Nullable)receiveData error:(nullable NSError *)error;

@end

@interface LSBluetoothManager : NSObject

@property (nonatomic, weak, nullable) id <LSBluetoothManagerDelegate> delegate;

// 初始化蓝牙
+ (instancetype _Nonnull )shareManager;

// 蓝牙是否打开,需要设置代理
- (BOOL)isAuthorizationOpen;

// 开始扫描,prefix: 只查找某一个前缀开头的设备,传nil默认扫描所有
- (void)startScanDevicesHasNamePrefix:(NSString *_Nullable)nameprefix;

// 结束扫描
- (void)stopScanDevices;

// 连接某一台设备
- (void)conect:(CBPeripheral *_Nonnull)peripheral ServiceUUID:(NSString * _Nonnull )ServiceUUID CharacteristicWriteUUID:(NSString *_Nonnull)characteristicWriteUUID CharacteristicNotifyUUID:(NSString *_Nonnull)characteristicNotifyUUID;

// 判断获取某一台设备是否在线
- (BOOL)isOnLine:(CBPeripheral *_Nonnull)peripheral ServiceUUID:(NSString *_Nonnull)ServiceUUID;

// 断开某一台设备
- (void)disconect:(CBPeripheral *_Nullable)peripheral;

// 写入数据，这里的命令是NSString -> NSData，没有进行hex处理
- (void)writeWithPeripheral:(CBPeripheral *_Nonnull)peripheral ServiceUUID:(NSString * _Nonnull )ServiceUUID CharacteristicWriteUUID:(NSString *_Nonnull)characteristicWriteUUID CharacteristicNotifyUUID:(NSString *_Nonnull)characteristicNotifyUUID CMD:(NSString *_Nonnull)CMDString;

@end



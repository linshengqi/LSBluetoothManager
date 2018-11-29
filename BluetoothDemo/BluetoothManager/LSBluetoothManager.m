//
//  BluetoothManager.m
//  BluetoothDemo
//
//  Created by HSDM10 on 2018/9/4.
//  Copyright © 2018年 HSDM10. All rights reserved.
//

#import "LSBluetoothManager.h"

@implementation LSBluetoothModel


@end

@interface LSBluetoothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *centralManager;  // 蓝牙管理者
    CBManagerState peripheralState; // 蓝牙权限状态
    NSMutableArray <LSBluetoothModel *>*peripheralsArrM;   // 蓝牙设备数组
    NSMutableArray <NSString *>*peripheralsUUIDArrM;   // 蓝牙设备UUID数组
    NSString *namePrefix;  // 蓝牙设备名称前缀
    CBPeripheral *connectedPeripheral; // 连接上的蓝牙设备
    BOOL isWritingfinished;
}

@property(nonatomic, strong) NSString *seviceUUID;   // 本次的服务通道值
@property(nonatomic, strong) NSString *characteristicWriteUUID;   // 本次写入的特征通道值
@property(nonatomic, strong) NSString *characteristicNotifyUUID;   // 本次通知的特征通道值
@property(nonatomic, strong) NSString *cmdString;   // 本次写入的命令
@property(nonatomic, assign)  BOOL isWritingfinished;
@property(nonatomic, strong) NSMutableArray <NSMutableDictionary *>*cmdArray;

@end

@implementation LSBluetoothManager

#pragma mark - init
+ (instancetype)shareManager {
    static LSBluetoothManager *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[LSBluetoothManager alloc]init];
    });
    return share;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //初始化对象
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        peripheralsArrM = [NSMutableArray array];
        peripheralsUUIDArrM = [NSMutableArray array];
        self.cmdArray = [NSMutableArray array];
        self.isWritingfinished = YES;
        [self addObserver:self forKeyPath:@"isWritingfinished" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}


#pragma mark - public
- (void)startScanDevicesHasNamePrefix:(NSString *)nameprefix {
    namePrefix = nameprefix;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->peripheralState == CBManagerStatePoweredOn) {
            [self->centralManager stopScan];
            // 没有过滤设备
            [self->centralManager scanForPeripheralsWithServices:nil options:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Bluetooth Has Not Open", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    });
    
}

- (void)conect:(CBPeripheral *_Nonnull)peripheral SeviceUUID:(NSString * _Nonnull )seviceUUID CharacteristicWriteUUID:(NSString *_Nonnull)characteristicWriteUUID CharacteristicNotifyUUID:(NSString *_Nonnull)characteristicNotifyUUID {
    self.seviceUUID = seviceUUID;
    self.characteristicWriteUUID = characteristicWriteUUID;
    self.characteristicNotifyUUID = characteristicNotifyUUID;
    [centralManager connectPeripheral:peripheral options:nil];
}


- (void)disconect:(CBPeripheral *)peripheral {
    
    [centralManager cancelPeripheralConnection:peripheral];
}


- (void)stopScanDevices {
    [centralManager stopScan];
}


- (BOOL)isOnLine:(NSString *_Nonnull)peripheralName  seviceUUID:(NSString *)seviceUUID{
    if (peripheralName.length < 1 || !peripheralName) {
        NSLog(@"设备名为空");
        // 写入和通知的值可以为空
        return NO;
    }
    
    if (seviceUUID.length < 1 || !seviceUUID) {
        NSLog(@"服务通道值为空");
        // 写入和通知的值可以为空
        return NO;
    }
    NSLog(@"设备名:%@服务通道值:%@",peripheralName,seviceUUID);
    [peripheralsArrM removeAllObjects];
    [peripheralsUUIDArrM removeAllObjects];
    [self->centralManager scanForPeripheralsWithServices:nil options:nil];
    NSArray *array =  [centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:seviceUUID]]];
    for (CBPeripheral * Peripheral in array) {
        NSLog(@"已经连接的设备：%@",Peripheral);
        if ([Peripheral.name isEqualToString:peripheralName]) {
            [self->centralManager stopScan];
            return YES;
            break;
        }
    }
    return NO;
}

- (void)writeWithSeviceUUID:(NSString * _Nonnull )seviceUUID CharacteristicWriteUUID:(NSString *_Nonnull)characteristicWriteUUID CharacteristicNotifyUUID:(NSString *_Nonnull)characteristicNotifyUUID CMD:(NSString *_Nonnull)CMDString {
    
    if (!self.isWritingfinished) {
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        dictM[@"seviceUUID"] = seviceUUID;
        dictM[@"characteristicWriteUUID"] = characteristicWriteUUID;
        dictM[@"characteristicNotifyUUID"] = characteristicNotifyUUID;
        dictM[@"CMDString"] = CMDString;
        [self.cmdArray addObject:dictM];
        return;
    }
    self.isWritingfinished = NO;
    self.seviceUUID = seviceUUID;
    self.characteristicWriteUUID = characteristicWriteUUID;
    self.characteristicNotifyUUID = characteristicNotifyUUID;
    self.cmdString = CMDString;
    if (self.seviceUUID == nil || [self.seviceUUID isKindOfClass:[NSNull class]] || [self.seviceUUID containsString:@" "]) {
        NSLog(@"服务通道值不能为空");
        // 写入和通知的值可以为空
        return;
    }
    if (connectedPeripheral == nil || [connectedPeripheral isKindOfClass:[NSNull class]] || connectedPeripheral.state != CBPeripheralStateConnected) {
        NSLog(@"蓝牙没有连接");
        // 写入和通知的值可以为空
        return;
    }
    NSArray *array =  [centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:self.seviceUUID]]];
    for (CBPeripheral *peripheral in array) {
        if (peripheral == connectedPeripheral) {
            peripheral.delegate = self;
            // services:传入nil  代表扫描所有服务
            [peripheral discoverServices:@[[CBUUID UUIDWithString:self.seviceUUID]]];
            break;
        }
    }
    
}


#pragma mark - CBCentralManagerDelegate
// 状态更新时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    switch (central.state) {
        case CBManagerStateUnknown:{
            NSLog(@"为知状态");
            peripheralState = central.state;
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"重置状态");
            peripheralState = central.state;
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"不支持的状态");
            peripheralState = central.state;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"未授权的状态");
            peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"关闭状态");
            peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"开启状态－可用状态");
            peripheralState = central.state;
            NSLog(@"%ld",(long)peripheralState);
        }
            break;
        default:
            break;
    }
}

/**
 扫描到设备
 
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
    NSLog(@"发现设备:%@  信号强度%@",peripheral, RSSI);
    LSBluetoothModel *model = [[LSBluetoothModel alloc]init];
    model.peripheral = peripheral;
    model.advertisementData = advertisementData;
    model.RSSI = RSSI;
    if (0 < namePrefix.length) {
        if (![peripheralsUUIDArrM containsObject:peripheral.identifier.UUIDString] && 0 < peripheral.name.length && [peripheral.name hasPrefix:namePrefix]) {
            [peripheralsUUIDArrM addObject:peripheral.identifier.UUIDString];
            [peripheralsArrM addObject:model];
        }
    } else {
        if (![peripheralsUUIDArrM containsObject:peripheral.identifier.UUIDString] && 0 < peripheral.name.length) {
            [peripheralsUUIDArrM addObject:peripheral.identifier.UUIDString];
            [peripheralsArrM addObject:model];
        }
    }
    //     NSLog(@"%@",peripheral);
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didDiscoverDeveices:error:)]) {
        [self.delegate manager:self didDiscoverDeveices:peripheralsArrM error:nil];
    }
}

/**
 连接失败
 
 @param central 中心管理者
 @param peripheral 连接失败的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@连接失败",peripheral.name);
//    [centralManager connectPeripheral:peripheral options:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:connectedDevice:state:)]) {
        [self.delegate manager:self connectedDevice:peripheral state:NO];
    }
}



/**
 连接断开
 
 @param central 中心管理者
 @param peripheral 连接断开的设备
 @param error 错误信息
 */

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"%@断开连接",peripheral.name);
//    [centralManager connectPeripheral:peripheral options:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:connectedDevice:state:)]) {
        [self.delegate manager:self connectedDevice:peripheral state:NO];
    }
}


/**
 连接成功
 
 @param central 中心管理者
 @param peripheral 连接成功的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [centralManager stopScan];
    connectedPeripheral = peripheral;
    NSLog(@"连接:%@成功",peripheral.name);
    peripheral.delegate = self;
    // services:传入nil  代表扫描所有服务
    [peripheral discoverServices:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:connectedDevice:state:)]) {
        [self.delegate manager:self connectedDevice:peripheral state:YES];
    }
}


#pragma mark - CBPeripheralDelegate
/**
 扫描到服务
 
 @param peripheral 服务对应的设备
 @param error 扫描错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 遍历所有的服务
    for (CBService *service in peripheral.services)
    {
        NSLog(@"服务UUIDString:%@",service.UUID.UUIDString);
        // 获取对应的服务
        if ([service.UUID.UUIDString isEqualToString:self.seviceUUID])
        {
            // 根据服务去扫描特征
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:self.characteristicWriteUUID],[CBUUID UUIDWithString:self.characteristicNotifyUUID]] forService:service];
        }
    }
}

/**
 扫描到对应的特征
 
 @param peripheral 设备
 @param service 特征对应的服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // 遍历所有的特征
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"特征值UUIDString:%@",characteristic.UUID.UUIDString);
        if ([characteristic.UUID.UUIDString isEqualToString:self.characteristicNotifyUUID])
        {
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
        if ([characteristic.UUID.UUIDString isEqualToString:self.characteristicWriteUUID] && self.cmdString.length > 1)
        {
            NSLog(@"写入命令：%@",self.cmdString);
            NSData *data =  [self.cmdString dataUsingEncoding:NSUTF8StringEncoding];
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            
        }
        
        
    }
}



/**
 根据特征读到数据
 
 @param peripheral 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if ([characteristic.UUID.UUIDString isEqualToString:self.characteristicNotifyUUID] && self.cmdString.length > 1 && !error)
    {
        NSData *data = characteristic.value;
        //        NSLog(@"根据特征读到数据:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didUpdateValueForCharacteristic:receiveData:error:)]) {
            [self.delegate manager:self didUpdateValueForCharacteristic:characteristic receiveData:data error:error];
        }
        self.isWritingfinished = YES;
    }
    
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (!error) {
        NSLog(@"写入成功");
    } else {
        NSLog(@"写入失败：%@",error.localizedDescription);
    }

}


#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //    NSLog(@"old : %@  new : %@",[change objectForKey:@"old"],[change objectForKey:@"new"]);
    if (self.isWritingfinished && self.cmdArray != nil && self.cmdArray.count > 0 ) {
        NSMutableDictionary *dictM = self.cmdArray.firstObject;
        [self writeWithSeviceUUID:dictM[@"seviceUUID"] CharacteristicWriteUUID:dictM[@"characteristicWriteUUID"] CharacteristicNotifyUUID:dictM[@"characteristicNotifyUUID"] CMD: dictM[@"CMDString"]];
        [self.cmdArray removeObject:dictM];
    }
}

#pragma mark - dealloc
-(void)dealloc{
    
    [self removeObserver:self forKeyPath:@"isWritingfinished" context:nil];
}

@end


# LSBluetoothManager
A Simple BLE Demo Base Running On iPhone And Peripheral


## 1. 概念

![Alt](https://raw.githubusercontent.com/linshengqi/MarkdownPhotos/master/%E8%93%9D%E7%89%99%E6%A6%82%E5%BF%B5.jpg)

 1.  **BLE** ，buletouch low energy，蓝牙4.0设备因为低耗电，所以也叫做BLE；
 2.  **中心设备** ，用于扫描周边蓝牙外设的设备，比如我们上面所说的中心者模式，此时我们的手机就是中心设备；
 3.  **外设** ，被扫描的蓝牙设备，比如我们上面所说的用我们的手机连接小米手环，这时候小米手环就是外设；
 4.  **广播** ，外部设备不停的散播的蓝牙信号，让中心设备可以扫描到，也是我们开发中接收数据的入口；
 5.  **服务(Service)** ，外部设备在与中心设备连接后会有服务，可以理解成一个功能模块，中心设备可以读取服务，筛选我们想要的服务，并从中获取出我们想要特征。（外设可以有多个服务）；
 6.  **特征(Characteristic)** ，服务中的一个单位，一个服务可以多个特征，而特征会有一个value，一般我们向蓝牙设备写入数据、从蓝牙设备读取数据就是这个value；
 7.  **UUID** ，区分不同服务和特征的唯一标识，使用该字端我们可以获取我们想要的服务或者特征（ps: 不同的中心设备（也可以说是不同的手机）对于同一台蓝牙设备，获取到的UUIDString可能是不一样的）。


## 2. CoreBluetooth框架

> CoreBluetooth框架的核心其实是两个东西，peripheral和central, 可以理解成外设和中心。
> 图中两组api分别对应不同的业务场景，左侧叫做中心模式，就是以你的app作为中心，连接其他的外设的场景，而右侧称为外设模式，使用手机作为外设别其他中心设备操作的场景

![Alt](https://raw.githubusercontent.com/linshengqi/MarkdownPhotos/master/CoreBluetoothFramework.jpeg)




#### 蓝牙中心模式流程

```javascript
1. 建立中心角色
2. 扫描外设（discover）
3. 连接外设(connect)
4. 扫描外设中的服务和特征(discover)
    - 4.1 获取外设的services
    - 4.2 获取外设的Characteristics,获取Characteristics的值，获取Characteristics的Descriptor和Descriptor的值
5. 与外设做数据交互(explore and interact)
6. 订阅Characteristic的通知
7. 断开连接(disconnect)
```



#### 蓝牙外设模式流程

```javascript
1. 启动一个Peripheral管理对象
2. 本地Peripheral设置服务,特性,描述，权限等等
3. Peripheral发送广告
4. 设置处理订阅、取消订阅、读characteristic、写characteristic的委托方法
```


## 3. Demo（这里只写了中心者模式）


已经实现了的功能以及代理方法
```javascript
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

// 写入数据，这里的命令是NSString -> NSData，没有进行hex处理
//- (void)writeWithCMD:(NSString *_Nonnull)CMDString;
- (void)writeWithSeviceUUID:(NSString * _Nonnull )seviceUUID CharacteristicWriteUUID:(NSString *_Nonnull)characteristicWriteUUID CharacteristicNotifyUUID:(NSString *_Nonnull)characteristicNotifyUUID CMD:(NSString *_Nonnull)CMDString;
```




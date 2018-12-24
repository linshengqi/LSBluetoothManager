//
//  ViewController.m
//  BluetoothDemo
//
//  Created by HSDM10 on 2018/9/4.
//  Copyright © 2018年 HSDM10. All rights reserved.
//

#import "ViewController.h"
#import "LSBluetoothManager.h"
#import "ViewController2.h"

@interface ViewController ()<LSBluetoothManagerDelegate>
@property (strong, nonatomic) LSBluetoothManager *manager;
@property (strong, nonatomic) NSMutableArray<LSBluetoothModel *> *peripheralsArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    self.manager =  [LSBluetoothManager shareManager];
    self.manager.delegate = self;
    [self.manager startScanDevicesHasNamePrefix:nil];
}

-(void)initUI {
    self.title = NSLocalizedString(@"Device List", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Refresh_64px"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshDeviceList)];
}


- (void)initData {
    self.peripheralsArr = [NSMutableArray array];

}

-(void)refreshDeviceList {
    [self.peripheralsArr removeAllObjects];
     [self.tableView reloadData];
    [self.manager startScanDevicesHasNamePrefix:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralsArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSBluetoothModel *model = self.peripheralsArr[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = model.peripheral.name;
    if (model.peripheral.state == CBPeripheralStateConnected) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@,已连接,点击连接",model.RSSI];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@,未连接,点击连接",model.RSSI];
    }
    NSLog(@"%@",model.advertisementData);
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSBluetoothModel *model = self.peripheralsArr[indexPath.row];
    if (model.peripheral.state != CBPeripheralStateConnected) {
        [self.manager conect:model.peripheral ServiceUUID:@"FFCC" CharacteristicWriteUUID:@"FFC1" CharacteristicNotifyUUID:@"FFC2"];
    }
    
    [self.navigationController pushViewController:[ViewController2 new] animated:YES];
}


- (void)manager:(LSBluetoothManager *)manager didDiscoverDeveice:(nonnull LSBluetoothModel *)peripheral error:(nullable NSError *)error {
    [self.peripheralsArr addObject:peripheral];
    [self.tableView reloadData];
}


@end

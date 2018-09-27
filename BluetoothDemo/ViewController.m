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
{
    NSMutableArray<LSBluetoothModel *> *peripheralsArr;
    LSBluetoothManager *manager;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Device List", nil);
    
    peripheralsArr = [NSMutableArray array];
    
    manager =  [LSBluetoothManager shareManager];
    manager.delegate = self;

   
}


- (void)viewDidAppear:(BOOL)animated {
    if (0 >= peripheralsArr.count) {
         [manager startScanDevicesHasNamePrefix:nil];
    } else {
        [self.tableView reloadData];
    }
}
    

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return peripheralsArr.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSBluetoothModel *model = peripheralsArr[indexPath.row];
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
    
    LSBluetoothModel *model = peripheralsArr[indexPath.row];
    if (model.peripheral.state != CBPeripheralStateConnected) {
        [manager conect:model.peripheral SeviceUUID:@"FFCC" CharacteristicWriteUUID:@"FFC1" CharacteristicNotifyUUID:@"FFC2"];
    }
    
    [self.navigationController pushViewController:[ViewController2 new] animated:YES];
}


- (void)manager:(LSBluetoothManager *)manager didDiscoverDeveices:(NSMutableArray<LSBluetoothModel *> *)peripheralsArrM error:(NSError *)error {
    
    peripheralsArr = peripheralsArrM;
    [self.tableView reloadData];
}


@end

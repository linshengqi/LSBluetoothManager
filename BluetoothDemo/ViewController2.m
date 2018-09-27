//
//  ViewController2.m
//  BluetoothDemo
//
//  Created by HSDM10 on 2018/9/4.
//  Copyright © 2018年 HSDM10. All rights reserved.
//

#import "ViewController2.h"
#import "LSBluetoothManager.h"

@interface ViewController2 ()<LSBluetoothManagerDelegate>
{
    LSBluetoothManager *manager;
}
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    manager =  [LSBluetoothManager shareManager];
    manager.delegate = self;
   
}


- (IBAction)LEDMode:(UIButton *)sender {
//     [manager writeWithCMD:@"mode100000000000000"];
//    [manager writeWithCMD:@"mode100000000000000"];
//    [manager writeWithCMD:@"mode200000000000000"];
//    [manager writeWithCMD:@"mode30000000000000"];
    [manager writeWithCMD:@"mode002559393000000"];
//    [manager writeWithCMD:@"mode500000000000000"];
//    [manager writeWithCMD:@"mode600000000000000"];
//    [manager writeWithCMD:@"mode700000000000000"];
//    [manager writeWithCMD:@"mode800000000000000"];
//    [manager writeWithCMD:@"mode900000000000000"];
}


- (IBAction)getVersion:(UIButton *)sender {
    [manager writeWithCMD:@"revision000000000000"];
}

- (IBAction)setTime:(UIButton *)sender {
    [manager writeWithCMD:@"time2018090813063000"];
}


- (IBAction)getBattery:(UIButton *)sender {
    [manager writeWithCMD:@"battery0000000000000"];
}


- (IBAction)setSentive:(UIButton *)sender {
//    [manager writeWithCMD:@"sens0010010010010000"];
}

- (IBAction)getSentive:(UIButton *)sender {
    [manager writeWithCMD:@"senr0000000000000000"];
}


- (IBAction)getAction:(UIButton *)sender {
    [manager writeWithCMD:@"exer2018090800000000"];
}



- (IBAction)setLEDTime:(UIButton *)sender {
    [manager writeWithCMD:@"settime0010000000000"];
}


- (IBAction)clearData:(UIButton *)sender {
    [manager writeWithCMD:@"cleardata00000000000"];
}

- (void)manager:(LSBluetoothManager *)manager didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic receiveData:(NSData *)receiveData error:(NSError *)error {
    if (!error) {
        NSString *receive = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSLog(@"根据特征%@读到数据:%@",characteristic.UUID.UUIDString, receive);
        self.readLabel.text = receive;
        static NSInteger i = 0;
//        [manager writeWithCMD:[NSString stringWithFormat:@"mode%ld00000000000000",(long)i]];
//        i ++;
    } else {
        NSLog(@"error\n%@----%@",characteristic.UUID.UUIDString,error.localizedDescription);
        self.readLabel.text = [NSString stringWithFormat:@"error:%@",error.localizedDescription];
    }
}


- (void)manager:(LSBluetoothManager *)manager connectedDevice:(CBPeripheral *)peripheral state:(BOOL)state {
    NSLog(@"connectedDevicestate %d",state);
    NSString *title = @"";
    if (state == YES) {
        
        title = [NSString stringWithFormat:@"%@连接成功",peripheral.name];

        
    } else {
        
        title = [NSString stringWithFormat:@"%@连接失败",peripheral.name];
    }

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [alert show];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  ScanSKYBeaconViewController.m
//  SDKDemo
//
//  Created by seekcy on 15/10/8.
//  Copyright (c) 2015年 com.seekcy. All rights reserved.
//

#import "ScanSKYBeaconViewController.h"
#import "SVProgressHUD.h"
#import "SICiBeaconConfigViewController.h"
@import SeekcyBeaconSDK;

@interface ScanSKYBeaconViewController ()<SKYBeaconManagerScanDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *scanUUIDArray;
    NSMutableArray *peripheralsForScanArray;
}

@property (nonatomic, strong) UITableView *tbView;

@end

@implementation ScanSKYBeaconViewController

- (void)loadView{
    [super loadView];
    //
    // tableview
    self.tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
    [self.view addSubview:self.tbView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"签到列表";
    
    //动态数组
    //peripheralsForScanArray扫描周边设备
    //scanUUIDArray扫描UUID
    peripheralsForScanArray = [[NSMutableArray alloc] init];
    scanUUIDArray = [[NSMutableArray alloc] init];
    
    [scanUUIDArray addObject:[[SKYBeaconScan alloc] initWithuuid:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0" name:@"签到教室:"]];
    [scanUUIDArray addObject:[[SKYBeaconScan alloc] initWithuuid:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825" name:@"签到教室:"]];
    
    // 用于解密mac地址
    [SKYBeaconManager sharedDefaults].seekcyDecryptKey = @""; // 你的解密密钥
}

//视图已完全过渡到屏幕上时调用
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    //扫描
    [SKYBeaconManager sharedDefaults].scanBeaconTimeInterval = 1.2;
    [[SKYBeaconManager sharedDefaults] startScanForSKYBeaconWithDelegate:self uuids:scanUUIDArray distinctionMutipleID:NO isReturnValueEncapsulation:NO];
}

//视图被驳回时调用，覆盖或以其他方式隐藏。默认情况下不执行任何操作
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    [[SKYBeaconManager sharedDefaults] stopScanSKYBeacon];
}
-(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%i",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}
#pragma mark - SKYBeaconManagerScanDelegate
//扫描完成
- (void)skyBeaconManagerCompletionScanWithBeacons:(NSArray *)beascons error:(NSError *)error{
    
    if(error){
        
        if(error.code == SKYBeaconSDKErrorBlueToothPoweredOff){
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"error"] maskType:SVProgressHUDMaskTypeBlack];
            
        }
        return;
    }
    
    
    NSLog(@"--skyBeaconManagerCompletionScanWithBeacons--");
    NSLog(@"扫描到：%lu 个",(unsigned long)beascons.count);
    
    [peripheralsForScanArray removeAllObjects];
    [peripheralsForScanArray addObjectsFromArray:beascons];
    
    [self.tbView reloadData];
}


#pragma mark - uitableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return peripheralsForScanArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *model = peripheralsForScanArray[indexPath.row];
    int intString = [model[modelTransitField_major] intValue];
    NSMutableString *s = [NSMutableString string];
    [s appendFormat:@"%@-%@\n点击签到",[self ToHex:intString],model[modelTransitField_minor]];
    
    
    cell.textLabel.text = model[modelTransitField_uuidReplaceName];
    cell.detailTextLabel.text = s;
    
    cell.detailTextLabel.numberOfLines = 50;
    UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 12.0 ];
    cell.detailTextLabel.font  = myFont;
    
    if([model[modelTransitField_isMutipleID] boolValue]){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 40, 5, 17, 32/2)];
        label.text = @"多";
        [cell addSubview:label];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *model = peripheralsForScanArray[indexPath.row];
    
    
    if([[model objectForKey:modelTransitField_isMutipleID] boolValue]){
        SKYBeaconMutipleID *muti = [[SKYBeaconMutipleID alloc] init];
        muti.peripheral = [model objectForKey:modelTransitField_peripheral];
        muti.macAddress = [model objectForKey:modelTransitField_macAddress];
        muti.deviceName = [model objectForKey:modelTransitField_deviceName];
        muti.hardwareVersion = [model objectForKey:modelTransitField_hardwareVersion];
        muti.firmwareVersionMajor = [model objectForKey:modelTransitField_major];
        muti.firmwareVersionMinor = [model objectForKey:modelTransitField_firmwareVersionMinor];
        muti.uuidReplaceName = [model objectForKey:modelTransitField_uuidReplaceName];
        muti.rssi = [model objectForKey:modelTransitField_rssi];
        muti.battery = [[model objectForKey:modelTransitField_battery] integerValue];
        muti.temperature = [[model objectForKey:modelTransitField_temperature] floatValue];
        muti.isLocked = [[model objectForKey:modelTransitField_isLocked] boolValue];
        muti.isSeekcyBeacon = [[model objectForKey:modelTransitField_isSeekcyBeacon] boolValue];
        muti.timestampMillisecond = [[model objectForKey:modelTransitField_timestampMillisecond] longValue];
        muti.intervalMillisecond = [model objectForKey:modelTransitField_intervalMillisecond];
        
        SKYBeaconMutipleIDCharacteristicInfo *info1 = [[SKYBeaconMutipleIDCharacteristicInfo alloc] initWithcharacteristicID:@"1" uuid:[model objectForKey:modelTransitField_proximityUUID] major:[model objectForKey:modelTransitField_major] minor:[model objectForKey:modelTransitField_minor] txPower:[[model objectForKey:modelTransitField_txPower] intValue] measuredPower:@"" isEncrypted:[[model objectForKey:modelTransitField_isEncrypted] boolValue]];
        [muti.characteristicInfo setValue:info1 forKey:SKYBeaconMutipleIDCharacteristicInfoKeyOne];
        
       
    }
    else{
        SKYBeacon *single = [[SKYBeacon alloc] init];
        single.peripheral = [model objectForKey:modelTransitField_peripheral];
        single.macAddress = [model objectForKey:modelTransitField_macAddress];
        single.deviceName = [model objectForKey:modelTransitField_deviceName];
        single.hardwareVersion = [model objectForKey:modelTransitField_hardwareVersion];
        single.firmwareVersionMajor = [model objectForKey:modelTransitField_firmwareVersionMajor];
        single.firmwareVersionMinor = [model objectForKey:modelTransitField_firmwareVersionMinor];
        single.uuidReplaceName = [model objectForKey:modelTransitField_uuidReplaceName];
        single.proximityUUID = [model objectForKey:modelTransitField_proximityUUID];
        single.major =  [model objectForKey:modelTransitField_major];
        single.minor = [model objectForKey:modelTransitField_minor];
        single.measuredPower = [model objectForKey:modelTransitField_measuredPower];
        single.intervalMillisecond = [model objectForKey:modelTransitField_intervalMillisecond];
        single.txPower = [[model objectForKey:modelTransitField_txPower] intValue];
        single.rssi = [model objectForKey:modelTransitField_rssi];
        single.battery = [[model objectForKey:modelTransitField_battery] integerValue];
        single.temperature = [[model objectForKey:modelTransitField_temperature] floatValue];
        single.isLocked = [[model objectForKey:modelTransitField_isLocked] boolValue];
        single.isEncrypted = [[model objectForKey:modelTransitField_isEncrypted] boolValue];
        single.isSeekcyBeacon = [[model objectForKey:modelTransitField_isSeekcyBeacon] boolValue];
        single.timestampMillisecond = [[model objectForKey:modelTransitField_timestampMillisecond] longValue];
        int intString = [model[modelTransitField_major] intValue];
        SICiBeaconConfigViewController *vc = [[SICiBeaconConfigViewController alloc] init];
        vc.textString = self.textString;
        vc.detailBeacon = single;
        NSString *textClass = [NSString stringWithFormat:@"%@-%@",[self ToHex:intString],model[modelTransitField_minor]];
        
        NSString *ns = [NSString stringWithFormat:@"提示:是否在%@-%@签到",[self ToHex:intString],model[modelTransitField_minor]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:ns message:nil preferredStyle:  UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self postData:textClass];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
    }
    }

- (void) postData:(NSString *) textClass{
    NSString *url = @"http://192.168.0.102:8080/tp5/public/index.php";
    NSLog(@"post_begin");
    NSDate *date =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //获取年月日时
    [formatter setDateFormat:@"yyyy"];
    NSInteger currentYear=[[formatter stringFromDate:date] integerValue];
    [formatter setDateFormat:@"MM"];
    NSInteger currentMonth=[[formatter stringFromDate:date]integerValue];
    [formatter setDateFormat:@"dd"];
    NSInteger currentDay=[[formatter stringFromDate:date] integerValue];
    [formatter setDateFormat:@"HH"];
    NSInteger currentHour=[[formatter stringFromDate:date] integerValue];
    NSString *time =  [NSString stringWithFormat:@"%d-%d-%d %d",currentYear,currentMonth,currentDay,currentHour];
    NSString *jsonData = [NSString stringWithFormat:@"{\"username\": \"%@\",\"classroom\":\"%@\",\"intime\": \"%@\"}", self.textString, textClass,time];
    NSLog(@"123321%@",jsonData);
    NSData* postData = [jsonData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];//数据转码;
    NSString *length = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]]; //设置地址
    [request setHTTPMethod:@"POST"]; //设置发送方式
    [request setTimeoutInterval: 20]; //设置连接超时
    [request setValue:length forHTTPHeaderField:@"Content-Length"]; //设置数据长度
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; //设置发送数据的格式
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"]; //设置预期接收数据的格式
    [request setHTTPBody:postData]; //设置编码后的数据
    
    //发起连接，接受响应
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init] ;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]; //返回数据，转码
    if ([responseString isEqualToString:@"success"]){
        [self showAlert:@"签到成功"];
        NSLog(@"qiandao%@",responseString);
    }
    else{
        [self showAlert:@"已签,请勿重复签到"];
    }
}

/**
 *  弹框提示
 */
- (void)showAlert:(NSString *) mes{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:mes delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alert show];
    // 2秒后执行
    [self performSelector:@selector(dimissAlert:) withObject:alert afterDelay:2.0];
}

/**
 *  移除弹框
 */
- (void) dimissAlert:(UIAlertView *)alert {
    if(alert){
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
    }
    
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

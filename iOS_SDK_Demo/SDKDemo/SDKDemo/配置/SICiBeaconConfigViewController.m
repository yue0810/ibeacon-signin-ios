
#import "SICiBeaconConfigViewController.h"
@import SeekcyBeaconSDK;

@interface SICiBeaconConfigViewController ()<SKYBeaconManagerConfigurationDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    BOOL viewShowAfterChooseUUID;
    SKYBeaconConfigSingleID *modelToConfig;
    UIView *inputView;
    BOOL disconnectAfterWrite;
    enum SKYBeaconVersion myBeaconType;
}

@property (strong, nonatomic) UITextField *majorTextField;
@property (strong, nonatomic) UITextField *minorTextField;
@property (strong, nonatomic) UITextField *measurePowerTextField;
@property (strong, nonatomic) UISwitch *lightSensationSwitch;
@property (strong, nonatomic) UISwitch *ledSwitch;


@end

@implementation SICiBeaconConfigViewController

#pragma mark - Life Cycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self connectBeacon];
    NSString *url = @"http://192.168.0.103:8080/tp5/public/index.php";
    NSLog(@"post_begin");
    NSDate *date =[NSDate date];//简书 FlyElephant
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
    NSString *jsonData = [NSString stringWithFormat:@"{\"username\": \"%@\",\"classroom\":\"%@\",\"intime\": \"%@\"}", self.textString, self.textClass,time];
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
        //成功
    }
    else{
        //失败
    }
}


- (void)connectBeacon{
    [[SKYBeaconManager sharedDefaults] connectSingleIDBeacon:self.detailBeacon delegate:self];
    
    // TODO:初始化数据
    modelToConfig = [[SKYBeaconConfigSingleID alloc] initWithBeacon:self.detailBeacon];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}

- (void)dealloc{
    NSLog(@"sicbeaconconfigviewcontroller dealloc");
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}

- (void)navBackPress{
    
    if(![[SKYBeaconManager sharedDefaults] isConnect]){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        __weak SICiBeaconConfigViewController *weak_Self = self;
        
        [[SKYBeaconManager sharedDefaults] cancelBeaconConnection:self.detailBeacon completion:^(BOOL complete, NSError *error) {
           
            if(complete){
                [weak_Self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

#pragma mark - SKYBeaconManagerConfigurationDelegate
- (void)skyBeaconManagerConnectResultSingleIDBeacon:(SKYBeacon *)beacon error:(NSError *)error{
   
    
    if(error == nil){
        
        //
        // TODO:初始化数据
       
        modelToConfig.uuidStringToWrite = beacon.proximityUUID;
        modelToConfig.majorStringToWrite = beacon.major;
        modelToConfig.minorStringToWrite = beacon.minor;
        modelToConfig.measuredPowerStringToWrite = beacon.measuredPower;
        modelToConfig.txPowerStringToWrite = beacon.txPower;
        modelToConfig.intervalStringToWrite = beacon.intervalMillisecond;
        modelToConfig.isLockedToWrite = beacon.isLocked;
        modelToConfig.lockedKeyToWrite = @"";
        modelToConfig.isEncryptedToWrite = beacon.isEncrypted;
        modelToConfig.isLedOnToWrite = beacon.isLedOn;
        
        modelToConfig.lightSensationToWrite.isOn = beacon.lightSensation.isOn;
        modelToConfig.lightSensationToWrite.darkThreshold = beacon.lightSensation.darkThreshold;
        modelToConfig.lightSensationToWrite.darkBroadcastFrequency = beacon.lightSensation.darkBroadcastFrequency;
        modelToConfig.lightSensationToWrite.voltage = beacon.lightSensation.voltage;
        modelToConfig.lightSensationToWrite.updateFrequency = beacon.lightSensation.updateFrequency;
        
        modelToConfig.temperatureUpdateFrequencyToWrite = beacon.temperatureUpdateFrequency;
        
        [self.tableView reloadData];
    }
    else{
        NSLog(@"连接失败");
    }
}

-(void)skyBeaconManagerDisconnectSingleIDBeaconError:(NSError *)error{
    
    if(!error){
        
    }
    else{
        
        if(!disconnectAfterWrite){
            // code 6 , time out
            if(error.code == 6){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接超时断开" message:nil delegate:nil cancelButtonTitle:@"Okey" otherButtonTitles: nil];
                [alert show];
            }
        }
        
    }
}
@end

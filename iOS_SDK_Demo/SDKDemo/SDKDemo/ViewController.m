//
//  ViewController.m
//  SDKDemo
//
//  Created by seekcy on 15/9/30.
//  Copyright (c) 2015年 com.seekcy. All rights reserved.
//

#import "ViewController.h"
#import "ScanSKYBeaconViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //self.navigationItem.title = @"功能列表";
    //用户名提示
    _lbUserName = [[UILabel alloc]init];
    _lbUserName.frame = CGRectMake(20, 160, 80, 40);
    _lbUserName.text = @"用户名:";
    _lbUserName.font = [UIFont systemFontOfSize:20];
    _lbUserName.textAlignment = NSTextAlignmentLeft;
    
    //密码提示
    
    _lbPassword = [[UILabel alloc]init];
    _lbPassword.frame = CGRectMake(20, 240, 80, 40);
    _lbPassword.text = @"密码:";
    _lbPassword.font = [UIFont systemFontOfSize:20];
    _lbPassword.textAlignment = NSTextAlignmentLeft;
    
    //用户名输入框
    
    _tfUserName = [[UITextField alloc]init];
    _tfUserName.frame = CGRectMake(120, 160, 180, 40);
    _tfUserName.placeholder = @"请输入用户名";
    _tfUserName.borderStyle = UITextBorderStyleRoundedRect;
    
    _tfPassword = [[UITextField alloc]init];
    _tfPassword.frame = CGRectMake(120, 240, 180, 40);
    _tfPassword.placeholder = @"请输入密码";
    _tfPassword.borderStyle = UITextBorderStyleRoundedRect;
    _tfPassword.secureTextEntry = YES;
    
    _btLogin = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btLogin.frame = CGRectMake(120, 400, 80, 40);
    [_btLogin setTitle:@"登陆" forState:UIControlStateNormal];
    [_btLogin addTarget:self action:@selector(pressLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_lbUserName];
    [self.view addSubview:_lbPassword];
    [self.view addSubview:_tfUserName];
    [self.view addSubview:_tfPassword];
    [self.view addSubview:_btLogin];
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //回收键盘对象
    [_tfUserName resignFirstResponder];
    [_tfPassword resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressLogin {
    
    NSString* strTextName = _tfUserName.text;
    NSString* strTextPass = _tfPassword.text;
    NSString *url = @"http://192.168.0.102:8080/tp5/public/admin.php";
    NSString *jsonData = [NSString stringWithFormat:@"{\"username\": \"%@\",\"userpassword\":\"%@\"}", strTextName, strTextPass];
    
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
    NSLog(@"登陆成功%@",responseString);
    if([responseString isEqualToString:@"success"]   )
    {
        
    ScanSKYBeaconViewController *vc = [[ScanSKYBeaconViewController alloc] init];
        vc.textString = strTextName;
    [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名或密码错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end

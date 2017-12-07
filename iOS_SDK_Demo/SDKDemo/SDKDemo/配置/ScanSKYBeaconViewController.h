//
//  ScanSKYBeaconViewController.h
//  SDKDemo
//
//  Created by seekcy on 15/10/8.
//  Copyright (c) 2015年 com.seekcy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanSKYBeaconViewController : UIViewController
@property(nonatomic,copy) NSString *textString;

- (void) postData:(NSString *) textClass;
-(NSString *)ToHex:(long long int)tmpid;
@end

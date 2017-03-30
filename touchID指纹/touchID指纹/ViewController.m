//
//  ViewController.m
//  touchID指纹
//
//  Created by lpn on 16/3/31.
//  Copyright © 2016年 lpn. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // ios8.0以上 iphone5s之后才有touchID功能
    [self authenticateUser];

}
- (void)authenticateUser
{
    //初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    
    //localizedFallbackTitle设置为@""代表指纹输错不会出现右侧“输入密码”字样
    context.localizedFallbackTitle = @"";
    //错误对象
    NSError* error = nil;
    NSString* result = @"百泉贷利用你的Touch ID解锁";
    
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) { // 主线程
        //支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
#warning 后台线程
            if (success) {
                //验证成功，后台线程
                NSLog(@"验证成功");
            }
            else
            {
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        NSLog(@"切换到其他APP，系统取消验证Touch ID 其他app切入Authentication was cancelled by the system");
                        //切换到其他APP，系统取消验证Touch ID 其他app切入
                        break;
                    }
                    case LAErrorAppCancel:
                    {
                        NSLog(@"用户不能控制的挂起 比如打电话");
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        NSLog(@"用户取消验证Touch IDAuthentication was cancelled by the user");
                        //用户取消验证Touch ID
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        NSLog(@"用户选择输入密码，切换主线程处理User selected to enter custom password");
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择输入密码，切换主线程处理
                        }];
                        break;
                    }
                    case LAErrorTouchIDLockout:
                    {
                       NSLog(@"多次TouchID失败 Touch ID被锁");// 输入多次不正确 执行代码
                        break;
                    }
                    case LAErrorInvalidContext:
                    {
                        NSLog(@"LAContext对象被释放掉了，造成的授权失败");
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //其他情况，切换主线程处理
                        }];
                        break;
                    }
                }
                NSLog(@"%@",error.localizedDescription);
            }
        }];
    }
    else{
#warning 主线程
        //不支持指纹识别，LOG出错误详情。比如设备不支持或者指纹没开启（指纹没开启也包括输入错误多次被锁定Touch ID）
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                NSLog(@"设备Touch ID不可用 用户未录入TouchID is not enrolled");
                // 设备Touch ID不可用 用户未录入
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                NSLog(@"系统未设置密码A passcode has not been set");
                // 系统未设置密码
                break;
            }
            case LAErrorTouchIDNotAvailable:
            {
                NSLog(@"设备Touch ID不可用，例如未打开A passcode has not been set");
                // 设备Touch ID不可用，例如未打开
                break;
            }
            default:
            {
                NSLog(@"TouchID not available");
                // Touch ID被锁定之后，点击屏幕跳到这里
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
}
@end

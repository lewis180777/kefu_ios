//
//  AppDelegate.m
//  kefu
//
//  Created by houxh on 16/4/6.
//  Copyright © 2016年 beetle. All rights reserved.
//

#import "AppDelegate.h"
#import <gobelieve/IMService.h>
#import <gobelieve/PeerMessageHandler.h>
#import <gobelieve/GroupMessageHandler.h>
#import <gobelieve/CustomerMessageHandler.h>
#import <gobelieve/CustomerMessageDB.h>
#import <gobelieve/CustomerOutbox.h>
#import <gobelieve/IMHttpAPI.H>
#import "CustomerSupportMessageHandler.h"
#import "CustomerMessageListViewController.h"
#import "LoginViewController.h"
#import "Config.h"
#import "Token.h"

@interface AppDelegate ()<UIAlertViewDelegate>{
    NSString *downloadUrl;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    // Override point for customization after application launch.
    [IMHttpAPI instance].apiURL = IM_API;
    [IMService instance].host = IM_HOST;
    [IMService instance].appID = APPID;

#if TARGET_IPHONE_SIMULATOR
    [IMService instance].deviceID = @"7C8A8F5B-E5F4-4797-8758-05367D2A4D61";
    NSLog(@"device id:%@", @"7C8A8F5B-E5F4-4797-8758-05367D2A4D61");
#else
    [IMService instance].deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"device id:%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
#endif

    [IMService instance].peerMessageHandler = [PeerMessageHandler instance];
    [IMService instance].groupMessageHandler = [GroupMessageHandler instance];
    [IMService instance].customerMessageHandler = [CustomerSupportMessageHandler instance];
    [[IMService instance] startRechabilityNotifier];

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];

    Token *token = [Token instance];
    if (token.uid > 0 && token.accessToken.length > 0) {
        //已经登录
        CustomerMessageListViewController *ctrl = [[CustomerMessageListViewController alloc] init];
        UINavigationController *navigationCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        self.window.rootViewController = navigationCtrl;
        [self.window makeKeyAndVisible];
    } else {
        LoginViewController *ctrl = [[LoginViewController alloc] init];
        self.window.rootViewController = ctrl;
        [self.window makeKeyAndVisible];
    }
    
    
    [self GetAppStrore];
    

    return YES;
}


-(void)GetAppStrore{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        // 系统并发线程池
        // ... 处理阻塞操作
        NSString *newVersion= @"";
       
        //    NSString *releaseNotes = @"";
        
        
        NSString *myURL = nil;
        
        myURL = @"http://itunes.apple.com/cn/lookup?id=1121843265";
        

        
        
        
        NSURL *url = [NSURL URLWithString:myURL];
        
        
        //通过url获取数据
        NSString *jsonResponseString =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"通过appStore获取的数据是：%@",jsonResponseString);
        
        //解析json数据为数据字典
        NSData *data = [jsonResponseString dataUsingEncoding:NSUTF8StringEncoding];
        
        if(data == nil){
            //        [self showSimpleAlertView:@"网络连接异常！"];
        }else{
            NSDictionary *loginAuthenticationResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //[self dictionaryFromJsonFormatOriginalData:jsonResponseString];
            
            NSLog(@"通过appStore获取的版本号是：%@ ---- %@",loginAuthenticationResponse,newVersion);
            //获取本地软件的版本号
            NSString *localVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            
            NSArray *appArray = loginAuthenticationResponse[@"results"];
            
            if ([appArray count] > 0) {
                downloadUrl = [appArray[0] objectForKey:@"trackViewUrl"];
                
                newVersion =  [appArray[0] objectForKey:@"version"];
                
                localVersion = [localVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
                newVersion = [newVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
                
                NSLog(@"url -- %@,version -- %@ ",downloadUrl,newVersion);
                
                if ([newVersion floatValue] > [localVersion floatValue])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 更新界面
                        // 系统串行主线程池
                        // ... 更新UI操作
                        
//                        UIAlertView *alerView = [UIAlertView bk_alertViewWithTitle:@"提示" message:@"AppStore有新版本更新"];
//                        
//                        [alerView bk_addButtonWithTitle:@"取消" handler:^{
//                            
//                            NSDLog(@"We hate you.");
//                        }];
//                        [alerView bk_addButtonWithTitle:@"马上下载" handler:^{
//                            
//                            NSDLog(@"Yay!");
//                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
//
//                            
//                        }];
                        
                        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"AppStore有新版本更新" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"马上下载", nil];
                        
                        [alerView show];
                        

                    });

                }
                
            }
        }

    });
    
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSLog(@"Yay!");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];

    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
   [[IMService instance] enterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[IMService instance] enterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"device token is:%@", newToken);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRegisterForRemoteNotificationsWithDeviceToken"
                                                        object:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"register remote notification error:%@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"did receive remote notification:%@", userInfo);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        NSLog(@"didRegisterUser");
        [application registerForRemoteNotifications];
    }
}

@end

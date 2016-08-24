//
//  EIMSAppDelegate.m
//  SP2P_6.1
//
//  Created by EIMS. on 14-6-6.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import "AppDelegate.h"
#import "GestureLockViewController.h"
#import "GuideViewController.h"

#import "MainViewController.h"

#import "BPush.h"
#import "JSONKit.h"
#import "OpenUDID.h"


#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApi.h>
#import <QQConnection/QQConnection.h>
//#import "WeiboApi.h"
#import <TencentWeiboConnection/TencentWeiboConnection.h>
#import "WXApi.h"
//#import "YXApi.h"
//#import <RennSDK/RennClient.h>
//#import <RennSDK/RennSDK.h>
//#import <YiXinConnection/YiXinConnection.h>

#define SUPPORT_IOS8 1   //是否在IOS8设备运行


#import "InfoNewsViewController.h" //活动或新闻详情
#import "BillingDetailsViewController.h" //借款账单详情
#import "BorrowingDetailsViewController.h"//借款标详情

#import "OpenLockViewController.h"

@interface AppDelegate ()<UIAlertViewDelegate, HTTPClientDelegate>

@property (copy,nonatomic) NSString *idNum;
@property (copy,nonatomic) NSString *billidNum;
@property (copy,nonatomic) NSString *bidNum;
@property (copy,nonatomic) NSString *typeStr;
@property (strong,nonatomic) GestureLockViewController *gestureLockView;
@property (strong,nonatomic) OpenLockViewController *openLockView;

@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UIImageView *adImageView;
@property(nonatomic ,strong) NetWorkClient *requestClient;
@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ShareSDK registerApp:@"41721a1de002"];     //参数为ShareSDK官网中添加应用后得到的AppKey
    
    //添加新浪微博应用 注册网址 http://open.weibo.com
    //    [ShareSDK connectSinaWeiboWithAppKey:@"164313040"
    //                               appSecret:@"59fa2a2365b4b641259288682a15b554"
    //                             redirectUri:@"http://www.sharesdk.cn"];
    
//    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
//                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
//                             redirectUri:@"http://www.sharesdk.cn"];
//    
    //    //添加腾讯微博应用 注册网址 http://dev.t.qq.com
    //    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
    //                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
    //                                redirectUri:@"http://www.sharesdk.cn"
    //                                   wbApiCls:[WeiboApi class]];
    
    //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
    [ShareSDK connectQZoneWithAppKey:@"1103427727"
                           appSecret:@"NlovF77litfDDiUd"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    //添加QQ应用  注册网址  http://open.qq.com/
    [ShareSDK connectQQWithQZoneAppKey:@"1103432166"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    //添加微信应用 注册网址 http://open.weixin.qq.com
    [ShareSDK connectWeChatWithAppId:@"wx25227362d6879199"
                           wechatCls:[WXApi class]];
    
    //添加豆瓣应用  注册网址 http://developers.douban.com
    [ShareSDK connectDoubanWithAppKey:@"07d08fbfc1210e931771af3f43632bb9"
                            appSecret:@"e32896161e72be91"
                          redirectUri:@"http://dev.kumoway.com/braininference/infos.php"];
    
    //添加人人网应用 注册网址  http://dev.renren.com
//    [ShareSDK connectRenRenWithAppId:@"226427"
//                              appKey:@"fc5b8aed373c4c27a05b712acba0f8c3"
//                           appSecret:@"f29df781abdd4f49beca5a2194676ca4"
//                   renrenClientClass:[RennClient class]];
    
    //    添加易信应用
//    [ShareSDK connectYiXinWithAppId:@"yx4c3f37ac186948d4b4d5216d0ddefafb"
//                           yixinCls:[YXApi class]];
    
    //连接邮件
    [ShareSDK connectMail];
    
    //连接短信分享
    [ShareSDK connectSMS];
    
    //百度云推送
    //初始化 Push
    [BPush setupChannel:launchOptions];
    //设置 Push delegate
    [BPush setDelegate:self];
    //    [application setApplicationIconBadgeNumber:0];
    //注册push服务
#if SUPPORT_IOS8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        //        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        //        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else
#endif
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    [self startAdView];
    
    [self performSelector:@selector(startAnim) withObject:nil afterDelay:1.5f];
    
    if (launchOptions != nil) {
        DLOG(@"LUN:%@", launchOptions);
        
        NSDictionary *userInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
        DLOG(@"推送内容为:%@",userInfo);
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        if ([userInfo objectForKey:@"id"] != nil &&![[userInfo objectForKey:@"id"] isEqual:[NSNull null]]) {
            
            NSString *idStr = [userInfo objectForKey:@"id"];
            //        NSString *typeStr1 = [userInfo objectForKey:@"type"];
            //        NSString *titleStr = [userInfo objectForKey:@"title"];
            //        NSString *alert = [userInfo objectForKey:@"description"];
            //        NSString *badgenum = [[userInfo objectForKey:@"aps"] objectForKey:@"badge"];
            InfoNewsViewController *infoView = [[InfoNewsViewController alloc] init];
            UINavigationController *infoNv = [[UINavigationController alloc] initWithRootViewController:infoView];
            infoView.newsId = [NSString stringWithFormat:@"%@",idStr];
            infoView.typeStr = @"推送";
            [self.window.rootViewController presentViewController:infoNv animated:YES completion:nil];
            
        }
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"Arial-BoldMT" size:18.0], NSFontAttributeName, nil]];
    
    return YES;
}

-(void) startAdView
{
    //设置动画效果
    _viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];// 广告界面，可以为webview等
    _viewContent.backgroundColor = [UIColor clearColor];
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    // 加一张遮盖底图，防止闪屏，空白跳转
    if (IS_iPhone6plus) {
        bg.image = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h"];
    } else if(IS_iPhone6){
        bg.image = [UIImage imageNamed:@"LaunchImage-800-667h"];
    } else if(IS_iPhone5) {
        bg.image = [UIImage imageNamed:@"LaunchImage-568h"];
    } else {
        bg.image = [UIImage imageNamed:@"LaunchImage"];
    }
    [_viewContent addSubview:bg];
    
    _adImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    //将图片添加到UIImageView对象中
    _adImageView.backgroundColor = [UIColor clearColor];
    // 加载上一次缓存的广告图
    //    _adImageView.image = [UIImage imageNamed:@"guide_page3.jpg"];
    NSURL *url = [NSURL URLWithString:[[AppDefaultUtil sharedInstance] getAppImage]];
    [_adImageView sd_setImageWithURL:url];
    
    [_viewContent addSubview:_adImageView];
    
    [self.window addSubview:_viewContent];
    [self.window bringSubviewToFront:_viewContent];
    
    // 请求网络图片，延时0.2s，避免 AFNetworkReachabilityManager未准备就绪的Bug
    [self performSelector:@selector(requestData) withObject:nil afterDelay:0.2f];
}

-(void) startAnim
{
    [UIView animateWithDuration:0.5 animations:^{
        _viewContent.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    //    [self performSelector:@selector(startRootView) withObject:nil afterDelay:0.2f];
    
    [self startRootView];
}

-(void) startRootView
{
    
    
    if(![[AppDefaultUtil sharedInstance] isFirstLancher])
    {
        // 第一次启动，直接启动引导界面
        [[AppDefaultUtil sharedInstance] setFirstLancher:YES];
        [[AppDefaultUtil sharedInstance] setRemeberUser:YES];
        
        [AppDelegateInstance setOpenType:@"1"];
        
        //启动引导页
        GuideViewController *guideView = [[GuideViewController alloc]  init];
        self.window.rootViewController = guideView;
        [self.window makeKeyAndVisible];
        
    } else {
        
        DLOG(@"=Account==%@=====", [[AppDefaultUtil sharedInstance] getDefaultAccount]);
        DLOG(@"=Password==%@=====", [[AppDefaultUtil sharedInstance] getDefaultUserPassword]);
        DLOG(@"=GesturesPassword==%@=====", [[AppDefaultUtil sharedInstance] getGesturesPasswordWithAccount:[[AppDefaultUtil sharedInstance] getDefaultUserName]]);
        if ([[AppDefaultUtil sharedInstance] getDefaultAccount] !=nil && ![[[AppDefaultUtil sharedInstance] getDefaultAccount] isEqualToString:@""] && [[AppDefaultUtil sharedInstance] getDefaultUserPassword] !=nil && ![[[AppDefaultUtil sharedInstance] getDefaultUserPassword] isEqualToString:@""] && [[AppDefaultUtil sharedInstance] getGesturesPasswordWithAccount:[[AppDefaultUtil sharedInstance] getDefaultUserName]] != nil && ![[[AppDefaultUtil sharedInstance] getGesturesPasswordWithAccount:[[AppDefaultUtil sharedInstance] getDefaultUserName]] isEqualToString:@""]) {
            // 有手势密码，而且记录了登陆账号与密码
            
            //手势密码页面
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [UIApplication sharedApplication].statusBarHidden = NO;
            _gestureLockView = [[GestureLockViewController alloc] init];
            self.window.rootViewController = _gestureLockView;
            
            
            
            
        } else {
            // 其他情况直接算未登陆，直接跳转到主界面
            
            //主界面
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [UIApplication sharedApplication].statusBarHidden = NO;
            MainViewController *main = [[MainViewController alloc] rootViewController];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:main];
            [navigationController setNavigationBarHidden:YES];
            self.window.rootViewController = navigationController;
        }
        [self.window makeKeyAndVisible];
        
        
    }
    
    
}


- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

#if SUPPORT_IOS8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"deviceToken"];
    [userDefaults setObject:deviceToken forKey:@"deviceToken"];
    DLOG(@"My token is: %@", [userDefaults objectForKey:@"deviceToken"]);
    //注册 Device Token
    [BPush registerDeviceToken:[userDefaults objectForKey:@"deviceToken"]];
    //绑定
    [BPush bindChannel];
    
    NSString *str2 = [@"dfdkjfkd is " stringByAppendingFormat: @"Register device token: %@\n openudid: %@", deviceToken, [OpenUDID value]];
    DLOG(@"str2 str2 str2 is %@",str2);
    DLOG(@"deviceToken is %@",deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
    DLOG(@"注册设备时的错误为:%@",error);
    
    
}


//返回绑定等调用的结果
- (void) onMethod:(NSString*)method response:(NSDictionary*)data {
    DLOG(@"On method:%@", method);
    DLOG(@"data:%@", [data description]);
    NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        
        if (returnCode == BPushErrorCode_Success) {
            DLOG(@"appid is %@ userid is %@ channelid is %@ requestid is %@",appid,userid,channelid,requestid);
            
            // 在内存中备份，以便短时间内进入可以看到这些值，而不需要重新bind
            self.appId = appid;
            self.channelId = channelid;
            self.userId = userid;
            DLOG(@"app id is %@,channelId is %@,userId is %@",appid,channelid,userid);
            
        }
    } else if ([BPushRequestMethod_Unbind isEqualToString:method]) {
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode == BPushErrorCode_Success) {
            //            self.viewController.appidText.text = nil;
            //            self.viewController.useridText.text = nil;
            //            self.viewController.channelidText.text = nil;
        }
    }
    NSString *str = [[NSString alloc] initWithFormat: @"%@ return: \n%@", method, [data description]];
    DLOG(@"返回的数据是 %@",str);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    DLOG(@"Receive Notify: %@", [userInfo JSONString]);
    if ([userInfo objectForKey:@"id"] != nil &&![[userInfo objectForKey:@"id"] isEqual:[NSNull null]] && [userInfo objectForKey:@"billId"] != nil &&![[userInfo objectForKey:@"billId"] isEqual:[NSNull null]] && [userInfo objectForKey:@"bidId"] != nil && ![[userInfo objectForKey:@"bidId"] isEqual:[NSNull null]]) {
        
        NSString *idStr = [userInfo objectForKey:@"id"];
        NSString *billIdStr = [userInfo objectForKey:@"billId"];
        NSString *bidIdStr = [userInfo objectForKey:@"bidId"];
        _typeStr = [userInfo objectForKey:@"type"];
        NSString *titleStr = [userInfo objectForKey:@"title"];
        NSString *descriptionStr = [userInfo objectForKey:@"description"];
        NSString *badgenum = [[userInfo objectForKey:@"aps"] objectForKey:@"badge"];
        if([badgenum integerValue])
        {
            [application setApplicationIconBadgeNumber:[badgenum integerValue]];
        }
        
        if (![[UIApplication sharedApplication].keyWindow isKindOfClass:[GestureLockViewController class]]&& ![[UIApplication sharedApplication].keyWindow isKindOfClass:[OpenLockViewController class]]) {
            
            //活动类型
            if ([_typeStr isEqualToString:@"1"]) {
                
                _idNum = idStr;
                if (application.applicationState == UIApplicationStateActive) {
                    // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleStr
                                                                        message:descriptionStr
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定",nil];
                    [alertView show];
                }else{
                    
                    InfoNewsViewController *infoView = [[InfoNewsViewController alloc] init];
                    UINavigationController *infoNv = [[UINavigationController alloc] initWithRootViewController:infoView];
                    infoView.newsId = [NSString stringWithFormat:@"%@",_idNum];
                    infoView.typeStr = @"推送";
                    [self.window.rootViewController presentViewController:infoNv animated:YES completion:nil];
                    
                }
                
            }
            //账单类型
            if ([_typeStr isEqualToString:@"2"]) {
                
                _billidNum = billIdStr;
                if (application.applicationState == UIApplicationStateActive)
                {
                    // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleStr
                                                                        message:descriptionStr
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定",nil];
                    [alertView show];
                }else{
                    
                    BillingDetailsViewController *billView = [[BillingDetailsViewController alloc] init];
                    UINavigationController *billNav = [[UINavigationController alloc] initWithRootViewController:billView];
                    billView.billId = [NSString stringWithFormat:@"%@",_billidNum];
                    billView.isPay = NO;
                    [self.window.rootViewController presentViewController:billNav animated:YES completion:nil];
                    
                }
            }
            
            //账单类型
            if ([_typeStr isEqualToString:@"3"]) {
                
                _bidNum = bidIdStr;
                if (application.applicationState == UIApplicationStateActive)
                {
                    // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleStr
                                                                        message:descriptionStr
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定",nil];
                    [alertView show];
                }else{
                    
                    BorrowingDetailsViewController *borrowingDetailsView = [[BorrowingDetailsViewController alloc] init];
                    UINavigationController *bidNav = [[UINavigationController alloc] initWithRootViewController:borrowingDetailsView];
                    borrowingDetailsView.borrowID = [NSString stringWithFormat:@"%@", _bidNum];
                    borrowingDetailsView.stateNum = 0;
                    [self.window.rootViewController presentViewController:bidNav animated:YES completion:nil];
                    
                }
            }
            
        }
        
        [application setApplicationIconBadgeNumber:0];
        [BPush handleNotification:userInfo];
    }
    
}



#pragma mark UIalertViewdelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=0) {
        if ([_typeStr isEqualToString:@"1"]) {
            InfoNewsViewController *infoView = [[InfoNewsViewController alloc] init];
            UINavigationController *infoNv = [[UINavigationController alloc] initWithRootViewController:infoView];
            infoView.newsId = [NSString stringWithFormat:@"%@",_idNum];
            infoView.typeStr = @"推送";
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:infoNv animated:YES completion:nil];
            
        }else if ([_typeStr isEqualToString:@"2"]){
            
            BillingDetailsViewController *billView = [[BillingDetailsViewController alloc] init];
            UINavigationController *billNav = [[UINavigationController alloc] initWithRootViewController:billView];
            billView.billId = [NSString stringWithFormat:@"%@",_billidNum];
            billView.isPay = NO;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:billNav animated:YES completion:nil];
            
        }else{
            
            BorrowingDetailsViewController *borrowingDetailsView = [[BorrowingDetailsViewController alloc] init];
            UINavigationController *bidNav = [[UINavigationController alloc] initWithRootViewController:borrowingDetailsView];
            borrowingDetailsView.borrowID = [NSString stringWithFormat:@"%@", _bidNum];
            borrowingDetailsView.stateNum = 0;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:bidNav animated:YES completion:nil];
            
        }
    }
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //获取 appid
    self.appId = [BPush getAppId];
    self.userId = [BPush getUserId];
    self.channelId = [BPush getChannelId];
    
    DLOG(@"相关ID2 是app  %@  user %@  channel %@",[BPush getAppId], [BPush getUserId],[BPush getChannelId]);
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //    // 用户退出活动状态时，添加手势界面。
    //    if ([[AppDefaultUtil sharedInstance] getDefaultAccount] !=nil && ![[[AppDefaultUtil sharedInstance] getDefaultAccount] isEqualToString:@""] && [[AppDefaultUtil sharedInstance] getDefaultUserPassword] !=nil && ![[[AppDefaultUtil sharedInstance] getDefaultUserPassword] isEqualToString:@""] && [[AppDefaultUtil sharedInstance] getGesturesPasswordWithAccount:[[AppDefaultUtil sharedInstance] getDefaultUserName]] != nil && ![[[AppDefaultUtil sharedInstance] getGesturesPasswordWithAccount:[[AppDefaultUtil sharedInstance] getDefaultUserName]] isEqualToString:@""]) {
    //        // 有手势密码，而且记录了登陆账号与密码
    //
    //        //手势密码页面
    //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //        [UIApplication sharedApplication].statusBarHidden = NO;
    //        _openLockView = [[OpenLockViewController alloc] init];
    //        UINavigationController *openNav = [[UINavigationController alloc] initWithRootViewController:_openLockView];
    //        [self.window.rootViewController presentViewController:openNav animated:YES completion:nil];
    //
    //
    //    } else {
    //        // 其他情况直接算未登陆，直接跳转到主界面
    //
    //    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // 用户退出活动状态时，添加手势界面。
    if ([[AppDefaultUtil sharedInstance] getDefaultAccount] !=nil && ![[[AppDefaultUtil sharedInstance] getDefaultAccount] isEqualToString:@""] && [[AppDefaultUtil sharedInstance] getDefaultUserPassword] !=nil && ![[[AppDefaultUtil sharedInstance] getDefaultUserPassword] isEqualToString:@""] && [[AppDefaultUtil sharedInstance] getGesturesPasswordWithAccount:[[AppDefaultUtil sharedInstance] getDefaultAccount]] != nil && ![[[AppDefaultUtil sharedInstance] getGesturesPasswordWithAccount:[[AppDefaultUtil sharedInstance] getDefaultAccount]] isEqualToString:@""]) {
        // 有手势密码，而且记录了登陆账号与密码
        
        //手势密码页面
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [UIApplication sharedApplication].statusBarHidden = NO;
        _openLockView = [[OpenLockViewController alloc] init];
        UINavigationController *openNav = [[UINavigationController alloc] initWithRootViewController:_openLockView];
        [self.window.rootViewController presentViewController:openNav animated:YES completion:nil];
        
        
    } else {
        // 其他情况直接算未登陆，直接跳转到主界面
        
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //
    //    self.appId = [BPush getAppId];
    //    self.userId = [BPush getUserId];
    //    self.channelId = [BPush getChannelId];
    //
    //    DLOG(@"相关ID2 是app  %@  user %@  channel %@",[BPush getAppId], [BPush getUserId],[BPush getChannelId]);
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Request 网络请求数据
#pragma 获取网络启动图片
- (void) requestData
{
    DLOG(@"获取网络图片");
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    // 获取网络启动图片（opt = 161）
    [parameters setObject:@"161" forKey:@"OPT"];
    [parameters setObject:@"" forKey:@"body"];
    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
        
    }
    [_requestClient requestGet:@"app/services" withParameters:parameters];
}


#pragma mark HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{
    DLOG(@"****************************1");
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    DLOG(@"****************************2 dics -> %@", obj);
    NSDictionary *dics = obj;
    if (dics.count == 0) {
        return;
    }
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        
        if (![[dics objectForKey:@"fileNames"] isEqual:[NSNull null]]&&[dics objectForKey:@"fileNames"]!= nil) {
            
            NSArray *fileNameArr = [dics objectForKey:@"fileNames"];
            
            if (fileNameArr.count)
            {
                NSString *imageUrl = nil;
                
                if ([[NSString stringWithFormat:@"%@",fileNameArr[0]] hasPrefix:@"http"]) {
                    
                    imageUrl = [NSString stringWithFormat:@"%@", fileNameArr[0]];
                    
                }else{
                    imageUrl = [NSString stringWithFormat:@"%@%@", Baseurl,fileNameArr[0]];
                }
                
                DLOG(@"imageUrl -> %@", imageUrl);
                
                [[AppDefaultUtil sharedInstance] setAppImage:imageUrl];
                
                [_adImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
                
            }
        }
        
    }else {
        
        DLOG(@"返回失败===========%@",[obj objectForKey:@"msg"]);
        
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
        
    }
    
}

// 返回失败
-(void) httpResponseFailure:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didFailWithError:(NSError *)error
{
    DLOG(@"****************************3");
}

// 无可用的网络
-(void) networkError
{
    DLOG(@"****************************4");
    
}

@end

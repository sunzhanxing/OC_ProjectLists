//
//  InfoNewsViewController.m
//  SP2P_7
//
//  Created by Jerry on 14-7-5.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import "InfoNewsViewController.h"
#include "ColorTools.h"

@interface InfoNewsViewController ()<UIWebViewDelegate,HTTPClientDelegate>

@property (nonatomic,strong)UIScrollView *ScrollView;
@property (nonatomic,strong)UIWebView *contentView;
@property (nonatomic,strong)NSString * timeStr;
@property (nonatomic,strong)NSString *authorStr;
@property (nonatomic,strong)NSString *contentStr;
@property (nonatomic,strong)UILabel *datelabel;
@property (nonatomic,strong)UILabel *countlabel;
@property (nonatomic,strong)UILabel *titlelabel;
@property(nonatomic ,strong) NetWorkClient *requestClient;

@end

@implementation InfoNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
     
    // 初始化视图
    [self initView];
    
    // 初始化数据
    [self initData];
}

/**
 * 初始化数据
 */
- (void)initData
{
  
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //财富资讯详情接口（opt=129）
    [parameters setObject:@"129" forKey:@"OPT"];
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:[NSString stringWithFormat:@"%@",_newsId] forKey:@"id"];
    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
        
    }
    [_requestClient requestGet:@"app/services" withParameters:parameters];
    
}

/**
 初始化数据
 */
- (void)initView
{
    
    [self initNavigationBar];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    _titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 68, self.view.frame.size.width-24, 25)];
    _titlelabel.numberOfLines = 1;
    _titlelabel.textAlignment = NSTextAlignmentCenter;
    _titlelabel.adjustsFontSizeToFitWidth = YES;
    _titlelabel.font = [UIFont boldSystemFontOfSize:13.5f];
    _titlelabel.text = _titleString;
    [backView addSubview:_titlelabel];
    
    _datelabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5-110, 90, 120, 20)];
    _datelabel.numberOfLines = 0;
    _datelabel.textColor = [UIColor lightGrayColor];
    _datelabel.font = [UIFont boldSystemFontOfSize:11.0f];
    [backView addSubview:_datelabel];
    
    _countlabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5+50, 90, 120, 20)];
   _countlabel.numberOfLines = 0;
    _countlabel.textColor = [UIColor lightGrayColor];
   _countlabel.font = [UIFont boldSystemFontOfSize:11.0f];
   [backView addSubview:_countlabel];
    

    _contentView = [[UIWebView alloc] initWithFrame:CGRectMake(3, 110, self.view.bounds.size.width-6, self.view.bounds.size.height-110)];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [_contentView setOpaque:YES];
    [_contentView.scrollView setScrollEnabled:YES];
    _contentView.scrollView.showsVerticalScrollIndicator = NO;
    _contentView.scalesPageToFit = YES;
    [_contentView setDelegate:self];
    //取消scrollerView的回弹效果
    for(id subview in _contentView.subviews){
        if([[subview class] isSubclassOfClass:[UIScrollView class]]){
            ((UIScrollView *)subview).bounces = NO;
        }
    }
    
    CGRect rect = _contentView.scrollView.frame;
    rect.size.height += 80;
    _contentView.scrollView.frame = rect;
    [self.view addSubview:_contentView];

}


/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    self.title = @"详情";
    [self.navigationController.navigationBar setBarTintColor:KColor];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Arial-BoldMT" size:18.0], NSFontAttributeName, nil]];
    
    
    // 导航条返回按钮
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"]  style:UIBarButtonItemStyleDone target:self action:@selector(backClick)];
    backItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
//    // 导航条分享按钮
//    UIBarButtonItem *ShareItem=[[UIBarButtonItem alloc]  initWithImage:[UIImage imageNamed:@"nav_share"] style:UIBarButtonItemStyleDone target:self action:@selector(ShareClick)];
//    ShareItem.tintColor = [UIColor whiteColor];
//    [self.navigationItem setRightBarButtonItem:ShareItem];
}



// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    
    DLOG(@"==返回成功=======%@",obj);
    NSDictionary *dics = obj;
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        
        _titlelabel.text = [dics objectForKey:@"title"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: [[[dics objectForKey:@"time"] objectForKey:@"time"] doubleValue]/1000];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        _datelabel.text = [dateFormat stringFromDate: date];
        
        _contentStr = [dics objectForKey:@"content"];
        _authorStr = [dics objectForKey:@"author"];
        _countlabel.text = [NSString stringWithFormat:@"作者:%@",_authorStr];
        
        if (![_contentStr isEqual:[NSNull null]]) {
            _contentStr = [_contentStr stringByReplacingOccurrencesOfString:@"alt=\"\" " withString:@""];
            
            _contentStr = [_contentStr stringByReplacingOccurrencesOfString:@"<img src=\"/" withString:[NSString stringWithFormat:@"<img src=\"%@/", Baseurl]]; //替换相对路径
            
//            _contentStr = [_contentStr stringByReplacingOccurrencesOfString:@"<img src=\"/" withString:[NSString stringWithFormat:@"<img style=\"width:%f\" src=\"%@/", self.view.frame.size.width - 20, Baseurl]]; //替换相对路径
            
            DLOG(@"width: %f", self.view.frame.size.width - 20);
            
            [_contentView loadHTMLString:_contentStr baseURL:nil];
        }
        
    }else if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-2"]) {
        
        [ReLogin outTheTimeRelogin:self];
    
    }else {
        
       DLOG(@"返回失败===========%@",[obj objectForKey:@"msg"]);
      [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
        
    }
}

// 返回失败
-(void) httpResponseFailure:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didFailWithError:(NSError *)error
{

  [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"失败：%ld", (long)[error code]]];
    
}



#pragma 返回按钮触发方法
- (void)backClick
{
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
    // DLOG(@"返回按钮");
    
    if ([_typeStr isEqualToString:@"推送"]) {
       
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        
    [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
}

#pragma  分享按钮
- (void)ShareClick
{
    if (AppDelegateInstance.userInfo == nil) {
        
          [ReLogin outTheTimeRelogin:self];        
    }else {
        DLOG(@"分享按钮");
        
//        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"];
        
        NSString *shareUrl = [NSString stringWithFormat:@"%@/front/wealthinfomation/newDetails?id=%@", Baseurl, _newsId];
        
        //构造分享内容
        id<ISSContent> publishContent = [ShareSDK content:@"SP2P7.2.2 善建网贷 财富资讯 详情"
                                           defaultContent:@"默认分享内容，没内容时显示"
                                                    image:[ShareSDK pngImageWithImage:[UIImage imageNamed:@"logo"]]
                                                    title:@"财富资讯"
                                                      url:shareUrl
                                              description:@"财富资讯详情"
                                                mediaType:SSPublishContentMediaTypeNews];
        
        [ShareSDK showShareActionSheet:nil
                             shareList:nil
                               content:publishContent
                         statusBarTips:YES
                           authOptions:nil
                          shareOptions: nil
                                result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                    if (state == SSResponseStateSuccess)
                                    {
                                        DLOG(@"分享成功");
                                    }
                                    else if (state == SSResponseStateFail)
                                    {
                                        DLOG(@"分享失败,错误码:%ld,错误描述:%@", [error errorCode], [error errorDescription]);
                                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]]];
                                    }
                                }];
    }
}


@end

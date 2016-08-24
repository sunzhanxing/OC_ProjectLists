//
//  GuideViewController.m
//  SP2P_6.1
//
//  Created by Jerry on 14-8-12.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
//引导页面

#import "GuideViewController.h"
#import "MainViewController.h"

#define count 4

@interface GuideViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIPageControl *control;
@property (nonatomic,strong) UIScrollView *scrollView;
@end

@implementation GuideViewController

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
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = self.view.bounds;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < count; i++) {
        NSString *imageName = [NSString  stringWithFormat:@"guide_page%d" ,i+1];
        UIImage *image = [UIImage imageNamed: imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(i*width, 0, width, height);
     
        [_scrollView addSubview:imageView];
        
        if (i == count-1) {
            
            UIButton *ClickBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*width, 0, width, height)];
            [ClickBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:ClickBtn];
    
        }
    }

    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(count * width, height);
    _scrollView.pagingEnabled = YES;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    
    _control = [[UIPageControl alloc] init];
    _control.numberOfPages = count;
    _control.bounds = CGRectMake(0, 0, 200, 50);
    _control.center = CGPointMake(width * 0.5, height - 50);
    _control.currentPage = 0;
    [_control addTarget:self action:@selector(onPointClick) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_control];
}

- (void) onPointClick
{
    DLOG(@"onPointClick");
    CGFloat offsetX = _control.currentPage * _scrollView.frame.size.width;
    
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(offsetX, 0);
    }];
}

- (void)btnClick
{
    // 第一次登陆应该直接进入主界面
    //主界面
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [UIApplication sharedApplication].statusBarHidden = NO;
    MainViewController *main = [[MainViewController alloc] rootViewController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:main];
    [navigationController setNavigationBarHidden:YES];
    
    // 通知全局广播 LeftMenuController 修改UI操作
//    [[NSNotificationCenter defaultCenter]  postNotificationName:@"update" object:nil];
    AppDelegateInstance.window.rootViewController = navigationController;
//
//    
//    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (scrollView == _scrollView)
    {
        int pageNum = scrollView.contentOffset.x / scrollView.frame.size.width;
        _control.currentPage = pageNum;
        
        DLOG(@"pageNum - > %d", pageNum);
        DLOG(@"scrollView.contentOffset.x - > %f", scrollView.contentOffset.x);
        
        if (scrollView.contentOffset.x > count * scrollView.frame.size.width) {
            [self performSelector:@selector(enterHome:) withObject:scrollView afterDelay:1.0];
        }
        
//        if (pageNum == 3)
//        {
//            [self performSelector:@selector(enterHome:) withObject:scrollView afterDelay:1.5];
//        }
        
    }
}

- (void) enterHome:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:1.0 animations:^(void) {
        
        scrollView.alpha = 0;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [UIApplication sharedApplication].statusBarHidden = NO;
        MainViewController *main = [[MainViewController alloc] rootViewController];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:main];
        [navigationController setNavigationBarHidden:YES];
        
        [self presentViewController:navigationController animated:YES completion:nil];
        
    } completion:^(BOOL finished){
        
        if (finished)
        {
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//            [UIApplication sharedApplication].statusBarHidden = NO;
//            MainViewController *main = [[MainViewController alloc] rootViewController];
//            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:main];
//            [navigationController setNavigationBarHidden:YES];
//            
//            [self presentViewController:navigationController animated:NO completion:nil];
            
            _control.hidden = YES;
            [scrollView removeFromSuperview];
            
        }
    }];
}

@end

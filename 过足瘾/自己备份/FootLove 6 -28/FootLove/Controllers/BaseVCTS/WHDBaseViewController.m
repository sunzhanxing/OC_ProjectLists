//
//  WHDBaseViewController.m
//  FootLove
//
//  Created by HUN on 16/6/27.
//  Copyright © 2016年 hundred Company. All rights reserved.
//

#import "WHDBaseViewController.h"

@interface WHDBaseViewController ()

@end

@implementation WHDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置背景指定的颜色
    [self.view setBackgroundColor:W_viewColor];
    [self _initIcon];//布置页面的按钮
}

-(void)_initIcon
{
    [self setLeftBtn:@"技师列表_侧边" andTitle:nil];
    self.leftBtnBlock=
    ^{
        
    };
    
    [self setRightBtn:@"技师列表_查询" andTitle:nil];
    self.rightBtnBlock=^{
        
    };
    
    
}

/** 设置左边的按钮 */
-(void)setLeftBtn:(NSString *)iconStr andTitle:(NSString *)titleStr
{
    UIButton *leftBtn=[[UIButton alloc]init];
    if (iconStr)
    {
        UIImage *imag = [UIImage imageNamed:iconStr];
        leftBtn.frame = CGRectMake(5, 0, imag.size.width+5, 44);
        [leftBtn setImage:imag forState:UIControlStateNormal];
    }else
    {
        CGSize fontSize = [titleStr sizeWithFont:W_font(13) constrainedToSize:(CGSize){MAXFLOAT,44}];
        leftBtn.frame = CGRectMake(5, 0, fontSize.width+5, 44);
        [leftBtn setTitle:titleStr forState:UIControlStateNormal];
    }
    [leftBtn addTarget:self action:@selector(leftWay:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftBtn];
}

/** 设置右边的按钮 */
-(void)setRightBtn:(NSString *)iconStr andTitle:(NSString *)titleStr
{
    UIButton *rightBtn=[[UIButton alloc]init];
    if (iconStr)
    {
        UIImage *imag = [UIImage imageNamed:iconStr];
        rightBtn.frame = CGRectMake(5, 0, imag.size.width+5, 44);
        [rightBtn setImage:imag forState:UIControlStateNormal];
    }else
    {
        CGSize fontSize = [titleStr sizeWithFont:W_font(13) constrainedToSize:(CGSize){MAXFLOAT,44}];
        rightBtn.frame = CGRectMake(5, 0, fontSize.width+5, 44);
        [rightBtn setTitle:titleStr forState:UIControlStateNormal];
    }
    [rightBtn addTarget:self action:@selector(rightWay:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
}

/** 设置顶部 */
-(void)setViewTitle:(NSString *)title
{
    UILabel *titleLB = [[UILabel  alloc]initWithFrame:(CGRect){0,0,200,44}];
    titleLB.text = title;
    titleLB.textAlignment = NSTextAlignmentCenter;
    titleLB.textColor = [UIColor whiteColor];
    titleLB.font=W_font(16);
    self.navigationItem.titleView = titleLB;
}


#pragma mark 方法实现
//左边方法实现
-(void)leftWay:(UIButton *)btn
{
    if (_leftBtnBlock) {
        _leftBtnBlock();
    }
}

-(void)rightWay:(UIButton *)btn
{
    if (_rightBtnBlock) {
        _rightBtnBlock();
    }
}


@end

//
//  LoginWindowTextField.m
//  SP2P_7
//
//  Created by kiu on 14-6-18.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import "LoginWindowTextField.h"

#import "ColorTools.h"


@implementation LoginWindowTextField
{
    AJComboBox *box;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UITextField *)textWithleftImage:(NSString *)leftIcon rightImage:(NSString *)rightIcon placeName:(NSString *)pName
{
    UIButton *signBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn.frame = self.bounds;
    signBtn.backgroundColor = [UIColor whiteColor];
    [signBtn.layer setMasksToBounds:YES];
    [signBtn.layer setCornerRadius:4.0]; //设置矩形四个圆角半径
    [signBtn.layer setBorderWidth:1.0];   //边框宽度
    [signBtn.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    signBtn.userInteractionEnabled = false;
    [self addSubview:signBtn];
    
//    _loginView = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, 280, 30)];
//    self.backgroundColor = [UIColor whiteColor];
    self.textColor = [UIColor blackColor];
    self.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0];
    self.placeholder = pName;
    
    _leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 28)];
    _leftImage.image = [UIImage imageNamed:leftIcon];
    _leftImage.contentMode = UIViewContentModeScaleAspectFit;

    _rightImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 28)];
    [_rightImage setImage:[UIImage imageNamed:rightIcon] forState:UIControlStateNormal];
    _rightImage.contentMode = UIViewContentModeScaleAspectFit;
    [_rightImage addTarget:self action:@selector(shiftAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.leftView = _leftImage;
    self.rightView = _rightImage;
    self.leftViewMode = self.rightViewMode = UITextFieldViewModeAlways;
    
    return self;
}
- (void)shiftAction
{
    if(box)
        [box removeFromSuperview];
    
    box=[[AJComboBox alloc] initWithFrame:CGRectMake(self.frame.origin.x,CGRectGetMinY(self.frame), self.frame.size.width, self.frame.size.height)];
    box.delegate=self;
    [box setArrayDatas:_userLists];
    [self addSubview:box];
    
}
#pragma AJComboBoxDelegate
- (void)didChangeComboBoxValue:(AJComboBox *)comboBox selectedIndex:(NSInteger)selectedIndex
{
    
    if(self.loginWindowDelegate && [self.loginWindowDelegate respondsToSelector:@selector(shiftAccount:)])
    {
        NSString *userName=[self.userLists objectAtIndex:selectedIndex];
        
        [self.loginWindowDelegate shiftAccount:userName];
    }
    
}
@end

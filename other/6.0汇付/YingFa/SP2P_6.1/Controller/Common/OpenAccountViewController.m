//
//  OpenAccountViewController.m
//  SP2P_6.1
//
//  Created by Cindy on 15-3-3.
//  Copyright (c) 2015年 EIMS. All rights reserved.
//
//开户前信息填写

#import "OpenAccountViewController.h"
#import "MyWebViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorTools.h"
#import "AccountInfoComboBox.h"

#import "AccountInfo.h"
#import "ActivationViewController.h"
#import "NSString+UserInfo.h"

#import "AccountItem.h"
#import "MSKeyboardScrollView.h"
#import "MyWebViewController.h"

#define fontsize 14.0f

#define TAG_NAME 30 //名字
#define TAG_IDCARD 32 // 身份证
#define TAG_PHONE1 33 // 手机号码1
#define TAG_NUMBER1 34 // 验证码1
#define TAG_EMAIL 37 // 验证码2

#define INT_TO_STRING(x)  [NSString stringWithFormat:@"%d", x]

@interface OpenAccountViewController ()<UITextFieldDelegate,UIScrollViewDelegate, HTTPClientDelegate>
{
    NSArray *_titleArr;
    
    NSInteger _requestType;// 0代表请求基本资料，1代表提交修改资料，2代表获取验证码
}

@property (nonatomic,strong)UITextField *nameField;
@property (nonatomic,strong)UITextField *PhoneField1;
@property (nonatomic,strong)UITextField *numField1;
@property (nonatomic,strong)UITextField *cardField;
@property (nonatomic,strong)UITextField *mailField;
@property (nonatomic,strong)UIButton *verifyBtn1;
@property (nonatomic,strong)UIButton *saveBtn;
@property (nonatomic,strong)UIScrollView *ScrollView;
@property (nonatomic,strong)UIView *backView;


@property (nonatomic,strong) AccountInfo *accountInfo;
@property (nonatomic,strong) NetWorkClient *requestClient;

@end

@implementation OpenAccountViewController

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
    // 初始化数据
    [self initData];
    
    // 初始化视图
    [self initView];
    
    _requestType = 0;
    [self requestData];
    
}

/**
 * 初始化数据
 */
- (void)initData
{
    _accountInfo =  [[AccountInfo alloc] init];
    
    _titleArr = @[@"真实姓名", @"身份证号码" ,@"邮箱",@"手机",@"验证码"];//,@"验证码"
}

/**
 初始化数据
 */
- (void)initView
{
    
    [self initNavigationBar];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //滚动视图
    _ScrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _ScrollView.userInteractionEnabled = YES;
    _ScrollView.scrollEnabled = YES;
    _ScrollView.showsHorizontalScrollIndicator =NO;
    _ScrollView.showsVerticalScrollIndicator = NO;
    _ScrollView.delegate = self;
    _ScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_ScrollView];
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _backView.backgroundColor = [UIColor whiteColor];
    [_ScrollView addSubview:_backView];
    
    UIControl *viewControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [viewControl addTarget:self action:@selector(controlAction) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:viewControl];
    
    //标题文本
    for (int i=0; i<_titleArr.count; i++) {
        UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 16 + i * 40, 70, 30)];
        titlelabel.textAlignment = NSTextAlignmentRight;
        titlelabel.font = [UIFont systemFontOfSize:fontsize];
        titlelabel.text = [_titleArr objectAtIndex:i];
        titlelabel.tag = i + 10;// 标记
        [_backView addSubview:titlelabel];
        
        // 添加*号
        UILabel *markLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 18 + i* 40, 10, 30)];
        markLabel.textAlignment = NSTextAlignmentCenter;
        markLabel.font = [UIFont systemFontOfSize:fontsize];
        markLabel.text = @"*";
        markLabel.tag = i + 100;// 标记
        markLabel.textColor = PinkColor;
        [_backView addSubview:markLabel];
        
    }
    
    //名字输入框
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self.view viewWithTag:(0+100)].frame) + 4, CGRectGetMidY([self.view viewWithTag:(0+10)].frame)-13, 150, 26)];
    _nameField.borderStyle = UITextBorderStyleRoundedRect;
    _nameField.delegate = self;
    _nameField.font = [UIFont systemFontOfSize:fontsize];
    _nameField.placeholder = @"请输入真实名字";
    _nameField.tag = TAG_NAME;
    _nameField.keyboardType = UIKeyboardTypeDefault;
    _nameField.returnKeyType = UIReturnKeyNext;
    [_backView addSubview:_nameField];
    
    //身份证输入框
    _cardField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self.view viewWithTag:(1+100)].frame) + 4, CGRectGetMidY([self.view viewWithTag:(1+10)].frame) - 13, 180, 26)];
    _cardField.borderStyle = UITextBorderStyleRoundedRect;
    _cardField.delegate = self;
    _cardField.font = [UIFont systemFontOfSize:fontsize];
    _cardField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _cardField.returnKeyType = UIReturnKeyNext;
    _cardField.tag = TAG_IDCARD;
    _cardField.placeholder = @"请输入身份证号码";
    [_backView addSubview:_cardField];

    
    //邮箱输入框
    _mailField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self.view viewWithTag:(2+100)].frame) + 4, CGRectGetMidY([self.view viewWithTag:(2+10)].frame) - 13, 180, 26)];
    _mailField.borderStyle = UITextBorderStyleRoundedRect;
    _mailField.delegate = self;
    _mailField.keyboardType = UIKeyboardTypeEmailAddress;
    _mailField.returnKeyType = UIReturnKeyNext;
    _mailField.tag = TAG_EMAIL;
    _mailField.font = [UIFont systemFontOfSize:fontsize];
    _mailField.placeholder = @"请输入邮箱";
    [_backView addSubview:_mailField];
    
    
    //手机号码1输入框
    _PhoneField1 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self.view viewWithTag:(3 + 100)].frame) + 4, CGRectGetMidY([self.view viewWithTag:(3 + 10)].frame) - 13, 130, 26)];
    _PhoneField1.borderStyle = UITextBorderStyleRoundedRect;
    _PhoneField1.delegate = self;
    _PhoneField1.font = [UIFont systemFontOfSize:fontsize];
    _PhoneField1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _PhoneField1.returnKeyType = UIReturnKeyDone;
    _PhoneField1.placeholder = @"请输入手机号码";
    _PhoneField1.tag = TAG_PHONE1;
    [_backView addSubview:_PhoneField1];
    
    //验证码1输入框
    _numField1 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self.view viewWithTag:(4 + 10)].frame) + 19, CGRectGetMidY([self.view viewWithTag:(4 + 10)].frame) - 13, 130, 26)];
    _numField1.borderStyle = UITextBorderStyleRoundedRect;
    _numField1.delegate = self;
    _numField1.font = [UIFont systemFontOfSize:fontsize];
    _numField1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _numField1.returnKeyType = UIReturnKeyDone;
    _numField1.tag = TAG_NUMBER1;
    _numField1.placeholder = @"请输入验证码";
    [_backView addSubview:_numField1];
    
    
    //验证码按钮
    _verifyBtn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_verifyBtn1 setFrame:CGRectMake(CGRectGetMaxX(_numField1.frame) + 12, CGRectGetMidY(_numField1.frame) - 13, 60, 26)];
    [_verifyBtn1 setTitle:@"点击获取" forState:UIControlStateNormal];
    [_verifyBtn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _verifyBtn1.layer.cornerRadius = 4.0f;
    _verifyBtn1.layer.masksToBounds = YES;
    _verifyBtn1.backgroundColor  = KblackgroundColor;
    _verifyBtn1.titleLabel.textColor = [UIColor grayColor];
    _verifyBtn1.titleLabel.font = [UIFont systemFontOfSize:fontsize];
    [_verifyBtn1 setTag:1001];
    [_verifyBtn1 addTarget:self action:@selector(verifyClick:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:_verifyBtn1];
    
    
    //保存按钮
    _saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_saveBtn setFrame:CGRectMake(self.view.frame.size.width*0.5-60, CGRectGetMaxY(_numField1.frame) + 20, 120, 30)];
    [_saveBtn setTitle:@"开通个人账户" forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _saveBtn.layer.cornerRadius= 4.0f;
    _saveBtn.layer.masksToBounds = YES;
    _saveBtn.backgroundColor = GreenColor;
    _saveBtn.titleLabel.textColor = [UIColor whiteColor];
    _saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [_saveBtn setTag:1003];
    [_saveBtn addTarget:self action:@selector(verifyClick:) forControlEvents:UIControlEventTouchUpInside];
    [_ScrollView addSubview:_saveBtn];
    
    _ScrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(_saveBtn.frame) + 280);
    
}

-(void) setValue
{
    [self setEnable:!_accountInfo.isAddBaseInfo];
    
    if (_accountInfo.realName != nil && ![_accountInfo.realName isEqual:[NSNull null]]) {
        _nameField.text = _accountInfo.realName;
    }
    
    if (_accountInfo.cellPhone1 != nil && ![_accountInfo.cellPhone1 isEqual:[NSNull null]]) {
        _PhoneField1.text = _accountInfo.cellPhone1;
    }
    
    if (_accountInfo.email != nil && ![_accountInfo.email isEqual:[NSNull null]]) {
        _mailField.text = _accountInfo.email;
    }
    
    if (_accountInfo.idNo != nil && ![_accountInfo.idNo isEqual:[NSNull null]]) {
        _cardField.text = _accountInfo.idNo;
    }
    
}

-(void) setEnable:(BOOL) isEnable
{
    _nameField.enabled = isEnable;
    _PhoneField1.enabled = isEnable;
    _numField1.enabled = isEnable;
  //  _mailField.enabled = isEnable;
    _cardField.enabled = isEnable;
    _verifyBtn1.enabled = isEnable;
    _verifyBtn1.hidden = !isEnable;
    _saveBtn.enabled = isEnable;
    _saveBtn.hidden = !isEnable;
}


/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    self.title = @"开通个人托管账户";
    [self.navigationController.navigationBar setBarTintColor:KColor];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Arial-BoldMT" size:18.0], NSFontAttributeName, nil]];
    
    // 导航条返回按钮
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backClick)];
    backItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
}

#pragma mark 验证码按钮触发方法
- (void)verifyClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 1001:
            _requestType = 2;
            [self getVerification:btn];
            
            break;
        case 1003:
            _requestType = 1;
            [self submitAccountInfo];
            break;
    }
}

#pragma mark 点击空白处收回键盘
- (void)controlAction
{
    
    for (UITextField *textField in [_backView  subviews])
    {
        if ([textField isKindOfClass: [UITextField class]]) {
            
            [textField  resignFirstResponder];
        }
        
    }
    
}


#pragma UITextFieldDelegate
// 当用户按下return键或者按回车键
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case TAG_NAME:
            [_cardField becomeFirstResponder];
            break;
        case TAG_IDCARD:
        {
            if (_mailField.text.length == 0)
            {
                [_mailField becomeFirstResponder];
                
            }else{
                [_PhoneField1 becomeFirstResponder];
            }
        }
            break;
        case TAG_EMAIL:
            [_PhoneField1 becomeFirstResponder];
            break;
        case TAG_PHONE1:
            [_PhoneField1 resignFirstResponder];
            break;
        default:
            break;
    }
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > -55)
        self.view.frame = CGRectMake(0.0f, offset-50, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

#pragma mark - 返回按钮触发方法
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - 开始进入刷新状态
- (void)headerRereshing
{
    [self requestData];
}

#pragma mark - 请求数据
-(void) requestData
{
    if (AppDelegateInstance.userInfo == nil) {
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"164" forKey:@"OPT"];//可能要改，查询开户信息接口172
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"userId"];//userId
    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
    }
    [_requestClient requestGet:@"app/services" withParameters:parameters];
    
}

#pragma HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{
    
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    NSDictionary *dics = obj;
    DLOG(@"开户返回===%@=======", dics);

    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        DLOG(@"msg  -> %@", [obj objectForKey:@"msg"]);
        if (_requestType == 0) {
            
            if (![[dics objectForKey:@"realName"]isEqual:[NSNull null]])
            {
                _accountInfo.realName = [NSString stringWithFormat:@"%@",[dics objectForKey:@"realName"]];
            }
            
            if (![[dics objectForKey:@"idNo"]isEqual:[NSNull null]])
            {
                _accountInfo.idNo = [dics objectForKey:@"idNo"];
            }
            if (![[dics objectForKey:@"cellPhone1"]isEqual:[NSNull null]])
            {
                _accountInfo.cellPhone1 = [dics objectForKey:@"cellPhone1"];
            }
            
            if (![[dics objectForKey:@"email"]isEqual:[NSNull null]])
            {
                _accountInfo.email = [dics objectForKey:@"email"];
            }
            
        
            if(_accountInfo.email.length > 0)
            {
                [_mailField setEnabled:NO];
            }
            
            [self setValue];
            
        }else if(_requestType == 1){
            
            [self setEnable:NO];
            
            NSString *htmlParam = [NSString stringWithFormat:@"%@",[obj objectForKey:@"htmlParam"]];
            MyWebViewController *web = [[MyWebViewController alloc]init];
            web.html = htmlParam;
            web.type = @"1";
            [self.navigationController pushViewController:web animated:YES];
            
            
        }else if(_requestType == 2)
        {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
        }
        
    }else if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-2"]) {
        
        NSString *msg = [NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]];
        
        if ([msg rangeOfString:@"邮箱未激活"].location != NSNotFound)
        {
            ActivationViewController *activatView = [[ActivationViewController alloc] init];
            [self.navigationController pushViewController:activatView animated:YES];
            
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
        }
    }
    else {
        // 服务器返回数据异常
        if (!dics) {
            ;
        }
        else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
        }
    }
    
}

// 返回失败
-(void) httpResponseFailure:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didFailWithError:(NSError *)error
{
    // 服务器返回数据异常
    //    [SVProgressHUD showErrorWithStatus:@"网络异常"];
}

// 无可用的网络
-(void) networkError
{
    // 服务器返回数据异常
    [SVProgressHUD showErrorWithStatus:@"无可用网络"];
}

-(void) submitAccountInfo
{
    if (AppDelegateInstance.userInfo == nil) {
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        return;
    }
    
    if ([_nameField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写真实姓名"];
        return;
    }
    
    if ([_cardField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写身份证"];
        return;
    }
    
    if (![NSString validateIdCard:_cardField.text]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的身份证"];
        return;
    }
      
    if ([_PhoneField1.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写电话号码"];
        return;
    }
    
    if (![NSString validateMobile:_PhoneField1.text]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    
//    if ([_numField1.text isEqualToString:@""]) {
//        [SVProgressHUD showErrorWithStatus:@"请填写收到的验证码"];
//        return;
//    }
    
    if (![_mailField.text isEqualToString:@""]) {
        if (![NSString validateEmail:_mailField.text]) {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的邮箱"];
            return;
        }
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"171" forKey:@"OPT"];
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"userId"];//userId
    [parameters setObject:_nameField.text forKey:@"realName"];
    [parameters setObject:_cardField.text forKey:@"idNo"];
    [parameters setObject:_PhoneField1.text forKey:@"cellPhone1"];
    [parameters setObject:_numField1.text forKey:@"randomCode1"];
    [parameters setObject:_mailField.text forKey:@"email"];
    
    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
    }
    
    [_requestClient requestGet:@"app/services" withParameters:parameters];
    
}

//  获取验证码
-(void) getVerification:(UIButton *)sender
{
    if (AppDelegateInstance.userInfo == nil) {
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        return;
    }
    
    if ([_PhoneField1.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号码"];
        return;
    }
    
    __block int timeout = 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                [_verifyBtn1 setTitle:@"点击获取" forState:UIControlStateNormal];
                _verifyBtn1.userInteractionEnabled = YES;
                [_verifyBtn1 setAlpha:1];
                
            });
        }else{
            int seconds = timeout % 61;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                NSLog(@"____%@",strTime);
                
                [_verifyBtn1 setTitle:[NSString stringWithFormat:@"稍后(%@s)",strTime] forState:UIControlStateNormal];
                _verifyBtn1.userInteractionEnabled = NO;
                [_verifyBtn1 setAlpha:0.4];
                
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"4" forKey:@"OPT"];
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:_PhoneField1.text forKey:@"cellPhone"];

    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
    }
    
    [_requestClient requestGet:@"app/services" withParameters:parameters];
    
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
}

@end

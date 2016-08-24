//
//  LeftMenuViewController.m
//  SP2P_6.1
//
//  Created by 李小斌 on 14-6-6.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import "LeftMenuViewController.h"

#import "MenuToolItemView.h"
#import "MenuToolItem.h"
#import "ColorTools.h"

// kiu
#import "MoreViewController.h"
#import "CalculatorViewController.h"

#import "LoginViewController.h"
#import "TwoCodeViewController.h"
#import "ChangeIconViewController.h"

#include "AccountCenterOrderViewController.h"
#import "SendValuedelegate.h"
#import "AccountCenterOrder.h"
#import "FMDB.h"

//各个账户中心子视图控制器
#import "BorrowingBillViewController.h"
#import "AuditingViewController.h"
#import "TenderViewController.h"
#import "PaymentViewController.h"
#import "SuccessfullyViewController.h"
#import "LiteratureAuditMainViewController.h"
#import "FinancialBillsViewController.h"
#import "BidRecordsViewController.h"
#import "FullScaleViewController.h"
#import "CollectionViewController.h"
#import "CompletedViewController.h"
#import "DebtManagementViewController.h"
#import "FinancialStatisticsViewController.h"
#import "TenderRobotViewController.h"
#import "AccountInfoViewController.h"
#import "FundRecordViewController.h"
#import "RechargeViewController.h"
#import "MyRechargeViewController.h"
#import "WithdrawalViewController.h"
#import "BankCardManageViewController.h"
#import "AccuontSafeViewController.h"
#import "MobilePassWordViewController.h"
#import "CreditLevelViewController.h"
#import "MyCollectionViewController.h"
#import "AttentionUserViewController.h"
#import "BlackListViewController.h"
//特别活动
#import "SpecialEventsViewController.h"

#import "UserInfo.h"
#import "Macros.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "JoinVipViewController.h"

@interface LeftMenuViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, SendValuedelegate, HTTPClientDelegate>
{
    NSMutableArray *_collectionArrays;
    AccountCenterOrderViewController *AccountCenterOrderView;
    UINavigationController *NavigationController;
    UINavigationController *NavigationController1;
    NSArray *IconDataArr;
    NSMutableArray *menuArr;
    
    BOOL isLogin;
    
    FMDatabase *db;             //数据库
    NSString *IDstr;  //ID
    NSMutableArray *OrderArr;
    MenuToolItem *bean;
    UIButton *collectionBtn1;
    
    NSInteger type;
    
}

@property (nonatomic, strong) UIImageView *sideBarImageView;
// 信用等级
@property (nonatomic, strong) UIImageView *levelImage;
@property (nonatomic, strong) UIButton *creditRatingBtn;    // 信用额度 img
// VIP
@property (nonatomic, strong) UIButton *vipBtn;
@property (nonatomic, strong) UIButton *code;

@property (nonatomic, strong) UIButton *info;
@property (nonatomic, strong) UIButton *calculator;
@property (nonatomic, strong) UIButton *refreshBtn;    // 刷新

@property (nonatomic, strong) UIButton *loginView;
@property (nonatomic, strong) UILabel *loginUser;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UILabel *amount;

@property (nonatomic, strong) UILabel *accountAmountLabel;
@property (nonatomic, strong) UILabel *availableBalanceLabel;
@property (nonatomic, strong) UILabel *accountAmountValue;          // 账户总额
@property (nonatomic, strong) UILabel *availableBalanceValue;       // 可用余额
@property (nonatomic, strong) UIButton *rechargeBtn;                // 充值
@property (nonatomic, strong) UIButton *withdrawBtn;                // 提现

@property(nonatomic ,strong) NetWorkClient *requestClient;

@end

@implementation LeftMenuViewController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    //通知检测对象
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(update) name:@"update" object:nil];
    
    [self initData];//初始化数据
    
    [self initView];//初始化视图
    
    [self readdata];//读取数据库
    
    if (AppDelegateInstance.userInfo != nil) {
        [self update];
    }
    
    type = 1;
    
    //[self initinfo];
    
    
    if ([AppDelegateInstance.openType isEqualToString:@"1"]) {
        [self initinfo];
        [AppDelegateInstance setOpenType:@"2"];
    }else{
        
        IDstr = @"123";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"UserSetData.db"];
        db= [FMDatabase databaseWithPath:dbPath] ;
        DLOG(@"dapath is %@",dbPath);
        if (![db open]) {
            DLOG(@"数据库无法打开");
            return ;
        }
        //创建表
        if(![db tableExists:@"UserSet"])
        {
            [db executeUpdate:@"CREATE TABLE  UserSet (Id text, Tag integer, Checked integer)"];
            DLOG(@"表创建完成");
        }
        
        
        //读取数据库数据
        [self readdata];
    }

    
}


/**
 * 初始化数据
 */
- (void)initData
{
    
    isLogin = NO;
    
    IconDataArr = [[NSArray alloc] init];
    OrderArr = [[NSMutableArray alloc] init];
    menuArr = [[NSMutableArray alloc] init];
    DLOG(@"IcondataArr is %@",IconDataArr);
    
    //左视图添加按钮
    _collectionArrays =[[NSMutableArray alloc] init];
    bean = [[MenuToolItem alloc] init];
    bean.name = @"";
    bean.icon = @"menu_collection_add";
    bean.Tag = 301;
    [_collectionArrays addObject:bean];
    
    
    
    

}


-(void)initinfo
{
    
    IDstr = @"123";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"UserSetData.db"];
    db= [FMDatabase databaseWithPath:dbPath] ;
    DLOG(@"dapath is %@",dbPath);
    if (![db open]) {
        DLOG(@"数据库无法打开");
        return ;
    }
    //创建表
    if(![db tableExists:@"UserSet"])
    {
        [db executeUpdate:@"CREATE TABLE  UserSet (Id text, Tag integer, Checked integer)"];
        DLOG(@"表创建完成");
    }
    
    
    [db executeUpdate:@"INSERT INTO UserSet (Id,Tag,Checked) VALUES (?,?,?)",IDstr,[NSNumber numberWithInt:201],[NSNumber numberWithInt:1]];
    [db executeUpdate:@"INSERT INTO UserSet (Id,Tag,Checked) VALUES (?,?,?)",IDstr,[NSNumber numberWithInt:102],[NSNumber numberWithInt:1]];
    
    [db executeUpdate:@"INSERT INTO UserSet (Id,Tag,Checked) VALUES (?,?,?)",IDstr,[NSNumber numberWithInt:3],[NSNumber numberWithInt:1]];
    
    
    
    
    
    
    //读取数据库数据
    [self readdata];

}

/**
 读取数据库数据数据
 */
- (void)readdata
{
    
//    IDstr = @"123";
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"UserSetData.db"];
//    db= [FMDatabase databaseWithPath:dbPath];
//    DLOG(@"dapath is %@",dbPath);
//    if (![db open]) {
//        DLOG(@"数据库无法打开");
//        return ;
//    }
    
    
   
    
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", @"UserSet"];
    while ([rs next])
    {
        
        NSInteger count = [rs intForColumn:@"count"];
        DLOG(@"isTableOK %ld", (long)count);
        
        if (0 == count)
        {
            
            DLOG(@"数据库中不存在表");
            
        }else {
    
            //返回全部查询结果
            FMResultSet *rs=[db executeQuery:@"SELECT * FROM UserSet WHERE Id = ?",IDstr];
            [OrderArr  removeAllObjects];
            while ([rs next])
            {
                DLOG(@"ID  %@ ********  标签  %@ *******  选中%@",[rs stringForColumn:@"Id"],[rs stringForColumn:@"Tag"],[rs stringForColumn:@"checked"]);
                AccountCenterOrder *orderModel = [[AccountCenterOrder alloc] init];
                orderModel.Id = [[rs stringForColumn:@"Id"] integerValue];
                orderModel.Tag = [[rs stringForColumn:@"Tag"] integerValue];
                orderModel.Checked = [[rs stringForColumn:@"checked"] integerValue];
                [OrderArr addObject:orderModel];
            }
            
            [rs close];
            //DLOG(@"orderArr is %@",OrderArr);
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"menu_collection_list" withExtension:@"plist"];
            NSArray *collections = [NSArray arrayWithContentsOfURL:url];
            for (int i = 0; i<[OrderArr count]; i++)
            {
                
                for (NSDictionary *item in collections)
                {
                    AccountCenterOrder *model = [OrderArr objectAtIndex:i];
                    if (model.Tag == [[item objectForKey:@"Tag"] integerValue])
                    {
                       // DLOG(@"model.tag is %d",model.Tag);
                        MenuToolItem *bean1 = [[MenuToolItem alloc] init];
                        bean1.name = [item objectForKey:@"name"];
                        bean1.icon = [item objectForKey:@"icon"];
                        bean1.Tag = [[item objectForKey:@"Tag"] intValue];
                        DLOG(@"bean.name and bean.icon is %@%@-----%d",bean1.name,bean1.icon,bean1.Tag);
                        [_collectionArrays insertObject:bean1 atIndex:0];
                        
                    }
                    
                }
                
            }
            [_collectionView reloadData];

        }
    }
}



/**
 初始化视图
 */
- (void)initView
{
    
    _sideBarImageView =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _sideBarImageView.image = [UIImage imageNamed:@"sidebar_bg"];
    _code =  [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 40, 40)];
    [_code setImage:[UIImage imageNamed:@"menu_promotion"] forState:UIControlStateNormal];
    [_code addTarget:self action:@selector(codeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sideBarImageView];
    [self.view addSubview:_code];
    
    // logo图片
    _loginView = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginView.frame = CGRectMake(self.view.frame.size.width*0.5 - 24 - 24, 55, 60, 60);
    [_loginView.layer setMasksToBounds:YES];
    [_loginView.layer setCornerRadius:30.0]; //设置矩形四个圆角半径
    [_loginView addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [_loginView setBackgroundImage:[UIImage imageNamed:@"default_head"] forState:UIControlStateNormal];
    [_loginView setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.view addSubview:_loginView];// 登陆头像
    
    _loginUser =  [[UILabel alloc] initWithFrame:CGRectZero];
    _loginUser.textColor = [UIColor whiteColor];
    _loginUser.textAlignment = NSTextAlignmentCenter;
    _loginUser.text = NSLocalizedString(@"Login_No", nil);
    _loginUser.font = [UIFont fontWithName:@"Arial" size:13.0];
    [self.view addSubview:_loginUser];//  请登录
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    UIFont *font = [UIFont fontWithName:@"Arial" size:13];
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize _label1Sz = [_loginUser.text boundingRectWithSize:CGSizeMake(999, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;

    _loginUser.frame = CGRectMake(self.view.frame.size.width*0.5 - (_label1Sz.width + 38)*0.5, 117, _label1Sz.width, 20);
    
    _vipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _vipBtn.frame = CGRectMake(_loginUser.frame.origin.x + _loginUser.frame.size.width + 10 , 117, 20, 20);
    [_vipBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_vipBtn addTarget:self action:@selector(vipClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_vipBtn];
    
    [self addListView];
    [self addCollectionView];
    
    _info =  [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 37, 24, 24)];
    [_info setImage:[UIImage imageNamed:@"account_more"] forState:UIControlStateNormal];
    [_info addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_info];// 关于
    
    _calculator =  [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 37, 24, 24)];
    [_calculator setImage:[UIImage imageNamed:@"menu_calculator2"] forState:UIControlStateNormal];
    [_calculator addTarget:self action:@selector(calculator:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_calculator];// 计算器
    
    _refreshBtn =  [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, 32, 26, 26)];
    [_refreshBtn setImage:nil forState:UIControlStateNormal];
    [_refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_refreshBtn]; // 刷新
}

- (void) addListView
{
    _accountAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -24 - 100, 150, 40, 20)];
    _accountAmountLabel.textColor = [UIColor whiteColor];
    _accountAmountLabel.text = @"";
    _accountAmountLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:_accountAmountLabel];

    // 账户总额
    _accountAmountValue = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_accountAmountLabel.frame)-3, 150, 120, 20)];
    _accountAmountValue.textColor = PinkColor;
    _accountAmountValue.text = @"";
    _accountAmountValue.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:_accountAmountValue];
    
    _availableBalanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 - 24-100, 175, 40, 20)];
    _availableBalanceLabel.textColor = [UIColor whiteColor];
    _availableBalanceLabel.text = @"";
    _availableBalanceLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:_availableBalanceLabel];
    
    // 可用余额
    _availableBalanceValue = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_availableBalanceLabel.frame)-3, 175, 130, 20)];
    _availableBalanceValue.textColor = PinkColor;
    _availableBalanceValue.text = @"";
    _availableBalanceValue.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:_availableBalanceValue];
    
    // 充值
    _rechargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rechargeBtn.frame = CGRectMake(self.view.frame.size.width * 0.5 + 30 , 148, 20, 20);
    [_rechargeBtn setBackgroundImage:[UIImage imageNamed:@"recharge"] forState:UIControlStateNormal];   // 充值
    [_rechargeBtn addTarget:self action:@selector(rechargeClick) forControlEvents:UIControlEventTouchUpInside];
    _rechargeBtn.hidden = YES;
    [self.view addSubview:_rechargeBtn];
    
    // 提现
    _withdrawBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _withdrawBtn.frame = CGRectMake(self.view.frame.size.width * 0.5 + 55 , 148, 20, 20);
    [_withdrawBtn setBackgroundImage:[UIImage imageNamed:@"withdraw"] forState:UIControlStateNormal];   // 提现
    [_withdrawBtn addTarget:self action:@selector(withdrawClick) forControlEvents:UIControlEventTouchUpInside];
     _withdrawBtn.hidden = YES;
    [self.view addSubview:_withdrawBtn];
    
    UILabel *level =  [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -24 - 100, 206, 100, 20)];
    level.textColor = [UIColor whiteColor];
    level.text = @"信用等级";
    level.font = [UIFont boldSystemFontOfSize:15.0f];
    [self.view addSubview:level];
    
    _levelImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _levelImage.contentMode = UIViewContentModeScaleAspectFill;
    _levelImage.frame = CGRectMake(level.frame.origin.x + 80, 206, 20, 20);
    [self.view addSubview:_levelImage];
    
    UIView *line1 =  [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -24 - 100, 198, 200, 0.3)];
    line1.backgroundColor = [UIColor grayColor];
    UIView *line2 =  [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -24 - 100, 234, 200, 0.3)];
    line2.backgroundColor = [UIColor grayColor];
    UIView *line3 =  [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -24 - 100, 270, 200, 0.5)];
    line3.backgroundColor = [UIColor grayColor];
//    UIView *line4 =  [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -24 - 100, 296, 200, 0.3)];
//    line4.backgroundColor = [UIColor grayColor];

    [self.view addSubview:line1];
    [self.view addSubview:line2];
    [self.view addSubview:line3];
//    [self.view addSubview:line4];
    
    _amount =  [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -24 - 100, 242, 100, 20)];
    _amount.textColor = [UIColor whiteColor];
    _amount.font = [UIFont boldSystemFontOfSize:15.0f];
    _amount.text = @"信用额度";
    [self.view addSubview:_amount];
    
    _amountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _amountLabel.text = @"";
    _amountLabel.textColor = PinkColor;
    _amountLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:_amountLabel];
    
    _creditRatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _creditRatingBtn.frame = CGRectZero;
    [_creditRatingBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_creditRatingBtn addTarget:self action:@selector(creditRatingClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_creditRatingBtn];
    
    /* UILabel *activity =  [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -24 - 100, 273, 180, 20)];
    activity.textColor = [UIColor whiteColor];
    activity.text = @"活动";
    activity.font = [UIFont boldSystemFontOfSize:16.0f];
    [self.view addSubview:activity];
    
    
   UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -50, 275, 70, 15)];
    label.backgroundColor = [UIColor clearColor];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"资讯公告"]];
    NSRange contentRange = {0,[content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    label.textColor = [UIColor orangeColor];
    label.font = [UIFont boldSystemFontOfSize:14.0f];
    label.attributedText = content;
    [self.view addSubview:label];
    
    UIButton *awardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    awardBtn.frame = CGRectMake(self.view.frame.size.width*0.5 -50, 275, 70, 15);
    awardBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [awardBtn addTarget:self action:@selector(awatdBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:awardBtn];
    
    UIImageView *arrowsImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5+55, 273, 18, 18)];
    [arrowsImg setImage:[UIImage imageNamed:@"cell_more_btn"]];
    [self.view addSubview:arrowsImg];
    */
}

-(void) addCollectionView
{
    UICollectionViewFlowLayout *flowLayOut = [[UICollectionViewFlowLayout alloc] init];
    
    float item_width = kICON_WIDTH_HEIGH + kPADDING * 2;
    float item_height = kICON_WIDTH_HEIGH + kNAME_LABEL_HEIGH +  kPADDING * 2;
    
    flowLayOut.minimumInteritemSpacing = 24;
    flowLayOut.minimumLineSpacing = 0;
    
    float collectionWidth = 210;
    float collectionHeight = 180;
    
    flowLayOut.itemSize = CGSizeMake(item_width , item_height);
  
    // 移动方向的设置
    [flowLayOut setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    
    CGFloat yPosition = 0;
   
    if (self.view.frame.size.height <= 480)
    {
        yPosition = 275;
    }else{
        yPosition = 300;
    }
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5 -24 - collectionWidth*0.5, yPosition, collectionWidth, collectionHeight) collectionViewLayout:flowLayOut];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.scrollEnabled = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
   // 注册cell
    [_collectionView registerClass:[MenuToolItemView class] forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:_collectionView];
    
}

#pragma mark - 表格布局协议方法
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //返回各个单元格的控件视图
    MenuToolItem *item = [_collectionArrays objectAtIndex:indexPath.row];
    //NSString *identifier = [NSString stringWithFormat:@"Cell%d%d",indexPath.section,indexPath.row];
    MenuToolItemView  *cell = (MenuToolItemView *) [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    cell.name.text = item.name;
    cell.icon.image = [UIImage imageNamed:item.icon];
    cell.icon.frame = CGRectMake(10, 10, 20, 20);
    
    if([item.name  isEqual: @""]){
        // 当图标为 + 号时候，设置位置居中
        cell.icon.frame = CGRectMake(cell.frame.size.width*0.5 - kICON_WIDTH_HEIGH*0.5, cell.frame.size.height*0.5 - kICON_WIDTH_HEIGH*0.5, kICON_WIDTH_HEIGH, kICON_WIDTH_HEIGH);
        
    }

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _collectionArrays.count;
}

#pragma  表格布局代理方法

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
 
        DLOG(@"cell #%d was selected", (int)indexPath.row);
        [self collectionClick:(int)indexPath.row];
  
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{

}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.contentView.backgroundColor = [UIColor clearColor];
}

#pragma mark - 刷新
- (void)refreshBtnClick {
    
    DLOG(@"刷新");
    
    [self requestData];
}

#pragma mark - 信用额度
- (void)creditRatingClick {
    
    DLOG(@"我的信用等级");
    CreditLevelViewController *CreditLevelView = [[CreditLevelViewController alloc] init];
    UINavigationController *NaVController22 = [[UINavigationController alloc] initWithRootViewController:CreditLevelView];
    [self presentViewController:NaVController22 animated:YES completion:nil];
}

#pragma mark - 充值
- (void)rechargeClick {
    
    DLOG(@"充值");
    MyRechargeViewController *RechargeView = [[MyRechargeViewController alloc] init];
    UINavigationController *NaVController17 = [[UINavigationController alloc] initWithRootViewController:RechargeView];
    [self presentViewController:NaVController17 animated:YES completion:nil];
}

#pragma mark - 提现
- (void)withdrawClick {
    
    DLOG(@"提现");
    WithdrawalViewController *WithdrawalView = [[WithdrawalViewController alloc] init];
    UINavigationController *NaVController18 = [[UINavigationController alloc] initWithRootViewController:WithdrawalView];
    [self presentViewController:NaVController18 animated:YES completion:nil];
}

#pragma mark 申请VIP
- (void)vipClick {
    
    if (isLogin) {
        
        JoinVipViewController *vip = [[JoinVipViewController alloc] init];
        UINavigationController *vipController = [[UINavigationController alloc] initWithRootViewController:vip];
        [self presentViewController:vipController animated:YES completion:nil];
        
    }else {
        
        [SVProgressHUD showErrorWithStatus:@"请登录!"];
        
    }
}

#pragma 表格视图图标按钮触发方法
- (void)collectionClick:(int)num
{
    
    DLOG(@"collectionBtnClick ....btn%ld",(long)num);
    
    MenuToolItem *item = [_collectionArrays objectAtIndex:num];
 
    switch (item.Tag) {
            
        case 301:
           {
               // " + " 添加功能快捷键页面
               AccountCenterOrderView = [[AccountCenterOrderViewController alloc] init];
               NavigationController1 = [[UINavigationController alloc] initWithRootViewController:AccountCenterOrderView];
               AccountCenterOrderView.valuedelegate = self;
               

               [self presentViewController:NavigationController1 animated:YES completion:nil];
               
            
               
           }
            break;
            
        case 1:
            {
                BorrowingBillViewController *BorrowingBillView = [[BorrowingBillViewController alloc] init];
                BorrowingBillView.curr = 1;
                UINavigationController *NaVController1 = [[UINavigationController alloc] initWithRootViewController:BorrowingBillView];
                [self presentViewController:NaVController1 animated:YES completion:nil];
            }
            break;
        case 2:
           {
            
             AuditingViewController *AuditingView = [[AuditingViewController alloc] init];
             UINavigationController *NaVController2 = [[UINavigationController alloc] initWithRootViewController:AuditingView];
             [self presentViewController:NaVController2 animated:YES completion:nil];
               
           }
            break;
        case 3:
           {
            
             TenderViewController *TenderView = [[TenderViewController alloc] init];
             UINavigationController *NaVController3 = [[UINavigationController alloc] initWithRootViewController:TenderView];
             [self presentViewController:NaVController3 animated:YES completion:nil];
               
           }
            break;
        case 4:
        {
            PaymentViewController *PaymentView = [[PaymentViewController alloc] init];
            UINavigationController *NaVController4 = [[UINavigationController alloc] initWithRootViewController:PaymentView];
            [self presentViewController:NaVController4 animated:YES completion:nil];
          
        }
            break;
        case 5:
        {
            SuccessfullyViewController *SuccessfullyView = [[SuccessfullyViewController alloc] init];
            UINavigationController *NaVController5 = [[UINavigationController alloc] initWithRootViewController:SuccessfullyView];
            [self presentViewController:NaVController5 animated:YES completion:nil];

        }
            break;
        case 6:
        {
            
            LiteratureAuditMainViewController *literatureAuditView = [[LiteratureAuditMainViewController alloc] rootViewController];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:literatureAuditView];
            [navigationController setNavigationBarHidden:YES];
            [self presentViewController:navigationController animated:YES completion:nil];
            
        }
            break;
        case 101:
        {
            FinancialBillsViewController *FinancialBillsView = [[FinancialBillsViewController alloc] init];
            UINavigationController *NaVController7 = [[UINavigationController alloc] initWithRootViewController:FinancialBillsView];
            [self presentViewController:NaVController7 animated:YES completion:nil];
        }
            break;
        case 102:
        {
            
            BidRecordsViewController *BidRecordsView = [[BidRecordsViewController alloc] init];
            UINavigationController *NaVController8 = [[UINavigationController alloc] initWithRootViewController:BidRecordsView];
            [self presentViewController:NaVController8 animated:YES completion:nil];
        }
            break;
        case 103:
        {
            FullScaleViewController  *FullScaleView = [[FullScaleViewController alloc] init];
            UINavigationController *NaVController9 = [[UINavigationController alloc] initWithRootViewController:FullScaleView];
            [self presentViewController:NaVController9 animated:YES completion:nil];
        }
            break;
            
        case 104:
        {
            CollectionViewController *CollectionView = [[CollectionViewController alloc] init];
            UINavigationController *NaVController10 = [[UINavigationController alloc] initWithRootViewController:CollectionView];
            [self presentViewController:NaVController10 animated:YES completion:nil];
        }
            break;
        case 105:
        {
       
            
            CompletedViewController *CompletedView = [[CompletedViewController alloc] init];
            UINavigationController *NaVController11 = [[UINavigationController alloc] initWithRootViewController:CompletedView];
            [self presentViewController:NaVController11 animated:YES completion:nil];
        }
            break;
        case 106:
        {
            
            DebtManagementViewController *DebtManagementView = [[DebtManagementViewController alloc] init];
            UINavigationController *NaVController12 = [[UINavigationController alloc] initWithRootViewController:DebtManagementView];
            [self presentViewController:NaVController12 animated:YES completion:nil];
        }
            break;
        case 107:
        {
 
            FinancialStatisticsViewController *FinancialStatisticsView = [[FinancialStatisticsViewController alloc] init];
            UINavigationController *NaVController13 = [[UINavigationController alloc] initWithRootViewController:FinancialStatisticsView];
            [self presentViewController:NaVController13 animated:YES completion:nil];
        }
            break;
        case 108:
        {

            TenderRobotViewController *TenderRobotView = [[TenderRobotViewController alloc] init];
             UINavigationController *NaVController14 = [[UINavigationController alloc] initWithRootViewController:TenderRobotView];
            [self presentViewController:NaVController14 animated:YES completion:nil];
        }
            break;
        case 201:
        {
            AccountInfoViewController *AccountInfoView = [[AccountInfoViewController alloc] init];
            UINavigationController *NaVController15 = [[UINavigationController alloc] initWithRootViewController:AccountInfoView];
            [self presentViewController:NaVController15 animated:YES completion:nil];
        }
            break;
        case 202:
        {
            FundRecordViewController  *FundRecordView = [[FundRecordViewController alloc] init];
            UINavigationController *NaVController16 = [[UINavigationController alloc] initWithRootViewController: FundRecordView];
            [self presentViewController:NaVController16 animated:YES completion:nil];
        }
            break;
        case 203:
        {
 
            MyRechargeViewController *RechargeView = [[MyRechargeViewController alloc] init];
            UINavigationController *NaVController17 = [[UINavigationController alloc] initWithRootViewController:RechargeView];
            [self presentViewController:NaVController17 animated:YES completion:nil];
        }
            break;
        case 204:
        {

            WithdrawalViewController *WithdrawalView = [[WithdrawalViewController alloc] init];
            UINavigationController *NaVController18 = [[UINavigationController alloc] initWithRootViewController:WithdrawalView];
            [self presentViewController:NaVController18 animated:YES completion:nil];
        }
            break;
//        case 205:
//        {
//            
//            BankCardManageViewController *BankCardManageView = [[BankCardManageViewController alloc] init];
//            UINavigationController *NaVController19 = [[UINavigationController alloc] initWithRootViewController:BankCardManageView];
//            [self presentViewController:NaVController19 animated:YES completion:nil];
//         }
//            break;
        case 205:
        {
            AccuontSafeViewController *AccuontSafeView = [[AccuontSafeViewController alloc] init];
            UINavigationController *NaVController20 = [[UINavigationController alloc] initWithRootViewController:AccuontSafeView];
            [self presentViewController:NaVController20 animated:YES completion:nil];
        }
            break;
        case 206:
        {
            CreditLevelViewController *CreditLevelView = [[CreditLevelViewController alloc] init];
            UINavigationController *NaVController22 = [[UINavigationController alloc] initWithRootViewController:CreditLevelView];
            [self presentViewController:NaVController22 animated:YES completion:nil];
        }
            break;
        case 207:
        {
            MyCollectionViewController *MyCollectionView = [[MyCollectionViewController alloc] init];
            UINavigationController *NaVController23 = [[UINavigationController alloc] initWithRootViewController:MyCollectionView];
            [self presentViewController:NaVController23 animated:YES completion:nil];

           
        }
            break;
        case 208:
        {
            AttentionUserViewController *AttentionUserView = [[AttentionUserViewController alloc] init];
            UINavigationController *NaVController24 = [[UINavigationController alloc] initWithRootViewController:AttentionUserView];
            [self presentViewController:NaVController24 animated:YES completion:nil];
           
        }
            break;
        case 209:
        {
            BlackListViewController *BlackListView = [[BlackListViewController alloc] init];
            UINavigationController *NaVController25 = [[UINavigationController alloc] initWithRootViewController:BlackListView];
            [self  presentViewController:NaVController25 animated:YES completion:nil];
       
           
        } break;
            
    }
    
}


#pragma mark SendValuedelegate  接收排序数组数据
-(void)SendValue:(NSArray *)valueArr
{

    IconDataArr = valueArr;
    DLOG(@"icondatARr is ----------------%@",valueArr);
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"menu_collection_list" withExtension:@"plist"];
    NSArray *collections = [NSArray arrayWithContentsOfURL:url];
    [_collectionArrays removeAllObjects];
        for (int i = 0; i<[IconDataArr count]; i++)
         {
             AccountCenterOrder *model = [IconDataArr objectAtIndex:i];
               for (NSDictionary *item1 in collections)
               {
                  
                    
                if (model.Tag == [[item1 objectForKey:@"Tag"] integerValue])
                   {
                        MenuToolItem *bean2 = [[MenuToolItem alloc] init];
                        bean2.name = [item1 objectForKey:@"name"];
                        bean2.icon = [item1 objectForKey:@"icon"];
                        bean2.Tag = [[item1 objectForKey:@"Tag"] intValue];
                        DLOG(@"bean.name and bean.icon is %@%@%d",bean2.name,bean2.icon,bean2.Tag);
                       [_collectionArrays insertObject:bean2 atIndex:0];
                
                   }
        
             }
        
       }
    [_collectionArrays addObject:bean];
    DLOG(@"_collectionArrays %@",_collectionArrays);
    [_collectionView reloadData];
}

#pragma mark - 
#pragma mark 注册有奖
- (void)awatdBtnClick
{

    DLOG(@"注册有奖!!!!");
    SpecialEventsViewController *SpecialEventsView = [[SpecialEventsViewController alloc]  init];
      UINavigationController *SpecialEventsVC= [[UINavigationController alloc] initWithRootViewController:SpecialEventsView];
    [self presentViewController:SpecialEventsVC animated:YES completion:nil];
}


#pragma mark - kiu
#pragma  mark 个人中心 更多 设置按钮
- (void)info:(id)sender
{
    MoreViewController *moreView = [[MoreViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:moreView];
    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark 点击计算器触发方法
- (void)calculator:(id)sender
{
    CalculatorViewController *calculatorVC = [[CalculatorViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calculatorVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark 头像点击事件
- (void)login:(id)sender
{
    if(isLogin)
    {
        ChangeIconViewController *calculatorVC = [[ChangeIconViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calculatorVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }else {
        LoginViewController *calculatorVC = [[LoginViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calculatorVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}


//通知中心触发方法

-(void)update
{
    DLOG(@"通知中心触发方法==============%@===========", AppDelegateInstance.userInfo.userImg);

    isLogin = [AppDelegateInstance.userInfo.isLogin boolValue];
    NSString *username = AppDelegateInstance.userInfo.userName;
    NSString *userImg = AppDelegateInstance.userInfo.userImg;
    NSString *creditRating = AppDelegateInstance.userInfo.userCreditRating;
    NSString *creditLimit = [NSString stringWithFormat:@"%@", AppDelegateInstance.userInfo.userLimit];
    NSString *isVip = [NSString stringWithFormat:@"%@", AppDelegateInstance.userInfo.isVipStatus];
    NSString *accountAmount = [NSString stringWithFormat:@"%@", AppDelegateInstance.userInfo.accountAmount];
    NSString *availableBalance = [NSString stringWithFormat:@"%@", AppDelegateInstance.userInfo.availableBalance];
    DLOG(@"userImg -> %@", userImg);
    DLOG(@"username -> %@", username);
    DLOG(@"creditRating -> %@", creditRating);
    DLOG(@"creditLimit -> %@", creditLimit);
    DLOG(@"isVip -> %@", isVip);
    DLOG(@"isLogin -> %d", isLogin);
    
    
    if (!isLogin) {
        _loginUser.text = @"请登录";
        _amountLabel.text = @"";
        [_vipBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [_loginView setBackgroundImage:[UIImage imageNamed:@"default_head"] forState:UIControlStateNormal];
        [_loginView setBackgroundImage:nil forState:UIControlStateHighlighted];
        _levelImage.image = nil;
        [_creditRatingBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [_refreshBtn setImage:nil forState:UIControlStateNormal];
        
        _rechargeBtn.hidden = YES;
        _withdrawBtn.hidden = YES;
        _accountAmountValue.text = @"";
        _availableBalanceValue.text = @"";
        
        _accountAmountLabel.text = @"";
        _availableBalanceLabel.text = @"";
        
    }else {


        [_loginView sd_setBackgroundImageWithURL:[NSURL URLWithString:userImg]forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_head"]];
        
        _amountLabel.text = creditLimit;
        _loginUser.text = username;
        [_levelImage sd_setImageWithURL:[NSURL URLWithString:creditRating]];
        [_creditRatingBtn setBackgroundImage:[UIImage imageNamed:@"creditRating.png"] forState:UIControlStateNormal];
        [_refreshBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        _rechargeBtn.hidden = NO;
        _withdrawBtn.hidden = NO;
        _accountAmountLabel.text = @"总额：";
        _availableBalanceLabel.text = @"余额：";
        
        
         _accountAmountValue.text = accountAmount;
        
//        DLOG(@"accountAmount -> %lu", (unsigned long)accountAmount.length);
//        // 总额 （根据金额长度转换万亿单位）
//        if (accountAmount.length <= 7) {
//            _accountAmountValue.text = accountAmount;
//        }else if(accountAmount.length > 7 && accountAmount.length <= 11) {
//            _accountAmountValue.text = [NSString stringWithFormat:@"%@万", [accountAmount substringToIndex:accountAmount.length - 7]];
//
//        }else {
//            _accountAmountValue.text = [NSString stringWithFormat:@"%@亿", [accountAmount substringToIndex:accountAmount.length - 11]];
//        }
        
        
        _availableBalanceValue.text = availableBalance;
//        // 余额（根据金额长度转换万亿单位）
//        if (availableBalance.length <= 7) {
//            _availableBalanceValue.text = availableBalance;
//        }else if(availableBalance.length > 7 && availableBalance.length <= 11) {
//            _availableBalanceValue.text = [NSString stringWithFormat:@"%@万", [availableBalance substringToIndex:availableBalance.length - 7]];
//        }else {
//            _availableBalanceValue.text = [NSString stringWithFormat:@"%@亿", [availableBalance substringToIndex:availableBalance.length - 11]];
//        }


        // VIP
        if ([isVip isEqualToString:@"1"]) {
            [_vipBtn setBackgroundImage:[UIImage imageNamed:@"member_vip"] forState:UIControlStateNormal];
        }else {
            [_vipBtn setBackgroundImage:[UIImage imageNamed:@"member_no_vip"] forState:UIControlStateNormal];
        }
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    UIFont *font = [UIFont fontWithName:@"Arial" size:13];
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize _label1Sz = [_loginUser.text boundingRectWithSize:CGSizeMake(999, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    CGSize _label2Sz = [_amountLabel.text boundingRectWithSize:CGSizeMake(999, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    _loginUser.frame = CGRectMake(self.view.frame.size.width * 0.5 - (_label1Sz.width + 38) * 0.5, 117, _label1Sz.width, 20);
    _vipBtn.frame = CGRectMake(_loginUser.frame.origin.x + _loginUser.frame.size.width + 10 , 117, 20, 20);
    
    _amountLabel.frame = CGRectMake(_amount.frame.origin.x + 80, 243, _label2Sz.width + 10, 20);
    _creditRatingBtn.frame = CGRectMake(_amountLabel.frame.origin.x + _label2Sz.width + 10, 237, 30, 30);
}

#pragma mark 二维码推广
- (void)codeClick:(id)sender
{
    TwoCodeViewController *calculatorVC = [[TwoCodeViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calculatorVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)requestData {
    
    if (AppDelegateInstance.userInfo == nil) {
        [SVProgressHUD showErrorWithStatus:@"亲，请登陆"];
    }else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        NSString *name = [[AppDefaultUtil sharedInstance] getDefaultAccount];
        NSString *password = [[AppDefaultUtil sharedInstance] getDefaultUserPassword];
        NSString *deviceType = [[AppDefaultUtil sharedInstance] getdeviceType];
        
        [parameters setObject:@"1" forKey:@"OPT"];
        [parameters setObject:@"" forKey:@"body"];
        [parameters setObject:name forKey:@"name"];
        [parameters setObject:password forKey:@"pwd"];
        
        if(AppDelegateInstance.userId !=nil && AppDelegateInstance.channelId != nil)
        {
            [parameters setObject:AppDelegateInstance.userId forKey:@"userId"];
            [parameters setObject:AppDelegateInstance.channelId forKey:@"channelId"];
            
        }else{
            
            [parameters setObject:@"" forKey:@"userId"];
            [parameters setObject:@"" forKey:@"channelId"];
            
        }
        [parameters setObject:deviceType forKey:@"deviceType"];
        
        if (_requestClient == nil) {
            _requestClient = [[NetWorkClient alloc] init];
            _requestClient.delegate = self;
        }
        [_requestClient requestGet:@"app/services" withParameters:parameters];
    }
}

#pragma HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{
    
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    
    NSDictionary *dics = obj;
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        [SVProgressHUD showSuccessWithStatus:@"刷新成功"];
        
        UserInfo *usermodel = [[UserInfo alloc] init];
        
        if ([obj objectForKey:@"creditRating"] != nil && ![[obj objectForKey:@"creditRating"]isEqual:[NSNull null]])
        {
            if([[obj objectForKey:@"creditRating"] hasPrefix:@"http"])
            {
                usermodel.userCreditRating = [obj objectForKey:@"creditRating"];
                
            }else{
                usermodel.userCreditRating =  [NSString stringWithFormat:@"%@%@", Baseurl, [obj objectForKey:@"creditRating"]];
            }
        }
        usermodel.userName = [obj objectForKey:@"username"];
        
        if ([obj objectForKey:@"headImg"] != nil && ![[obj objectForKey:@"headImg"]isEqual:[NSNull null]])
        {
            if ([[obj objectForKey:@"headImg"] hasPrefix:@"http"]) {
                
                usermodel.userImg = [NSString stringWithFormat:@"%@", [obj objectForKey:@"headImg"]];
            }else{
                
                usermodel.userImg = [NSString stringWithFormat:@"%@%@", Baseurl, [obj objectForKey:@"headImg"]];
                
            }
        }
        usermodel.userLimit = [obj objectForKey:@"creditLimit"];
        usermodel.isVipStatus = [obj objectForKey:@"vipStatus"];
        usermodel.userId = [obj objectForKey:@"id"];
        usermodel.isLogin = @"1";
        usermodel.accountAmount = [NSString stringWithFormat:@"%.2f", [[obj objectForKey:@"accountAmount"] doubleValue]];
        usermodel.availableBalance = [NSString stringWithFormat:@"%.2f", [[obj objectForKey:@"availableBalance"] doubleValue]];

        AppDelegateInstance.userInfo = usermodel;
        // 通知全局广播 LeftMenuController 修改UI操作
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"update" object:[obj objectForKey:@"username"]];
        
    }else {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
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
    [SVProgressHUD showErrorWithStatus:@"无可用网络"];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestClient != nil) {
        [_requestClient cancel];
    }
}

@end

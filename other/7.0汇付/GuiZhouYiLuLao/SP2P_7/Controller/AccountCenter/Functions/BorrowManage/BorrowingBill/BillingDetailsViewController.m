//
//  BillingDetailsViewController.m
//  SP2P_7
//
//  Created by Jerry on 14-7-30.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
//  理财子账户 ->借款账单 -> 账单详情
#import "BillingDetailsViewController.h"
#import "ColorTools.h"
#import "UIFolderTableView.h"
#import "BorrowingBillDetailViewController.h"
#import "RepaymentHistoricalViewController.h"
#import "BorrowingBillDetail.h"
#import "NSString+Date.h"
#import "AccuontSafeViewController.h"
#import "MyWebViewController.h"
#import "MyRechargeViewController.h"

@interface BillingDetailsViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate, HTTPClientDelegate>
{
    NSArray *tableArr;
    
    NSInteger _requestType;// 0 代表请求账单信息，1代表付款
}

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic, strong) UIFolderTableView *listView;

@property(nonatomic ,strong) NetWorkClient *requestClient;

@property(nonatomic, strong) BorrowingBillDetail *borrowingBillDetail;

@property(nonatomic, strong) UILabel *nameLabel;

@property(nonatomic, strong) UILabel *contentLabel;

@property (nonatomic,strong) UILabel *billTitleLabel;

@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) UILabel *billIdLabel;

@property (nonatomic,strong) UILabel *billIdDateLabel;

@property (nonatomic,strong) UILabel *platformLabel;

@property (nonatomic,strong) UILabel *hotlineLabel;

@property (nonatomic,strong) UILabel *amountLabel;// 总额

@property (nonatomic,strong) UILabel *balanceLabel;// 余额

@end

@implementation BillingDetailsViewController

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
    // 初始化数据
    [self initData];
    
    // 初始化视图
    [self initView];
    
    
    [self loadData];
    
}
/**
 * 初始化数据
 */
- (void)initData
{
     tableArr = @[@"本期借款账单明细",@"借款标详细情况",@"历史还款记录"];
}

/**
 初始化数据
 */
- (void)initView
{
    
    [self initNavigationBar];
    self.view.backgroundColor = KblackgroundColor;
    
    //滚动视图
    _scrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60)];
    _scrollView.userInteractionEnabled = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator =NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = KblackgroundColor;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    [self.view addSubview:_scrollView];
    
    
    UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    backView1.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:backView1];
    
    
    _billTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 35)];
    _billTitleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
    _billTitleLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_billTitleLabel];
    
    UIView *backView2 = [[UIView alloc] initWithFrame:CGRectMake(0,51, self.view.frame.size.width, 80)];
    backView2.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:backView2];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 54, self.view.frame.size.width, 30)];
    _nameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_scrollView addSubview:_nameLabel];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, self.view.frame.size.width-20, 60)];
    _contentLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _contentLabel.textColor = [UIColor grayColor];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [_scrollView addSubview:_contentLabel];
    
    
    UIView *backView3 = [[UIView alloc] initWithFrame:CGRectMake(0,132, self.view.frame.size.width, 140)];
    backView3.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:backView3];
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 134, 90, 30)];
    promptLabel.text = @"重要提示:";
    promptLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_scrollView addSubview:promptLabel];
    
    
    UILabel *textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(80, 140, self.view.frame.size.width-20, 60)];
    textLabel2.font = [UIFont boldSystemFontOfSize:14.0f];
    textLabel2.textColor = [UIColor grayColor];
    textLabel2.text = @"本期借款账单还款日";
    [_scrollView addSubview:textLabel2];
    
    _timeLabel = [[UILabel alloc]  initWithFrame:CGRectMake(80, 170, self.view.frame.size.width, 50)];
    _timeLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0];
    _timeLabel.textColor = PinkColor;
    [_scrollView addSubview:_timeLabel];
    

    UILabel *textLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 205, self.view.frame.size.width-20, 60)];
    textLabel3.font = [UIFont boldSystemFontOfSize:14.0f];
    textLabel3.textColor = [UIColor grayColor];
    textLabel3.text = @"       尊敬的客户,为确保您还款准确,请您仔细阅读下面需还款明细栏目中各账户本期应还款金额及本期最低还款额等信息。";
    textLabel3.numberOfLines = 0;
    textLabel3.lineBreakMode = NSLineBreakByCharWrapping;
    [_scrollView addSubview:textLabel3];
    

    _listView = [[UIFolderTableView alloc] initWithFrame:CGRectMake(0, 270, self.view.frame.size.width, 400)  style:UITableViewStyleGrouped];
    _listView.delegate = self;
    _listView.dataSource = self;
    [_listView setBackgroundColor:KblackgroundColor];
    [_scrollView addSubview:_listView];
    
    _billIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, self.view.frame.size.width, 30)];
    _billIdLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    _billIdLabel.textColor = [UIColor grayColor];
    [_listView addSubview:_billIdLabel];
    
    _billIdDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, self.view.frame.size.width, 30)];
    _billIdDateLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    _billIdDateLabel.textColor = [UIColor grayColor];
    [_listView addSubview:_billIdDateLabel];
    
    _platformLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, self.view.frame.size.width, 30)];
    
    _platformLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    _platformLabel.textColor = [UIColor grayColor];
    [_listView addSubview:_platformLabel];
    
    
    _hotlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 180, self.view.frame.size.width, 30)];
    _hotlineLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    _hotlineLabel.textColor = [UIColor grayColor];
    [_listView addSubview:_hotlineLabel];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 90, self.view.frame.size.width, 90)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:bottomView aboveSubview:_scrollView];
    
    UILabel *sumtextLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, MSWIDTH/2-10, 20)];
    sumtextLabel.text = @"账户总额";
    sumtextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    sumtextLabel.textAlignment = NSTextAlignmentCenter;
    sumtextLabel.textColor = [UIColor grayColor];
    [bottomView addSubview:sumtextLabel];
    
    _amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,15, MSWIDTH/2-10, 25)];
    _amountLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
    _amountLabel.textColor = BrownColor;
    _amountLabel.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:_amountLabel];
    
    UILabel *balancetextLabel = [[UILabel alloc] initWithFrame:CGRectMake(MSWIDTH/2+5, 2, MSWIDTH/2-10, 20)];
    balancetextLabel.text = @"可用余额";
    balancetextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    balancetextLabel.textColor = [UIColor grayColor];
    balancetextLabel.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:balancetextLabel];
    
    _balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(MSWIDTH/2+5,15, MSWIDTH/2-10, 25)];
    _balanceLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
    _balanceLabel.textColor = PinkColor;
    _balanceLabel.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:_balanceLabel];
    
    
    
    if(!_isPay)
    {
        
        UIButton *repayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        repayBtn.frame = CGRectMake(self.view.frame.size.width*0.5-50, bottomView.frame.size.height-40,100, 25);
        repayBtn.backgroundColor = BrownColor;
        [repayBtn setTitle:@"还  款" forState:UIControlStateNormal];
        [repayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        repayBtn.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0];
        [repayBtn.layer setMasksToBounds:YES];
        [repayBtn.layer setCornerRadius:3.0];
        [repayBtn addTarget:self action:@selector(repayBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:repayBtn];
    
    }
    


    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 510);
}


-(void) setView
{
    BillDetail *billDetail = _borrowingBillDetail.billDetail ;
    
    _billTitleLabel.text = billDetail.bidTitle;
    
    _timeLabel.text = billDetail.repaymentTime;

    _nameLabel.text = [NSString stringWithFormat:@"尊敬的 %@ 用户，您好!", billDetail.userName];
    
    _contentLabel.text = [NSString stringWithFormat:@"     感谢您使用%@借款服务,我平台客服专线:%@ 竭诚为您服务", _borrowingBillDetail.platformName, _borrowingBillDetail.hotline];
    
    _billIdLabel.text = [NSString stringWithFormat:@"账单编号：%@", billDetail.billNumber];
    
    _billIdDateLabel.text = [NSString stringWithFormat:@"借款账单生成日期：%@", billDetail.produceBillTime];
    
    _platformLabel.text = _borrowingBillDetail.platformName;
    
    _hotlineLabel.text = [NSString stringWithFormat:@"客服专线：%@", _borrowingBillDetail.hotline];
    
    // 账户总额
    _amountLabel.text = [NSString stringWithFormat:@"%0.2f 元", [billDetail.userAmount floatValue]];
    // 可用余额
    _balanceLabel.text =  [NSString stringWithFormat:@"%0.2f 元", [billDetail.userBalance floatValue]];
}


/**
 * 初始化导航条
 */
- (void)initNavigationBar
{
    self.title = @"账单详情";
    [self.navigationController.navigationBar setBarTintColor:KColor];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Arial-BoldMT" size:18.0], NSFontAttributeName, nil]];
    
    // 导航条返回按钮
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backClick)];
    backItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
}


-(void) loadData
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [_scrollView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // 自动刷新(一进入程序就下拉刷新)
//    [_scrollView headerBeginRefreshing];
       [self headerRereshing];
}

#pragma mark UItableViewdelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableArr count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 3.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 35.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 3.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        NSString *cellID2 = @"cellid1";
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID2];
        }
        cell.textLabel.text = [tableArr objectAtIndex:indexPath.section];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_borrowingBillDetail == nil) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIFolderTableView *folderTableView = (UIFolderTableView *)tableView;
    switch (indexPath.section) {
        case 0:
        {
            UIView *dropView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90)];
            dropView.backgroundColor = [UIColor whiteColor];
            UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, dropView.frame.size.width, 30)];
    
            moneyLabel.text = [NSString stringWithFormat:@"本期账单应还金额：%@ 元", [_borrowingBillDetail.billDetail currentPayAmount]];
            moneyLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            moneyLabel.textColor = [UIColor grayColor];
            [dropView addSubview:moneyLabel];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, dropView.frame.size.width, 30)];
            timeLabel.text = [NSString stringWithFormat:@"还款到期时间：%@", [_borrowingBillDetail.billDetail repaymentTime]];
            timeLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            timeLabel.textColor = [UIColor grayColor];
            [dropView addSubview:timeLabel];
            
            UILabel *wayLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 50, dropView.frame.size.width, 30)];
            wayLabel.text = [NSString stringWithFormat:@"还款方式：%@", [_borrowingBillDetail.billDetail repaymentType]];
            wayLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            wayLabel.textColor = [UIColor grayColor];
            [dropView addSubview:wayLabel];
            
            _listView.scrollEnabled = NO;
            [folderTableView openFolderAtIndexPath:indexPath WithContentView:dropView
                                         openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                             // opening actions
                                             //[self CloseAndOpenACtion:indexPath];
                                         }
                                        closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                            // closing actions
                                            //[self CloseAndOpenACtion:indexPath];
                                            //[cell changeArrowWithUp:NO];
                                        }
                                   completionBlock:^{
                                       // completed actions
                                       _listView.scrollEnabled = YES;
                                   }];
        }
            break;
            
        case 1:
        {
            BorrowingBillDetailViewController *borrowingBillDetailsView = [[BorrowingBillDetailViewController alloc] init];
            borrowingBillDetailsView.billDetail = _borrowingBillDetail.billDetail;
            [self.navigationController pushViewController:borrowingBillDetailsView animated:YES];
            
        }
            break;
        case 2:
        {
            RepaymentHistoricalViewController *repaymentHistoricalView = [[RepaymentHistoricalViewController alloc] init];
            repaymentHistoricalView.historyArrays = _borrowingBillDetail.historyArrays;
            [self.navigationController pushViewController:repaymentHistoricalView animated:YES];
        }
            break;
 
    }

}

#pragma mark 还款按钮
- (void)repayBtnClick
{
//    DLOG(@"是否设置了交易密码: %d", AppDelegateInstance.userInfo.isPayPasswordStatus);
//    if (AppDelegateInstance.userInfo.isPayPasswordStatus) {
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入交易密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//        //[alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
//        [alertView textFieldAtIndex:0].secureTextEntry = YES;
//        [alertView show];
//        
//    }else{
//            
//            [SVProgressHUD showErrorWithStatus:@"请先设置交易密码保障安全"];
//            AccuontSafeViewController *AccuontSafeView = [[AccuontSafeViewController alloc] init];
//            UINavigationController *NaVController20 = [[UINavigationController alloc] initWithRootViewController:AccuontSafeView];
//        AccuontSafeView.backTypeNum = 2;
//            [self presentViewController:NaVController20 animated:YES completion:nil];
//        
//    }
    
    if (AppDelegateInstance.userInfo == nil || _borrowingBillDetail == nil) {
        return;
    }
    
    _requestType = 1;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"89" forKey:@"OPT"]; //已成功的借款标查询
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:_billId forKey:@"billId"];
    [parameters setObject:[NSString stringWithFormat:@"%@", _borrowingBillDetail.billDetail.currentPayAmount] forKey:@"payAmount"];
//    NSString *dealDES = [NSString encrypt3DES:dealPwd key:DESkey];
//    [parameters setObject:dealDES forKey:@"dealPwd"];
    [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
    }
    [_requestClient requestGet:@"app/services" withParameters:parameters];
    

 
}

#pragma 返回按钮触发方法
- (void)backClick
{
    // DLOG(@"返回按钮");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma 请求数据
-(void) requestData
{
    if (AppDelegateInstance.userInfo == nil) {
        [self hiddenRefreshView];
         [ReLogin outTheTimeRelogin:self];
        return;
    }
    
    _requestType = 0;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"88" forKey:@"OPT"]; //已成功的借款标查询
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:_billId forKey:@"billId"];
    [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
    
    if (_requestClient == nil) {
        _requestClient = [[NetWorkClient alloc] init];
        _requestClient.delegate = self;
    }
    [_requestClient requestGet:@"app/services" withParameters:parameters];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    [self requestData];
}


#pragma HTTPClientDelegate 网络数据回调代理
-(void) startRequest
{
    
}

// 返回成功
-(void) httpResponseSuccess:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didSuccessWithObject:(id)obj
{
    [self hiddenRefreshView];
    
    NSDictionary *dics = obj;
    DLOG(@"===%@=======", dics);
    DLOG(@"msg  -> %@", [obj objectForKey:@"msg"]);
    
    if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-1"]) {
        
        if (_requestType == 0) {
            _borrowingBillDetail = [[BorrowingBillDetail alloc] init];
            _borrowingBillDetail.hotline = [dics objectForKey:@"hotline"];
            _borrowingBillDetail.platformName = [dics objectForKey:@"platformName"];
            
            NSArray *dataArr = [[dics objectForKey:@"page"] objectForKey:@"page"];
            NSMutableArray *historys = [[NSMutableArray alloc]  init];
            for (NSDictionary *item in dataArr) {
                HistoryRepayment *bean = [[HistoryRepayment alloc] init];
                bean.title = [item objectForKey:@"title"];
                bean.currentPayAmount = [item objectForKey:@"current_pay_amount"];
                bean.status = [[item objectForKey:@"status"] intValue];
                bean.overdueMark = [[item objectForKey:@"overdue_mark"] intValue];
                bean.period = [dataArr indexOfObject:item] + 1;
                
                if ([item objectForKey:@"repayment_time"] != nil && ![[item objectForKey:@"repayment_time"] isEqual:[NSNull null]]) {
                    bean.repaymentTime = [NSString converDate:[[item objectForKey:@"repayment_time"] objectForKey:@"time"] withFormat:@"yyyy-MM-dd"];
                }
                
                [historys addObject:bean];
            }
            
            _borrowingBillDetail.historyArrays = historys;
            
            NSDictionary *billDetailDics = [dics objectForKey:@"billDetail"];
            
            BillDetail *billDetail =  [[BillDetail alloc] init];
            
            if (billDetailDics != nil && ![billDetailDics isEqual:[NSNull null]]) {
                billDetail.bidTitle = [billDetailDics objectForKey:@"bid_title"];
                billDetail.loanAmount = [billDetailDics objectForKey:@"loan_amount"];
                billDetail.loanPrincipalInterest = [billDetailDics objectForKey:@"loan_principal_interest"];
                billDetail.loanPeriods = [[billDetailDics objectForKey:@"loan_periods"] intValue];
                billDetail.apr = [[billDetailDics objectForKey:@"apr"] floatValue];
                billDetail.currentPayAmount = [billDetailDics objectForKey:@"current_pay_amount"];
                billDetail.hasPayedPeriods = [[billDetailDics objectForKey:@"has_payed_periods"] intValue];
                billDetail.remainPeriods = billDetail.loanPeriods - billDetail.hasPayedPeriods;
                billDetail.userName = [billDetailDics objectForKey:@"user_name"];
                billDetail.billNumber = [billDetailDics objectForKey:@"bill_number"];
                
                billDetail.userBalance = [billDetailDics objectForKey:@"user_balance"];
                billDetail.userAmount = [billDetailDics objectForKey:@"user_amount"];
                
                billDetail.repaymentType = [billDetailDics objectForKey:@"repayment_type"];
                
                if ([billDetailDics objectForKey:@"repayment_time"] != nil && ![[billDetailDics objectForKey:@"repayment_time"] isEqual:[NSNull null]]) {
                    
                    billDetail.repaymentTime = [NSString converDate:[[billDetailDics objectForKey:@"repayment_time"] objectForKey:@"time"] withFormat:@"yyyy-MM-dd"];
                }
                
                if ([billDetailDics objectForKey:@"produce_bill_time"] != nil && ![[billDetailDics objectForKey:@"produce_bill_time"] isEqual:[NSNull null]]) {
                    billDetail.produceBillTime = [NSString converDate:[[billDetailDics objectForKey:@"produce_bill_time"] objectForKey:@"time"] withFormat:@"yyyy-MM-dd"];
                }
            }
            
            _borrowingBillDetail.billDetail = billDetail;
            
            [self setView];
            
        }else if(_requestType == 1){
        
            if (![[obj objectForKey:@"htmlParam"]isEqual:[NSNull null]] && [obj objectForKey:@"htmlParam"] != nil)
            {
                NSString *htmlParam = [NSString stringWithFormat:@"%@",[obj objectForKey:@"htmlParam"]];
                MyWebViewController *web = [[MyWebViewController alloc]init];
                web.html = htmlParam;
                web.type = @"8";
                [self.navigationController pushViewController:web animated:YES];
            }else{
                [[NSNotificationCenter defaultCenter]  postNotificationName:@"BorrowingBillSuccess" object:self];
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
               
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * 600000000ull)), dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }
        }
        
    }else if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-999"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"可用余额不足，是否现在充值？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 50;
        [alertView show];
        
    }
    else if ([[NSString stringWithFormat:@"%@",[dics objectForKey:@"error"]] isEqualToString:@"-2"]) {
        
        [ReLogin outTheTimeRelogin:self];
        
    }else {
        // 服务器返回数据异常
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [obj objectForKey:@"msg"]]];
    }
}

// 返回失败
-(void) httpResponseFailure:(NetWorkClient *)client dataTask:(NSURLSessionDataTask *)task didFailWithError:(NSError *)error
{
     [self hiddenRefreshView];
    // 服务器返回数据异常
//    [SVProgressHUD showErrorWithStatus:@"网络异常"];
}

// 无可用的网络
-(void) networkError
{
     [self hiddenRefreshView];
    // 服务器返回数据异常
    [SVProgressHUD showErrorWithStatus:@"无可用网络"];
}

#pragma Hidden View

// 隐藏刷新视图
-(void) hiddenRefreshView
{
    if (!self.scrollView.isHeaderHidden) {
        [self.scrollView headerEndRefreshing];
    }
    
    if (!self.scrollView.isFooterHidden) {
        [self.scrollView footerEndRefreshing];
    }
}

#pragma UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLOG(@"buttonIndex: %ld", (long)buttonIndex);
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
        {
            if (alertView.tag == 50)
            {
                MyRechargeViewController *RechargeView = [[MyRechargeViewController alloc]init];
                RechargeView.level = 1;
                [self.navigationController pushViewController:RechargeView animated:YES];
            }else{
                DLOG(@"确定按钮===%@===", [alertView textFieldAtIndex:0].text);
                if ([alertView textFieldAtIndex:0].text.length > 0) {
                    [self requestRepayment:[alertView textFieldAtIndex:0].text];
                }
            }
        }
            break;
        default:
            break;
    }

}


#pragma 还款
// 根据交易密码还款
-(void) requestRepayment:(NSString *)dealPwd
{
    if (AppDelegateInstance.userInfo == nil || _borrowingBillDetail == nil) {
        return;
    }
    
    _requestType = 1;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"89" forKey:@"OPT"]; //已成功的借款标查询
    [parameters setObject:@"" forKey:@"body"];
    [parameters setObject:_billId forKey:@"billId"];
    [parameters setObject:[NSString stringWithFormat:@"%@", _borrowingBillDetail.billDetail.currentPayAmount] forKey:@"payAmount"];
    NSString *dealDES = [NSString encrypt3DES:dealPwd key:DESkey];
    [parameters setObject:dealDES forKey:@"dealPwd"];
    [parameters setObject:AppDelegateInstance.userInfo.userId forKey:@"id"];
    
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

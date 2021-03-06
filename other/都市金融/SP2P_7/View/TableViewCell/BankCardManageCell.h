//
//  BankCardManageCell.h
//  SP2P_7
//
//  Created by Jerry on 14-8-5.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankCardManageCell : UITableViewCell

@property (nonatomic,strong) UILabel *banknameLabel;
@property (nonatomic,strong) UIImageView *bankCardImage;
@property (nonatomic,strong) UILabel *branchbanknameLabel;
@property (nonatomic,strong) UILabel *bankNumLabel;
@property (nonatomic,strong) UILabel *NameLabel;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIButton *editBtn;
/**
 *  填充cell的对象
 *
 */
- (void)fillCellWithObject:(id)object;

@end

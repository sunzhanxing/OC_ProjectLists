//
//  AttentionUser.h
//  SP2P_7
//
//  Created by 李小斌 on 14-9-28.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttentionUser : NSObject

@property (nonatomic, strong) NSString *attentionUserPhoto;// 好友头像
@property (nonatomic, assign) NSInteger attentionUserId;// 好友用户ID

@property (nonatomic, strong) NSString *attentionUserName;// 好友用户名
@property (nonatomic, strong) NSString *sign;// 用户加密ID

@property (nonatomic, strong) NSString *signAttentionUserId; // 好友用户加密ID
@property (nonatomic, assign) NSInteger userId; // 用户ID

@property (nonatomic, assign) NSInteger uId;

@end

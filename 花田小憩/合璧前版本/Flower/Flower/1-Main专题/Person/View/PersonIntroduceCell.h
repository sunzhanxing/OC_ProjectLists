//
//  PersonIntroduceCell.h
//  Flower
//
//  Created by HUN on 16/7/13.
//  Copyright © 2016年 hundred Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroduceModel.h"
@interface PersonIntroduceCell : UICollectionViewCell

@property(nonatomic,strong)IntroduceModel *model;


-(CGFloat)personIntroduceHeight;
@end

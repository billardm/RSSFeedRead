//
//  UIHeaderView.h
//  RSSFeedRead
//
//  Created by Michael Billard on 4/18/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIHeaderView : UICollectionReusableView
@property (nonatomic, strong)UILabel* titleLabel;
@property (nonatomic, strong)UIButton* refreshButton;
@end

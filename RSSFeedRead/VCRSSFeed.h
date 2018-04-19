//
//  VCRSSFeed.h
//  RSSFeedRead
//
//  Created by Michael Billard on 4/16/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface VCRSSFeed : UIViewController
//Collection view to hold the RSS items.
@property (nonatomic, strong)UICollectionView* collectionView;
@property (nonatomic, strong)UIActivityIndicatorView* activityIndicator;
@end


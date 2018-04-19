//
//  UIWebViewController.h
//  RSSFeedRead
//
//  Created by Michael Billard on 4/19/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RSSItem+CoreDataClass.h"

@interface UIWebViewController : UIViewController <UIWebViewDelegate>
@property(nonatomic, weak)RSSItem* item;
@property(nonatomic, strong)UIWebView* webView;
@end

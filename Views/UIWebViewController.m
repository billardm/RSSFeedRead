//
//  UIWebViewController.m
//  RSSFeedRead
//
//  Created by Michael Billard on 4/19/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import "UIWebViewController.h"

@interface UIWebViewController ()
@end

@implementation UIWebViewController

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    
    //Set the title
    self.navigationItem.title = self.item.title;
    
    //Refresh view
    [self refreshView];
}

- (void)refreshView {
    NSURL* url = [NSURL URLWithString:self.item.link];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //Offset the content a bit to account for the navigation bar.
    float offsetHeight = self.navigationController.navigationBar.frame.size.height;
    
    //And don't forget the status bar...
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    offsetHeight += MIN(statusBarSize.width, statusBarSize.height);
    
    //Now setup the content insets
    [webView.scrollView setContentInset:UIEdgeInsetsMake(offsetHeight, 0, 0, 0)];
    [webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(offsetHeight, 0, 0, 0)];
    [webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}
@end

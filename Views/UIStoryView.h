//
//  UIStoryView.h
//  RSSFeedRead
//
//  Created by Michael Billard on 4/18/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryView : UICollectionViewCell
@property(nonatomic, strong)UIImageView* imageView;
@property(nonatomic, strong)UILabel* titleLabel;
@property(nonatomic, strong)UILabel* summaryLabel;

/**
 Shows/hides the summary label and resizes the image and title labels as needed.
*/
- (void)setSummaryVisible:(BOOL)summaryVisible;

/**
 Asynchronously loads the image provided by the input parameter.
 - Parameter imageURLString : An NSString containing the URL of the image to load.
*/
- (void)loadImage:(NSString*)imageURLString;
@end

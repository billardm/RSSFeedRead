//
//  UIHeaderView.m
//  RSSFeedRead
//
//  Created by Michael Billard on 4/18/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import "UIHeaderView.h"

@implementation UIHeaderView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //Create resizing mask
        UIViewAutoresizing resizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        //setup the label
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.autoresizingMask = resizingMask;
        self.titleLabel.textColor = [UIColor blackColor];
        
        //Set default text
        self.titleLabel.text = @"Something";
        
        //Add the view
        [self addSubview:self.titleLabel];
    }
    return self;
}
- (BOOL)shouldUpdateFocusInContext:(UIFocusUpdateContext *)context {
    return true;
}
/*
- (id)initWithFrame:(CGRect)frame withRefresh:(BOOL)showRefresh buttonWidth:(float)buttonWidth {
    if ([super initWithFrame:frame]) {
        //Create resizing mask
        UIViewAutoresizing resizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        //Init the label and button
        if (showRefresh) {
            //Adjust the label frame to account for the button.
            CGRect labelFrame = self.bounds;
            labelFrame.size.width -= buttonWidth;
            
            //setup the label
            self.titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
            self.titleLabel.autoresizingMask = resizingMask;
            self.titleLabel.textColor = [UIColor blackColor];
            
            //Set default text
            self.titleLabel.text = @"Something";
            
            //Add the view
            [self addSubview:self.titleLabel];
            
            //Setup the button
        }
        
        //Init just the label
        else {
            //setup the label
            self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
            self.titleLabel.autoresizingMask = resizingMask;
            self.titleLabel.textColor = [UIColor blackColor];
            
            //Set default text
            self.titleLabel.text = @"Something";
            
            //Add the view
            [self addSubview:self.titleLabel];
        }
    }
    return self;
}
*/
@end

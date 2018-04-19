//
//  UIStoryView.m
//  RSSFeedRead
//
//  Created by Michael Billard on 4/18/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import "UIStoryView.h"

//Font sizes
#define kFontSizeTitle 20
#define kFontSizeTitleNoSummary 14
#define kFontSizeSummary 12

//View heights: these are ratios to account for varying sizes of the panels.
//Front page heights
#define kImageFrameWithSummaryHeight 0.6
#define kTitleWithSummaryHeight 0.15

//Older story heights
#define kImageFrameNoSummaryHeight 0.6
#define kTitleOnlyHeight 0.4

@interface UIStoryView() {
    NSURLSessionDataTask* dataTask;
}
@end

@implementation UIStoryView
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //Set background color
        self.backgroundColor = [UIColor whiteColor];
        
        //Create resizing mask
        UIViewAutoresizing resizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        //Setup the image
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = resizingMask;
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.imageView];
        
        //Setup the title
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.autoresizingMask = resizingMask;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.adjustsFontSizeToFitWidth = NO;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.numberOfLines = 1;
        [self.titleLabel setFont:[UIFont systemFontOfSize:kFontSizeTitle]];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        
        //Set default text
        self.titleLabel.text = @"This is a super long title that should have a lot of text but only one line.";
        
        //Add the view
        [self addSubview:self.titleLabel];
        
        //Setup the summary
        self.summaryLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.summaryLabel.autoresizingMask = resizingMask;
        self.summaryLabel.textColor = [UIColor blackColor];
        self.summaryLabel.adjustsFontSizeToFitWidth = NO;
        self.summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.summaryLabel.numberOfLines = 0;
        [self.summaryLabel setFont:[UIFont systemFontOfSize:kFontSizeSummary]];
        [self.summaryLabel setTextAlignment:NSTextAlignmentLeft];
        
        //Set default text
        self.summaryLabel.text = @"This is my super long summary that should have a lot of text but only two lines. There should be a whole lot of text but only two lines. Seriously, make sure that the summary has a lot of text and that only two lines are shown.";
        
        //Add the view
        [self addSubview:self.summaryLabel];
    }
    return self;
}

- (void)setSummaryVisible:(BOOL)summaryVisible {
    if (summaryVisible) {
        //Show the summary label
        [self.summaryLabel setHidden:NO];
        
        //Resize the imageview
        CGRect frame = self.bounds;
        frame.size.height *= kImageFrameWithSummaryHeight;
        self.imageView.frame = frame;
        
        //Resize the title label
        self.titleLabel.numberOfLines = 1;
        frame = self.bounds;
        frame.size.height *= kTitleWithSummaryHeight;
        frame.origin.y = self.imageView.frame.size.height;
        self.titleLabel.frame = frame;
        
        //Resize the font for the front page title
        [self.titleLabel setFont:[UIFont systemFontOfSize:kFontSizeTitle]];

        //Resize the summary label. Its height takes up the remaining space.
        frame.size.height = self.bounds.size.height - self.titleLabel.frame.size.height - self.imageView.frame.size.height;
        frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
        self.summaryLabel.frame = frame;
    } else {
        //Hide the summary label
        [self.summaryLabel setHidden:YES];
        
        //Resize the imageview
        CGRect frame = self.bounds;
        frame.size.height *= kImageFrameNoSummaryHeight;
        self.imageView.frame = frame;

        //Resize the title label
        self.titleLabel.numberOfLines = 2;
        frame = self.bounds;
        frame.size.height *= kTitleOnlyHeight;
        frame.origin.y = self.imageView.frame.size.height;
        self.titleLabel.frame = frame;

        //Resize font so that we get a bit more of the title
        [self.titleLabel setFont:[UIFont systemFontOfSize:kFontSizeTitleNoSummary]];
    }
}

- (void)loadImage:(NSString*)imageURLString {
    if (imageURLString == nil) {
        return;
    }
    
    //Setup the URL
    NSURL* requestURL = [NSURL URLWithString:imageURLString];
    
    //Setup the session
    __weak UIStoryView* weakSelf = self;
    NSURLSession* session = [NSURLSession sharedSession];
    
    //Setup the data task
    [dataTask cancel];
    dataTask = [session dataTaskWithURL:requestURL
                      completionHandler:^(NSData *data,
                                          NSURLResponse *response,
                                          NSError *error) {
                          // handle response
                          if (error == nil) {
                              UIImage* image = [UIImage imageWithData:data];
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  weakSelf.imageView.image = image;
                              });
                          }
                          
                          else {
                              NSLog(@"Error while trying to download an image: %@", error);
                          }
                      }];
    
    //Start up the task
    [dataTask resume];
}
@end

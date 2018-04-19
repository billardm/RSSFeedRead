//
//  VCRSSFeed.m
//  RSSFeedRead
//
//  Created by Michael Billard on 4/16/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "VCRSSFeed.h"
#import "AppDelegate.h"
#import "RSSItem+CoreDataClass.h"
#import "RSSRequest.h"
#import "UIHeaderView.h"
#import "UIStoryView.h"
#import "UIWebViewController.h"

#pragma mark - Constants
//Server URL
#define kRSSFeedURL @"https://www.personalcapital.com/blog/feed/?cat=3,891,890,68,284"

//Cell identifiers
NSString* const kCellIdentifier = @"cellIdentifier";

//Items per older story
#define kItemsPerRowiPhone 2
#define kItemsPerRowiPad 3

//Aspect ratio for the older stories.
//Used to determine height of the view from its calculated width.
#define kViewAspectRatio 0.7

//Story insets
#define kStoryInsetBottom 10
#define kStoryInsetLeft 10
#define kStoryInsetTop 10
#define kStoryInsetRight 10

//Header view constants
#define kHeaderViewKind @"HeaderView"
#define kHeaderIdentifier @"Header"
#define kHeaderHeight 50
#define kRefreshButtonWidth 50

//Fetch items
#define kFetchSize 120

@interface VCRSSFeed () <RSSRequestDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    AppDelegate* appDelegate;
    RSSRequest* request;
    UIEdgeInsets storyInsets;
    NSArray* fetchResults;
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIWebViewController* webViewController;
@end

@implementation VCRSSFeed

#pragma mark - View setup
- (void)viewDidLoad {
    [super viewDidLoad];
    //Get the app delegte
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.persistentContainer.viewContext;
    
    //Setup refresh button
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateFromServer)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    //Setup the request
    request = [[RSSRequest alloc] initWithURLString:kRSSFeedURL];
    request.delegate = self;
    
    //Get some items from the database to display
    [self fetchItems];
}

/**
 Refreshes the data from the server.
*/
- (void)updateFromServer {
    [request refreshData];
}

- (void)loadView {
    //Setup the collection view
    [self setupCollectionView];
    
    //Now set up the activity indicator
    [self setupActivityIndicator];
    
    //Setup the web view controller
    self.webViewController = [[UIWebViewController alloc] initWithNibName:nil bundle:nil];
    self.webViewController.view = [[UIView alloc] initWithFrame:self.view.bounds];
    self.webViewController.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webViewController.webView.delegate = self.webViewController;
    [self.webViewController.view addSubview:self.webViewController.webView];
}

- (void)viewWillLayoutSubviews {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setupActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.frame = self.collectionView.bounds;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.collectionView addSubview:self.activityIndicator];
}

- (void)setupCollectionView {
    //Create resizing mask
    UIViewAutoresizing resizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    //Setup edge insets
    storyInsets = UIEdgeInsetsMake(kStoryInsetBottom, kStoryInsetLeft, kStoryInsetTop, kStoryInsetRight);
    
    //Setup our view
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Setup the flow layout
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    //TODO: find out why the app is crashing when we have header views and the device is rotated.
//    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, kHeaderHeight);
    
    //Create the collection view
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    
    //Make sure we adjust when the user rotates the device.
    self.collectionView.autoresizingMask = resizingMask;
    
    //Set delegate
    self.collectionView.delegate = self;
    
    //Set data source
    self.collectionView.dataSource = self;
    
    //Register the view cell and header classes
    [self.collectionView registerClass:[UIStoryView class] forCellWithReuseIdentifier:kCellIdentifier];
    //TODO: find out why the app is crashing when we have header views and the device is rotated.
//    [self.collectionView registerClass:[UIHeaderView class] forSupplementaryViewOfKind:kHeaderViewKind withReuseIdentifier:kHeaderIdentifier];
    
    //Setup background color
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    //All done, add the view
    [self.view addSubview:self.collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RSSRequestDelegate
/**
 Informs the delegate that the RSSRequest has parsed a new <item> element.
 - Parameter request: An RSSRequest that has finished its operation.
 - Parameter itemDictionary: An NSDictionary containing key-value pairs parsed from the <item> element.
 */
-(void)request:(RSSRequest*)request didParseRSSItem:(NSDictionary*)itemDictionary {
    //Make sure we have a guid
    NSString* guid = [itemDictionary objectForKey:kGUID];
    if (guid == nil) {
        return;
    }
    
    //Uncomment for debug purposes
//    NSLog(@"%@", [itemDictionary objectForKey:kGUID]);
//    NSLog(@"%@", [itemDictionary objectForKey:kTitle]);
//    NSLog(@"%@", [itemDictionary objectForKey:kPubDate]);
//    NSLog(@"%@", [itemDictionary objectForKey:kDescription]);
//    NSLog(@"%@", [itemDictionary objectForKey:kLink]);
//    NSLog(@"%@", [itemDictionary objectForKey:kImageURL]);
//    NSLog(@"%@", [itemDictionary objectForKey:kImageHeight]);
//    NSLog(@"%@", [itemDictionary objectForKey:kImageWidth]);
    
    //Save the RSSItem in the background so we don't tie up the networking thread.
    [appDelegate.persistentContainer performBackgroundTask:^(NSManagedObjectContext* moc){
        //Does the item exist? If not, we'll create one.
        RSSItem* rssItem = [self getRSSItemForGUID:guid withMOC:moc];
        if (rssItem == nil) {
            rssItem = (RSSItem*)[NSEntityDescription insertNewObjectForEntityForName:@"RSSItem" inManagedObjectContext:moc];
        }
        
        //Now set the fields.
        //guid
        rssItem.guid = guid;
        
        //title
        NSString* value = [itemDictionary objectForKey:kTitle];
        if (value != nil) {
            rssItem.title = value;
        }
        
        //pubdate
        value = [itemDictionary objectForKey:kPubDate];
        if (value != nil) {
            rssItem.pubDate = value;
        }

        //description
        value = [itemDictionary objectForKey:kDescription];
        if (value != nil) {
            rssItem.summary = value;
        }

        //link
        value = [itemDictionary objectForKey:kLink];
        if (value != nil) {
            rssItem.link = value;
        }

        //image url
        value = [itemDictionary objectForKey:kImageURL];
        if (value != nil) {
            rssItem.imageURL = value;
        }

        //image height
        value = [itemDictionary objectForKey:kImageHeight];
        int intValue = [value intValue];
        if (value != nil) {
            rssItem.imageHeight = intValue;
        }

        //image width
        value = [itemDictionary objectForKey:kImageWidth];
        intValue = [value intValue];
        if (value != nil) {
            rssItem.imageWidth = intValue;
        }

        //Save the data
        NSError* saveError;
        [moc save:&saveError];
        if (saveError != nil) {
            NSLog(@"Error while trying to save an RSSItem into the database: %@", saveError);
        }
        
        //Save the view context
        [self->_managedObjectContext performBlockAndWait:^{
            NSError* viewContextError;
            [self->_managedObjectContext save:&viewContextError];
            if (viewContextError != nil) {
                NSLog(@"Error while trying to save an RSSItem into the viewContext: %@", viewContextError);
            }
        }];
    }];
}

/**
 The RSSRequest has completed, possibly with an error.
 - Parameter request: An RSSRequest that has finished its operation.
 - Parameter error: An NSError with information about what went wrong. Nil if there was no issue.
 */
-(void)request:(RSSRequest*)request completedWithError:(NSError*)error {
    if (error == nil) {
        NSLog(@"Request finished.");
        
        //Fetch items from the database to display.
        [self fetchItems];
    } else {
        NSLog(@"Error during RSSRequest: %@", error);
    }
    
    //Stop the activity indicator
    [self.activityIndicator stopAnimating];
}

#pragma mark - UICollectionView delegates
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //If no items in the fech results, then return 0
    if (fetchResults.count == 0) {
        return 0;
    }
    return 2;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    //If no items in the fech results, then return 0
    if (fetchResults.count == 0) {
        return 0;
    }
    
    //Return item count based on fetched results
    if (section == 0) {
        return 1;
    } else {
        return fetchResults.count;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    UIStoryView* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    //Get the RSSItem
    RSSItem* item;
    
    //Front page/other pages
    if (indexPath.section == 0) {
        item = [fetchResults objectAtIndex:0];
        
        //Setup as front page
        [cell setSummaryVisible:YES];

        //Setup summary text.
        //We need to render the HTML into a label. This can take awhile and if we
        //do this inline, then we'll get CATransaction sync errors. So, let's do this on
        //a background thread.
        NSString* summaryText = item.summary;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            //Create paragraph style
            NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
            paragrahStyle.lineSpacing = 1.5;
            paragrahStyle.lineHeightMultiple = 0;
            paragrahStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            
            //Create font
            UIFont *fontStyle = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];

            //Create the attributed string
            NSMutableAttributedString* htmlString = [[NSMutableAttributedString alloc] initWithData:[summaryText dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            //Add attributes
            [htmlString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [htmlString length])];
            [htmlString addAttribute:NSFontAttributeName value:fontStyle range:NSMakeRange(0, [htmlString length])];
            
            //Ok we're done creating the attributed string. Now set the string... but on the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.summaryLabel.attributedText = htmlString;
            });
        });
    } else {
        item = [fetchResults objectAtIndex:indexPath.row + 1];
        [cell setSummaryVisible:NO];
    }
    
    //Title
    cell.titleLabel.text = item.title;
    
    //Image
    [cell loadImage:item.imageURL];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //Get the RSSItem
    RSSItem* item;
    if (indexPath.section == 0) {
        item = [fetchResults objectAtIndex:0];
    } else {
        item = [fetchResults objectAtIndex:indexPath.row + 1];
    }
    
    //Setup the web view controller
    self.webViewController.item = item;
    
    //push the controller
    [appDelegate.navController pushViewController:self.webViewController animated:YES];
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //The first section takes up half the screen.
    if (indexPath.section == 0) {
        return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height / 2);
    }
    
    //The second section depends upon whether or not we're an iPhone or iPad.
    else {
        //Setup items per row
        float itemsPerRow = kItemsPerRowiPhone;
        
        //iPad gets 3 items per row...
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            itemsPerRow = kItemsPerRowiPad;
        }
        
        //Now calculate the size.
        float padding = storyInsets.left * (itemsPerRow + 1);
        float viewWidth = (self.view.frame.size.width - padding) / itemsPerRow;
        return CGSizeMake(viewWidth, viewWidth * kViewAspectRatio);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsZero;
    } else {
        return storyInsets;
    }
}

/*
 TODO: Determine why the header view is crashing the app upon rotation
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, kHeaderHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeZero;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    //Get the header view
    UIHeaderView* headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kHeaderViewKind withReuseIdentifier:kHeaderIdentifier forIndexPath:indexPath];
    
    //Configure the view

    //Done
    return headerView;
}
*/

#pragma mark - Helpers
- (void)fetchItems {
    //Start activity indicator
    [self.activityIndicator startAnimating];
    
    //Run the fetch request
    [appDelegate.persistentContainer performBackgroundTask:^(NSManagedObjectContext* moc){
        //build the request
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"RSSItem" inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:kFetchSize];
        
        //Execute request
        NSError* fetchError;
        self->fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError != nil) {
            NSLog(@"Error while trying to fetch an RSSItem: %@", fetchError);
            return;
        }
        
        //If we have no items in the database then fetch them.
        if (self->fetchResults.count == 0) {
            [self->request refreshData];
            return;
        }
        
        //Update the collection view
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self.activityIndicator stopAnimating];
        });
    }];
}

-(RSSItem*)getRSSItemForGUID:(NSString*)guid withMOC:(NSManagedObjectContext*)moc {
    
    //Setup the fetch request
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"RSSItem" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid = %@", guid];
    fetchRequest.predicate = predicate;
    
    //Run it
    NSError* fetchError;
    NSArray* fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError != nil) {
        NSLog(@"Error while trying to fetch an RSSItem: %@", fetchError);
        return nil;
    }
    
    //See if we have an existing item
    if (fetchResults.count == 0) {
        return nil;
    }
    
    //We got one.
    return (RSSItem*)[fetchResults objectAtIndex:0];
}
@end

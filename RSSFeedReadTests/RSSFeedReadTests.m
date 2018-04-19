//
//  RSSFeedReadTests.m
//  RSSFeedReadTests
//
//  Created by Michael Billard on 4/16/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RSSRequest.h"

@interface RSSFeedReadTests : XCTestCase

@end

@implementation RSSFeedReadTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

/**
 This is a simple test to make sure the RSSRequest is properly handling rss item processing.
 */
#define kTitleTest @"FRED"
#define kLinkTest @"link"
#define kPubDateTest @"SomeDate"
#define kDescriptionTest @"SomeDescription"
#define kGuidTest @"1234567890"
#define kImageURLTest @"https://someWebSite.com/image.jpg"
#define kImageHeightTest @"500"
#define kImagewidthTest @"500"
- (void)testRSSItemParsing {
    RSSRequest* request = [[RSSRequest alloc] init];
    
    //Begin RSS item
    [request parser:nil didStartElement:@"item" namespaceURI:nil qualifiedName:nil attributes:nil];
    
    //Title
    [request parser:nil didStartElement:@"title" namespaceURI:nil qualifiedName:nil attributes:nil];
    [request parser:nil foundCharacters:kTitleTest];
    [request parser:nil didEndElement:@"title" namespaceURI:nil qualifiedName:nil];

    //Link
    [request parser:nil didStartElement:@"link" namespaceURI:nil qualifiedName:nil attributes:nil];
    [request parser:nil foundCharacters:kLinkTest];
    [request parser:nil didEndElement:@"link" namespaceURI:nil qualifiedName:nil];
    
    //pubDate
    [request parser:nil didStartElement:@"pubDate" namespaceURI:nil qualifiedName:nil attributes:nil];
    [request parser:nil foundCharacters:kPubDateTest];
    [request parser:nil didEndElement:@"pubDate" namespaceURI:nil qualifiedName:nil];

    //Description
    [request parser:nil didStartElement:@"description" namespaceURI:nil qualifiedName:nil attributes:nil];
    [request parser:nil foundCharacters:kDescriptionTest];
    [request parser:nil didEndElement:@"description" namespaceURI:nil qualifiedName:nil];
    
    //Guid
    [request parser:nil didStartElement:@"guid" namespaceURI:nil qualifiedName:nil attributes:nil];
    [request parser:nil foundCharacters:kGuidTest];
    [request parser:nil didEndElement:@"guid" namespaceURI:nil qualifiedName:nil];

    //media:content
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:kImageURLTest forKey:kImageURL];
    [attributes setObject:kImagewidthTest forKey:kImageWidth];
    [attributes setObject:kImageHeightTest forKey:kImageHeight];
    [request parser:nil didStartElement:@"media:content" namespaceURI:nil qualifiedName:nil attributes:attributes];

    //End item
    [request parser:nil didEndElement:@"item" namespaceURI:nil qualifiedName:nil];

    //At this point our dictionary should have all the elements we need.
    //Grab the dictionary (we can't do this in a release build)
    NSDictionary* itemFields = [request getDictionary];
    
    //Check title
    NSString* value = [itemFields objectForKey:kTitle];
    XCTAssertTrue([value isEqualToString:kTitleTest]);
    
    //Link
    value = [itemFields objectForKey:kLink];
    NSMutableString* linkString = [NSMutableString stringWithString:kLinkTest];
    [linkString appendString:kLinkSuffix];
    XCTAssertTrue([value isEqualToString:(NSString*)linkString]);
    
    //pubDate
    value = [itemFields objectForKey:kPubDate];
    XCTAssertTrue([value isEqualToString:kPubDateTest]);

    //Description
    value = [itemFields objectForKey:kDescription];
    XCTAssertTrue([value isEqualToString:kDescriptionTest]);

    //guid
    value = [itemFields objectForKey:kGUID];
    XCTAssertTrue([value isEqualToString:kGuidTest]);

    //media:content
    value = [itemFields objectForKey:kImageURL];
    XCTAssertTrue([value isEqualToString:kImageURLTest]);
    
    value = [itemFields objectForKey:kImageHeight];
    XCTAssertTrue([value isEqualToString:kImageHeightTest]);
    
    value = [itemFields objectForKey:kImageWidth];
    XCTAssertTrue([value isEqualToString:kImagewidthTest]);
}

@end

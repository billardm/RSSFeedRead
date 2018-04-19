//
//  RSSRequest.h
//  RSSFeedRead
//
//  Created by Michael Billard on 4/16/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#pragma mark - Constants
extern NSString* const kLinkSuffix;
extern NSString* const kImageURL;
extern NSString* const kImageHeight;
extern NSString* const kImageWidth;
extern NSString* const kDescription;
extern NSString* const kPubDate;
extern NSString* const kTitle;
extern NSString* const kGUID;
extern NSString* const kLink;

@protocol RSSRequestDelegate;

/**
 The RSSRequest object handles making an RSS feed request to the supplied URL and parsing the results into RSSItem objects.
*/
@interface RSSRequest : NSObject <NSXMLParserDelegate>

///Delegate to receive feedback from the RSSRequest.
@property (nullable, assign) id <RSSRequestDelegate> delegate;
@property (nonatomic, readwrite) NSPersistentContainer* persistentContainer;

/**
 This method initializes the RSS request with a string containing the URL to obtain RSS data from.
 - Parameter urlString: an NSString containing the URL to get RSS data from.
 - Returns: An instance of RSSRequest.
 */
-(instancetype)initWithURLString:(NSString*)urlString;

/**
 This method requests RSS data from the supplied URL.
 - Parameter urlString: an NSString containing the URL to get RSS data from.
*/
-(void)requestDataWithURLString:(NSString*)urlString;

/*
 This method instructs the RSSRequest to refresh its RSS data from an existing URL. The results of the request will be delivered through the RSSRequestDelegate protocol.
*/
-(void)refreshData;

//These are the NSXMLParserDelegate method signatures that we only need for debugging and testing purposes.
#ifdef DEBUG
- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)xmlParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeMap;
-(void) parser:(NSXMLParser *)xmlParser foundCharacters:(NSString *)string;
- (NSDictionary*)getDictionary;
#endif
@end

/**
 This protocol defines the RSSRequestDelegate. It provides feedback regarding the status of the request.
*/
@protocol RSSRequestDelegate
/**
 The RSSRequest has completed, possibly with an error.
 - Parameter request: An RSSRequest that has finished its operation.
 - Parameter error: An NSError with information about what went wrong. Nil if there was no issue.
*/
-(void)request:(RSSRequest*)request completedWithError:(NSError*)error;

/**
 Informs the delegate that the RSSRequest has parsed a new <item> element.
 - Parameter request: An RSSRequest that has finished its operation.
 - Parameter itemDictionary: An NSDictionary containing key-value pairs parsed from the <item> element.
*/
-(void)request:(RSSRequest*)request didParseRSSItem:(NSDictionary*)itemDictionary;
@end


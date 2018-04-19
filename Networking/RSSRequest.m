//
//  RSSRequest.m
//  RSSFeedRead
//
//  Created by Michael Billard on 4/16/18.
//  Copyright © 2018 Sympathetic Software. All rights reserved.
//

#import "RSSRequest.h"

#pragma mark - Constants
NSString* const kLinkSuffix = @"?displayMobileNavigation=0";
NSString* const kImageURL = @"url";
NSString* const kImageHeight = @"height";
NSString* const kImageWidth = @"width";
NSString* const kDescription = @"description";
NSString* const kPubDate = @"pubDate";
NSString* const kTitle = @"title";
NSString* const kGUID = @"guid";
NSString* const kLink = @"link";

//Extension to RSSRequest for housekeeping.
@interface RSSRequest() {
    NSString* urlString;
    NSMutableDictionary* rssItemDictionary;
    NSString* fieldName;
    NSMutableString* fieldValue;
    BOOL parsingRSSItem;
}
@end

@implementation RSSRequest
#pragma mark - Initializers
/**
 This method initializes the RSS request with a string containing the URL to obtain RSS data from.
 - Parameter urlString: an NSString containing the URL to get RSS data from.
 - Returns: An instance of RSSRequest.
 */
-(instancetype)initWithURLString:(NSString*)urlString {
    self = [super init];
    if (self) {
        self->urlString = urlString;
        rssItemDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - API
/**
 This method requests RSS data from the supplied URL.
 - Parameter urlString: an NSString containing the URL to get RSS data from. The results of the request will be delivered through the RSSRequestDelegate protocol.
 */
-(void)requestDataWithURLString:(NSString*)urlString {
    self->urlString = urlString;
    [self refreshData];
}

/*
 This method instructs the RSSRequest to refresh its RSS data from an existing URL. The results of the request will be delivered through the RSSRequestDelegate protocol.
 */
-(void)refreshData {
    //Sanity check: make sure we have a urlString
    if (!urlString) {
        //Flag the error
        
        //Call the delegate
        
        //Done
        return;
    }
    
    //Start parsing. We'll do this on a background thread to avoid tying up the main thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSURL* url = [NSURL URLWithString:self->urlString];
        
        //Setup parser. This will initiate the web request.
        NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        xmlParser.delegate = self;
        xmlParser.shouldResolveExternalEntities = NO;
        
        //Now parse the results and get the error (if any).
        [xmlParser parse];
        NSError* parserError = xmlParser.parserError;
        
        //If there was an error, then log it.
        if (parserError != nil) {
            NSLog(@"Error while making RSS feed request: %@", parserError);
        }
        
        //Call the delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_delegate request:self completedWithError:parserError];
        });
    });
}

#pragma mark - NSXMLParserDelegate
- (void) parserDidStartDocument:(NSXMLParser *)xmlParser {
    NSLog(@"parserDidStartDocument");
}

- (void) parserDidEndDocument:(NSXMLParser *)xmlParser {
    NSLog(@"parserDidEndDocument");
}

- (void)parser:(NSXMLParser *)xmlParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeMap {
    NSString* elementNameLower = [elementName lowercaseString];
    if ([elementNameLower isEqualToString:@"item"]) {
        //Clear all items in the dictionary
        rssItemDictionary = [[NSMutableDictionary alloc] init];
        
        //Set parsing flag
        parsingRSSItem = YES;
        
    //We're only interested in Item elements. Skip any that aren't part of an Item element.
    } else if (parsingRSSItem) {
        //Record the element
        fieldName = [[NSString alloc] initWithString:elementName];
    }
    
    //The media:content element contains the information we need for the image. It is contained in the attributeMap.
    NSString* attributeValue = nil;
    if ([elementNameLower isEqualToString:@"media:content"] && parsingRSSItem) {
        attributeValue = [attributeMap objectForKey:kImageURL];
        if (attributeValue != nil) {
            [rssItemDictionary setObject:attributeValue forKey:kImageURL];
        }
        attributeValue = [attributeMap objectForKey:kImageHeight];
        if (attributeValue != nil) {
            [rssItemDictionary setObject:attributeValue forKey:kImageHeight];
        }
        attributeValue = [attributeMap objectForKey:kImageWidth];
        if (attributeValue != nil) {
            [rssItemDictionary setObject:attributeValue forKey:kImageWidth];
        }
    }
}

- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //Close out the RSS item and inform the delegate.
    if ([[elementName lowercaseString] isEqualToString:@"item"]) {
        //Tell the delegate that we have a new item
        [_delegate request:self didParseRSSItem:rssItemDictionary];

        //Set parsing flag
        parsingRSSItem = NO;
    } else if (parsingRSSItem) {
        //link node: append ?displayMobileNavigation=0
        if ([[elementName lowercaseString] isEqualToString:@"link"]) {
            [fieldValue appendString:kLinkSuffix];
        }
        
        //Trim the newline and tab characters by replacing them with whitespace.
        //Otherwise, our title and descriptions won't show up due to leading newline and tab characters.
        [fieldValue replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, [fieldValue length])];
        [fieldValue replaceOccurrencesOfString:@"\t" withString:@" " options:0 range:NSMakeRange(0, [fieldValue length])];
        [fieldValue replaceOccurrencesOfString:@"\t1" withString:@" " options:0 range:NSMakeRange(0, [fieldValue length])];
        
        //Now trim the whitespace
        NSString* trimmedString = [fieldValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

        //Record the element
        [rssItemDictionary setValue:trimmedString forKey:fieldName];

        //Clear the value so we're ready for the next element.
        fieldValue = nil;
    }
}

-(void) parser:(NSXMLParser *)xmlParser foundCharacters:(NSString *)string {
    //Make sure we have something to set.
    if (string == nil) {
        return;
    }

    //Create the value string if needed
    if (fieldValue == nil) {
        fieldValue = [[NSMutableString alloc] initWithString:string];
    } else {
        [fieldValue appendString:string];
    }
}

#pragma mark - Helpers
#ifdef DEBUG
- (NSDictionary*)getDictionary {
    return rssItemDictionary;
}
#endif
@end

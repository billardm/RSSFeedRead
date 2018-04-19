//
//  RSSItem+CoreDataProperties.m
//  
//
//  Created by Michael Billard on 4/19/18.
//
//  This file was automatically generated and should not be edited.
//

#import "RSSItem+CoreDataProperties.h"

@implementation RSSItem (CoreDataProperties)

+ (NSFetchRequest<RSSItem *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"RSSItem"];
}

@dynamic guid;
@dynamic imageHeight;
@dynamic imageURL;
@dynamic imageWidth;
@dynamic link;
@dynamic pubDate;
@dynamic summary;
@dynamic title;

@end

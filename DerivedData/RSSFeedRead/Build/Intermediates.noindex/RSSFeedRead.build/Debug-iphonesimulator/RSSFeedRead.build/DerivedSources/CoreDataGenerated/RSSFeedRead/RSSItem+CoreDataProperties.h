//
//  RSSItem+CoreDataProperties.h
//  
//
//  Created by Michael Billard on 4/19/18.
//
//  This file was automatically generated and should not be edited.
//

#import "RSSItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RSSItem (CoreDataProperties)

+ (NSFetchRequest<RSSItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *guid;
@property (nonatomic) int32_t imageHeight;
@property (nullable, nonatomic, copy) NSString *imageURL;
@property (nonatomic) int32_t imageWidth;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *pubDate;
@property (nullable, nonatomic, copy) NSString *summary;
@property (nullable, nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END

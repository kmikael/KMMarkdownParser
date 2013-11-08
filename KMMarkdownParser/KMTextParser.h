//
//  KMTextParser.h
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 08/11/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSAttributedString * (^KMTextParserProcessingBlock)(NSArray *results);

@interface KMTextParser : NSObject

+ (KMTextParser *)sequence:(NSArray *)textParsers;

+ (KMTextParser *)textParserWithPattern:(NSString *)pattern processingBlock:(KMTextParserProcessingBlock)processingBlock;
+ (KMTextParser *)textParserWithOpeningDelimiter:(NSString *)openingDelimiter closingDelimiter:(NSString *)closingDelimiter attributes:(NSDictionary *)attributes;
+ (KMTextParser *)textParserWithDelimiter:(NSString *)delimiter attributes:(NSDictionary *)attributes;

@property (copy, nonatomic, readonly) NSArray *textParsers;

@property (copy, nonatomic, readonly) NSString *pattern;
@property (copy, nonatomic, readonly) KMTextParserProcessingBlock processingBlock;

@end

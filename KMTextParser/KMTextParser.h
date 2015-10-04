//
//  KMTextParser.h
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 08/11/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NSArray * _Nonnull (^KMTextParserProcessingBlock)(NSArray *results);

@interface KMTextParser : NSObject

/** Creates a text parser that chains a collection of parser sequentially. */
+ (KMTextParser *)sequence:(NSArray *)textParsers;

/** Creates a text parser with the specified pattern and processing block. */
+ (KMTextParser *)textParserWithPattern:(NSString *)pattern processingBlock:(KMTextParserProcessingBlock)processingBlock;

/** Creates a text parser with the specified opening and closing delimiters, as weel as the specified attributes. */
+ (KMTextParser *)textParserWithOpeningDelimiter:(NSString *)openingDelimiter closingDelimiter:(NSString *)closingDelimiter attributes:(NSDictionary *)attributes;

/** Creates a text parser with the specified delimiters, as weel as the specified attributes. */
+ (KMTextParser *)textParserWithDelimiter:(NSString *)delimiter attributes:(NSDictionary *)attributes;

/** Returns an attributed string after (recursively) applying all the given attributes to the string. */
- (NSAttributedString *)attributedStringFromString:(NSString *)string;

/** The text parsers that the text parser was created with by calling `sequence`. */
@property (copy, nonatomic, readonly, nullable) NSArray *textParsers;

/** The text parser's pattern. */
@property (copy, nonatomic, readonly, nullable) NSString *pattern;

/** The text parser's processing block. */
@property (copy, nonatomic, readonly, nullable) KMTextParserProcessingBlock processingBlock;

/** The font name for the attributed string to be produced. */
@property (strong, nonatomic) NSString *fontName;

/** The point size for the attributed string to be produced. */
@property (assign, nonatomic) CGFloat fontSize;

@end

NS_ASSUME_NONNULL_END

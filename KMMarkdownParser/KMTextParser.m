//
//  KMTextParser.m
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 08/11/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "KMTextParser.h"

@implementation KMTextParser

- (instancetype)initWithTextParsers:(NSArray *)textParsers
{
    self = [super init];
    if (self) {
        _textParsers = textParsers;
    }
    return self;
}

- (instancetype)initWithPattern:(NSString *)pattern processingBlock:(KMTextParserProcessingBlock)processingBlock;
{
    self = [super init];
    if (self) {
        _processingBlock = processingBlock;
        _pattern = pattern;
    }
    return self;
}

+ (KMTextParser *)sequence:(NSArray *)textParsers
{
    return [[self alloc] initWithTextParsers:textParsers];
}

+ (KMTextParser *)textParserWithPattern:(NSString *)pattern processingBlock:(KMTextParserProcessingBlock)processingBlock;
{
    return [[self alloc] initWithPattern:pattern processingBlock:processingBlock];
}

+ (KMTextParser *)textParserWithOpeningDelimiter:(NSString *)openingDelimiter closingDelimiter:(NSString *)closingDelimiter attributes:(NSDictionary *)attributes
{
    NSString *escapedOpeningDelimiter = [NSRegularExpression escapedPatternForString:openingDelimiter];
    NSString *escapedClosingDelimiter = [NSRegularExpression escapedPatternForString:closingDelimiter];
    NSString *pattern = [NSString stringWithFormat:@"(%@)(.+?)(%@)", escapedOpeningDelimiter, escapedClosingDelimiter];
    
    KMTextParserProcessingBlock processingBlock = ^ NSAttributedString * (NSArray *results) {
        NSString *replacementString = [results objectAtIndex:2];
        return [[NSAttributedString alloc] initWithString:replacementString attributes:attributes];
    };
    
    return [KMTextParser textParserWithPattern:pattern processingBlock:processingBlock];
}

+ (KMTextParser *)textParserWithDelimiter:(NSString *)delimiter attributes:(NSDictionary *)attributes
{
    return [KMTextParser textParserWithOpeningDelimiter:delimiter closingDelimiter:delimiter attributes:attributes];
}

@end

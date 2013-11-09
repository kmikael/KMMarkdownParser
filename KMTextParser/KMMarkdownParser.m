//
//  KMMarkdownParser.m
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 08/11/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "KMMarkdownParser.h"

@implementation KMMarkdownParser

- (NSArray *)textParsers
{
    NSMutableArray *textParsers = [NSMutableArray array];
    
    // Merge the client properties into the default ones and create the normal font
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:self.fontName size:self.fontSize];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:fontDescriptor.pointSize];
    
    // Bold text: `**`
    UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *boldFont = [UIFont fontWithDescriptor:boldFontDescriptor size:fontDescriptor.pointSize];
    NSDictionary *boldAttributes = @{NSFontAttributeName: boldFont};
    
    KMTextParser *boldMarkdownParser = [KMTextParser textParserWithDelimiter:@"**" attributes:boldAttributes];
    [textParsers addObject:boldMarkdownParser];
    
    // Italic text: `*`
    UIFontDescriptor *italicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFont *italicFont = [UIFont fontWithDescriptor:italicFontDescriptor size:fontDescriptor.pointSize];
    NSDictionary *italicAttributes = @{NSFontAttributeName: italicFont};
    
    KMTextParser *italicMarkdownParser = [KMTextParser textParserWithDelimiter:@"*" attributes:italicAttributes];
    [textParsers addObject:italicMarkdownParser];
    
    // Underlined text: `_`
    NSDictionary *underlineAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSFontAttributeName: font};
    
    KMTextParser *underlineMarkdownParser = [KMTextParser textParserWithDelimiter:@"_" attributes:underlineAttributes];
    [textParsers addObject:underlineMarkdownParser];
    
    // Monospace text: `\``
    // iOS only has two monospace fonts by default: Courier and AmericanTypewriter
    UIFont *monospaceFont = [UIFont fontWithName:@"Courier" size:font.pointSize];
    NSDictionary *monospaceAttributes = @{NSFontAttributeName: monospaceFont};
    
    KMTextParser *monospaceMarkdownParser = [KMTextParser textParserWithDelimiter:@"`" attributes:monospaceAttributes];
    [textParsers addObject:monospaceMarkdownParser];
    
    // URLs: `<...>`
    KMTextParserProcessingBlock URLProcessingBlock = ^ NSAttributedString * (NSArray *results) {
        NSString *URLString = [results objectAtIndex:2];
        NSDictionary *attributes = @{NSLinkAttributeName: URLString, NSFontAttributeName: font};
        return [[NSAttributedString alloc] initWithString:URLString attributes:attributes];
    };
    NSString *URLPattern = @"(<)(.+?)(>)";
    
    KMTextParser *URLMarkdownParser = [KMTextParser textParserWithPattern:URLPattern processingBlock:URLProcessingBlock];
    [textParsers addObject:URLMarkdownParser];
    
    // Headers: `#`, `##`, etc.
    NSString *headerPattern = @"(#+)( ?)(.+?)(\n)";
    KMTextParserProcessingBlock headerProcessingBlock = ^ NSAttributedString * (NSArray *results) {
        NSString *hashes = [results objectAtIndex:1];
        NSUInteger hashCount = [hashes length];
        NSString *headerString = [results objectAtIndex:3];
        
        CGFloat size = boldFontDescriptor.pointSize + 24 - 6 * MIN(hashCount, 4);
        UIFont *headerFont = [UIFont fontWithDescriptor:boldFontDescriptor size:size];
        
        CGFloat baselineOffset = 10.0 - MAX(hashCount, 4);
        
        NSDictionary *attributes = @{NSFontAttributeName: headerFont, NSBaselineOffsetAttributeName: @(baselineOffset)};
        return [[NSAttributedString alloc] initWithString:headerString attributes:attributes];
    };
    
    KMTextParser *headerMarkdownParser = [KMTextParser textParserWithPattern:headerPattern processingBlock:headerProcessingBlock];
    [textParsers addObject:headerMarkdownParser];
    
    // URLs: `[...](...)`
    NSString *URLPattern_ = @"(\\[)(.+?)(])(\\()(.+?)(\\))";
    KMTextParserProcessingBlock URLProcessingBlock_ = ^ NSAttributedString * (NSArray *results) {
        NSString *URLString = [results objectAtIndex:5];
        NSDictionary *attributes = @{NSLinkAttributeName: URLString, NSFontAttributeName: font};
        NSString *replacementString = [results objectAtIndex:2];
        return [[NSAttributedString alloc] initWithString:replacementString attributes:attributes];
    };
    
    KMTextParser *URLMarkdownParser_ = [KMTextParser textParserWithPattern:URLPattern_ processingBlock:URLProcessingBlock_];
    [textParsers addObject:URLMarkdownParser_];
    
    return [NSArray arrayWithArray:textParsers];
}

@end

//
//  KMTextParser.m
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 08/11/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "KMTextParser.h"

@interface KMTextParser ()

@property (strong, nonatomic) NSMutableAttributedString *attributedString;
@property (strong, nonatomic) UIFont *font;

@end

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
    
    KMTextParserProcessingBlock processingBlock = ^ NSArray * (NSArray *results) {
        NSString *replacementString = [results objectAtIndex:2];
        return @[replacementString, attributes];
    };
    
    return [KMTextParser textParserWithPattern:pattern processingBlock:processingBlock];
}

+ (KMTextParser *)textParserWithDelimiter:(NSString *)delimiter attributes:(NSDictionary *)attributes
{
    return [KMTextParser textParserWithOpeningDelimiter:delimiter closingDelimiter:delimiter attributes:attributes];
}

#pragma mark -

- (UIFont *)font
{
    if (!_font) {
        // Merge the client properties into the default ones
        UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:self.fontName size:self.fontSize];
        _font = [UIFont fontWithDescriptor:fontDescriptor size:fontDescriptor.pointSize];
    }
    
    return _font;
}

#pragma mark -

- (NSAttributedString *)attributedStringFromString:(NSString *)string
{
    _attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    // The full range of the string
    NSUInteger length = [_attributedString length];
    NSRange range = NSMakeRange(0u, length);
    
    // Apply the font to the whole string
    [_attributedString addAttribute:NSFontAttributeName value:self.font range:range];
    
    NSArray *textParsers = [self flattenedTextParsers];
    
    if ([textParsers count] > 0) {
        for (KMTextParser *textParser in textParsers) {
            [self commitParser:textParser];
        }
    } else {
        [self commitParser:self];
    }
    
    return [[NSAttributedString alloc] initWithAttributedString:_attributedString];
}

#pragma mark -

/** Recursively flattens the `textParsers` array. */
- (NSArray *)flattenedTextParsers
{
    NSArray *textParsers = self.textParsers;
    NSUInteger capacity = [textParsers count];
    NSMutableArray *flattenedTextParsers = [NSMutableArray arrayWithCapacity:capacity];
    
    for (KMTextParser *textParser in textParsers) {
        if (textParser.textParsers) {
            [flattenedTextParsers addObjectsFromArray:[textParser flattenedTextParsers]];
        } else {
            [flattenedTextParsers addObject:textParser];
        }
    }
    
    return flattenedTextParsers;
}

/** Apply the attributes returned by attributesBlock to the search pattern */
- (void)commitParser:(KMTextParser *)textParser
{
    // The full range of the string
    NSUInteger length = [_attributedString length];
    NSRange range = NSMakeRange(0u, length);
    
    // The ranges (wraped as NSValue objects) of the matches
    NSMutableArray *values = [NSMutableArray array];
    
    // The replacement strings, each match's full text is replaced with this string
    NSMutableArray *replacementStrings = [NSMutableArray array];
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:textParser.pattern options:0 error:NULL];
    
    // Enumerate the matches,
    NSString *string = [_attributedString string];
    [regularExpression enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSMutableArray *results = [NSMutableArray array];
        for (NSUInteger index = 0; index < result.numberOfRanges; ++index) {
            NSRange range = [result rangeAtIndex:index];
            NSString *substring = [string substringWithRange:range];
            [results addObject:substring];
        }
        
        NSArray *components = textParser.processingBlock(results);
        NSString *replacementString = [components firstObject];
        NSDictionary *attributes = [components lastObject];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:replacementString attributes:attributes];
        
        // Use the default font if one hasn't been specified
        if (![attributes objectForKey:NSFontAttributeName]) {
            NSUInteger length = [attributedString length];
            NSRange range = NSMakeRange(0u, length);
            [attributedString addAttribute:NSFontAttributeName value:self.font range:range];
        }
        
        // and save the rages of the full matches and the replacements
        [values addObject:[NSValue valueWithRange:result.range]];
        [replacementStrings addObject:attributedString];
    }];
    
    NSUInteger locationOffset = 0;
    
    // Iterate over the range values and replace those characters with the replacement string
    for (NSUInteger index = 0; index < [values count]; ++index) {
        // Unbox the range
        NSRange range = [[values objectAtIndex:index] rangeValue];
        
        // Apply the offset
        range.location += locationOffset;
        
        NSAttributedString *replacementString = [replacementStrings objectAtIndex:index];
        
        [_attributedString replaceCharactersInRange:range withAttributedString:replacementString];
        
        locationOffset = locationOffset - range.length + [replacementString length];
    }
}

@end

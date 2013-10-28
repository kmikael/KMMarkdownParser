//
//  KMMarkdownParser.m
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 17/10/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "KMMarkdownParser.h"

@implementation KMMarkdownParser
{
    // The attributed string that will be processed into the result
    NSMutableAttributedString *_attributedString;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Default to the system body text style
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _fontName = font.fontName;
        _fontSize = font.pointSize;
    }
    return self;
}

- (NSAttributedString *)attributedStringFromMarkdownString:(NSString *)markdownString
{
    _attributedString = [[NSMutableAttributedString alloc] initWithString:markdownString];
    
    // Merge the client properties into the default ones and create the normal font
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:self.fontName size:self.fontSize];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:fontDescriptor.pointSize];
    
    NSUInteger length = [_attributedString length];
    NSRange range = NSMakeRange(0u, length);
    
    // Apply the font to the whole string
    [_attributedString addAttribute:NSFontAttributeName value:font range:range];
    
    // Apply bold styling to words wraped with `**`
    UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *boldFont = [UIFont fontWithDescriptor:boldFontDescriptor size:fontDescriptor.pointSize];
    NSDictionary *boldAttributes = @{NSFontAttributeName: boldFont};
    [self commitAttributes:boldAttributes delimiter:@"**"];
    
    // Apply italic styling to words wraped with `*`
    UIFontDescriptor *italicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFont *italicFont = [UIFont fontWithDescriptor:italicFontDescriptor size:fontDescriptor.pointSize];
    NSDictionary *italicAttributes = @{NSFontAttributeName: italicFont};
    [self commitAttributes:italicAttributes delimiter:@"*"];
    
    // Underline words wraped with `_`
    NSDictionary *underlineAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSFontAttributeName: font};
    [self commitAttributes:underlineAttributes delimiter:@"_"];
    
    // Apply monospace styling to words wraped with `\``
    // iOS only has two monospace fonts by default: Courier and AmericanTypewriter
    UIFont *monospaceFont = [UIFont fontWithName:@"Courier" size:font.pointSize];
    NSDictionary *monospaceAttributes = @{NSFontAttributeName: monospaceFont};
    [self commitAttributes:monospaceAttributes delimiter:@"`"];
    
    // Apply link styling to URLs wrapped in `<` and `>`
    NSString *escapedOpeningDelimiter = [NSRegularExpression escapedPatternForString:@"<"];
    NSString *escapedClosingDelimiter = [NSRegularExpression escapedPatternForString:@">"];
    NSString *URLPattern = [NSString stringWithFormat:@"(%@)(.+?)(%@)", escapedOpeningDelimiter, escapedClosingDelimiter];
    NSDictionary * (^block)(NSArray *) = ^ NSDictionary * (NSArray *results) {
        NSString *URLString = [results objectAtIndex:2];
        NSDictionary *attributes = @{NSLinkAttributeName: URLString, NSFontAttributeName: font};
        return @{@"attributes": attributes, @"replacement": URLString};
    };
    [self commitAttributesBlock:block pattern:URLPattern];
    
    // Apply big, bold styling to lines starting with `#`, `##`, etc.
    NSString *headerPattern = @"(#+)( ?)(.+?)(\n)";
    block = ^ NSDictionary * (NSArray *results) {
        NSString *hashes = [results objectAtIndex:1];
        NSUInteger hashCount = [hashes length];
        NSString *headerString = [results objectAtIndex:3];
        
        CGFloat size = boldFontDescriptor.pointSize + 24 - 6 * MIN(hashCount, 4);
        UIFont *headerFont = [UIFont fontWithDescriptor:boldFontDescriptor size:size];
        
        CGFloat baselineOffset = 10.0 - MAX(hashCount, 4);
        
        NSDictionary *attributes = @{NSFontAttributeName: headerFont, NSBaselineOffsetAttributeName: @(baselineOffset)};
        return @{@"attributes": attributes, @"replacement": headerString};
    };
    [self commitAttributesBlock:block pattern:headerPattern];
    
    // Apply link styling with title text
    NSString *linkPattern = @"(\\[)(.+?)(])(\\()(.+?)(\\))";
    block = ^ NSDictionary * (NSArray *results) {
        NSString *URLString = [results objectAtIndex:5];
        NSDictionary *attributes = @{NSLinkAttributeName: URLString, NSFontAttributeName: font};
        NSString *replacement = [results objectAtIndex:2];
        return @{@"attributes": attributes, @"replacement": replacement};
    };
    [self commitAttributesBlock:block pattern:linkPattern];
    
    return _attributedString;
}

/** Apply the attributes returned by attributesBlock to the search pattern */
- (void)commitAttributesBlock:(NSDictionary * (^)(NSArray *results))attributesBlock pattern:(NSString *)pattern
{
    // The full range of the string
    NSUInteger length = [_attributedString length];
    NSRange range = NSMakeRange(0u, length);
    
    // The ranges (wraped as NSValue objects) of the matches
    NSMutableArray *values = [NSMutableArray array];
    
    // The replacement strings, each match's full text is replaced with this string
    NSMutableArray *replacements = [NSMutableArray array];
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    
    // Enumerate the matches,
    NSString *string = [_attributedString string];
    [regularExpression enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSMutableArray *results = [NSMutableArray array];
        for (NSUInteger index = 0; index < result.numberOfRanges; ++index) {
            NSRange range = [result rangeAtIndex:index];
            NSString *substring = [string substringWithRange:range];
            [results addObject:substring];
        }
        
        NSDictionary *parser = attributesBlock(results);
        NSDictionary *attributes = [parser objectForKey:@"attributes"];
        NSString *replacementString = [parser objectForKey:@"replacement"];
        NSAttributedString *replacement = [[NSAttributedString alloc] initWithString:replacementString attributes:attributes];
        
        // and save the rages of the full matches and the replacements
        [values addObject:[NSValue valueWithRange:result.range]];
        [replacements addObject:replacement];
    }];
    
    NSUInteger locationOffset = 0;
    
    // Iterate over the range values and replace those characters with the replacement string
    for (NSUInteger index = 0; index < [values count]; ++index) {
        // Unbox the range
        NSRange range = [[values objectAtIndex:index] rangeValue];
        
        // Update the range to accommodate for shifting, because characters were deleted/added in previous loops iterations
        range.location += locationOffset;
        
        NSAttributedString *replacementString = [replacements objectAtIndex:index];
        
        [_attributedString replaceCharactersInRange:range withAttributedString:replacementString];

        locationOffset = locationOffset - range.length + [replacementString length];
    }
}

/** Applies the `attributes` to words delimited by `openingDelimiter` and `closingDelimiter` */
- (void)commitAttributes:(NSDictionary *)attributes openingDelimiter:(NSString *)openingDelimiter closingDelimiter:(NSString *)closingDelimiter
{
    // Escape the delimiter and create the regular expression, with 3 capture groups
    // 1. The opening delimiter
    // 2. The wrapped words
    // 3. The closing delimiter
    NSString *escapedOpeningDelimiter = [NSRegularExpression escapedPatternForString:openingDelimiter];
    NSString *escapedClosingDelimiter = [NSRegularExpression escapedPatternForString:closingDelimiter];
    NSString *pattern = [NSString stringWithFormat:@"(%@)(.+?)(%@)", escapedOpeningDelimiter, escapedClosingDelimiter];
    
    NSDictionary * (^block)(NSArray *) = ^ NSDictionary * (NSArray *results) {
        NSString *replacement = [results objectAtIndex:2];
        return @{@"attributes": attributes, @"replacement": replacement};
    };
    
    [self commitAttributesBlock:block pattern:pattern];
}

/** Applies the `attributes` to words delimited by `delimiter` */
- (void)commitAttributes:(NSDictionary *)attributes delimiter:(NSString *)delimiter
{
    [self commitAttributes:attributes openingDelimiter:delimiter closingDelimiter:delimiter];
}

@end

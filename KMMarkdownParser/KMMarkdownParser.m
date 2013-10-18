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
    NSDictionary *underlineAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    [self commitAttributes:underlineAttributes delimiter:@"_"];
    
    // Apply monospace styling to words wraped with `\``
    // iOS only has two monospace fonts by default: Courier and AmericanTypewriter
    UIFont *monospaceFont = [UIFont fontWithName:@"Courier" size:font.pointSize];
    NSDictionary *monospaceAttributes = @{NSFontAttributeName: monospaceFont};
    [self commitAttributes:monospaceAttributes delimiter:@"`"];
    
    NSDictionary *attributes = @{NSLinkAttributeName: @""};
    [self commitAttributes:attributes openingDelimiter:@"<" closingDelimiter:@">"];
    
    return _attributedString;
}

/** Applies the `attributes` to words delimited by `openingDelimiter` and `closingDelimiter` */
- (void)commitAttributes:(NSDictionary *)attributes openingDelimiter:(NSString *)openingDelimiter closingDelimiter:(NSString *)closingDelimiter
{
    // The full range of the string
    NSUInteger length = [_attributedString length];
    NSRange range = NSMakeRange(0u, length);
    
    // The ranges (wraped as NSValue objects) of the delimiter characters that will be deleted
    NSMutableArray *values = [NSMutableArray array];
    
    // Escape the delimiter and create the regular expression, with 3 capture groups
    // 1. The opening delimiter
    // 2. The wrapped words
    // 3. The closing delimiter
    NSString *escapedOpeningDelimiter = [NSRegularExpression escapedPatternForString:openingDelimiter];
    NSString *escapedClosingDelimiter = [NSRegularExpression escapedPatternForString:closingDelimiter];
    NSString *pattern = [NSString stringWithFormat:@"(%@)(.+?)(%@)", escapedOpeningDelimiter, escapedClosingDelimiter];
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    
    // Enumerate the matches,
    NSString *string = [_attributedString string];
    [regularExpression enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (attributes[NSLinkAttributeName]) {
            // `NSLinkAttributeName` is a special case because the attributes depend on the matched string
            NSRange URLRange = [result rangeAtIndex:2];
            NSString *URLString = [[_attributedString string] substringWithRange:URLRange];
            [_attributedString addAttribute:NSLinkAttributeName value:URLString range:result.range];
        } else {
            [_attributedString addAttributes:attributes range:result.range];
        }
        
        // and save the rages of the opening and closing delimiters
        [values addObject:[NSValue valueWithRange:[result rangeAtIndex:1]]];
        [values addObject:[NSValue valueWithRange:[result rangeAtIndex:3]]];
    }];
    
    // Iterate over the range values and delete those characters
    for (NSUInteger index = 0u; index < [values count]; index += 1) {
        // Update the range to accommodate for the shifting ranges
        // (because characters were deleted in previous loops iterations)
        NSRange range = [[values objectAtIndex:index] rangeValue];
        range.location -= index * [openingDelimiter length];
        [_attributedString deleteCharactersInRange:range];
        index++;
        range = [[values objectAtIndex:index] rangeValue];
        range.location -= index * [closingDelimiter length];
        [_attributedString deleteCharactersInRange:range];
    }
}

/** Applies the `attributes` to words delimited by `delimiter` */
- (void)commitAttributes:(NSDictionary *)attributes delimiter:(NSString *)delimiter
{
    [self commitAttributes:attributes openingDelimiter:delimiter closingDelimiter:delimiter];
}

@end

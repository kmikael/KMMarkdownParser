//
//  KMMarkdownParser.h
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 17/10/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * KMMarkdownParser will take a plain text markdown string and produce an NSAttributedString.
 * The span elements bold (**), italic (*), underline (_), monospace (`) and link (<, >) are supported.
 * If given, the produced attributed string will use `self.fontName` and `self.fontSize`,
 * otherwise the system default font and body text size will be used.
 */
@interface KMMarkdownParser : NSObject

/** The font name for the attributed string to be produced. */
@property (strong, nonatomic) NSString *fontName;

/** The point size for the attributed string to be produced. */
@property (assign, nonatomic) CGFloat fontSize;

/** Returns an attributed string with the attributes of the markdown string. */
- (NSAttributedString *)attributedStringFromMarkdownString:(NSString *)markdownString;

@end

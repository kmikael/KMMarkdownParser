//
//  KMMarkdownParser.h
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 08/11/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "KMTextParser.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * KMMarkdownParser will take a plain text markdown string and produce an NSAttributedString.
 * The span elements bold (**), italic (*), underline (_), monospace (`) and link (<, >) are supported.
 * If given, the produced attributed string will use `self.fontName` and `self.fontSize`,
 * otherwise the system default font and body text size will be used.
 */
@interface KMMarkdownParser : KMTextParser

@end

NS_ASSUME_NONNULL_END

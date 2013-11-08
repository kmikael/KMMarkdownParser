//
//  KMMarkdownParser.h
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 08/11/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "KMTextParser.h"

@interface KMMarkdownParser : KMTextParser

/** The font name for the attributed string to be produced. */
@property (strong, nonatomic) NSString *fontName;

/** The point size for the attributed string to be produced. */
@property (assign, nonatomic) CGFloat fontSize;

@end

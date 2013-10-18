//
//  MVViewController.m
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 17/10/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "MVViewController.h"
#import "KMMarkdownParser.h"

@interface MVViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) KMMarkdownParser *markdownParser;

@end

@implementation MVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"Metamorphosis" withExtension:@"txt"];
    NSString *markdownString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL];
    self.textView.attributedText = [self.markdownParser attributedStringFromMarkdownString:markdownString];
}

#pragma mark -

- (KMMarkdownParser *)markdownParser
{
    if (!_markdownParser) {
        // Lazily instantiate the markdown parser
        _markdownParser = [[KMMarkdownParser alloc] init];
        // and set a font and size to be used
        _markdownParser.fontName = @"AvenirNext-Regular";
        _markdownParser.fontSize = 20.0;
    }
    
    return _markdownParser;
}

@end

//
//  MVViewController.m
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 17/10/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "MVViewController.h"
#import "KMTextProcessor.h"

@interface MVViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) KMTextProcessor *textProcessor;

@end

@implementation MVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"Metamorphosis" withExtension:@"txt"];
    NSString *markdownString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL];
    self.textView.attributedText = [self.textProcessor attributedStringFromMarkdownString:markdownString];
}

#pragma mark -

- (KMTextProcessor *)textProcessor
{
    if (!_textProcessor) {
        // Lazily instantiate the markdown parser
        _textProcessor = [[KMTextProcessor alloc] init];
        // and set a font and size to be used
        _textProcessor.fontName = @"AvenirNext-Regular";
        _textProcessor.fontSize = 20.0;
    }
    
    return _textProcessor;
}

@end

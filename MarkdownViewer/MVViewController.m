//
//  MVViewController.m
//  MarkdownViewer
//
//  Created by Mikael Konutgan on 17/10/13.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "MVViewController.h"
#import "KMMarkdownParser.h"

@interface MVViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation MVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    KMMarkdownParser *markdownParser = [[KMMarkdownParser alloc] init];
    
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"Metamorphosis" withExtension:@"txt"];
    NSString *string = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL];
    
    self.textView.attributedText = [markdownParser attributedStringFromString:string];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}

@end

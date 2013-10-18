# KMMarkdownParser

`KMMarkdownParser` is a really simple mini-markdown to `NSAttributedString` converter. The span elements bold (**), italic (*), underline (_) and monospace (`) are supported at the moment.

## Usage

```objective-c
KMMarkdownParser markdownParser = [[KMMarkdownParser alloc] init];
markdownParser.fontName = @"AvenirNext-Regular";
markdownParser.fontSize = 20.0;

NSString *markdownString = @"A `markdown` string with **bold** and *italic* and _underlined_ txt.";
self.textView.attributedText = [self.markdownParser attributedStringFromMarkdownString:markdownString];
```

## Example

Here is some markdown:

```no-highlight
**Metamorphosis**

*Franz Kafka*

_Translated by David Wyllie_

**I**

One morning, when *Gregor Samsa* woke from _troubled dreams_, he found himself *transformed* in his bed into **a horrible vermin**. He lay on his armour-like back, and if he lifted his head a little **he could see his brown belly**, slightly domed and divided by arches into stiff sections. The bedding was hardly able to cover it and seemed ready to slide off any moment. **His many legs**, pitifully thin compared with the size of the rest of him, waved about helplessly as he looked.

*"What's happened to me?"* he thought. It wasn't a dream. His room, a proper human room although a little too small, lay peacefully between its four familiar walls. A collection of textile samples lay spread out on the table - *Samsa* was _a travelling salesman_ - and above it there hung a picture that he had recently cut out of an illustrated magazine and housed in a nice, gilded frame. It showed a lady fitted out with a fur hat and fur boa who sat upright, raising a heavy fur muff that covered the whole of her lower arm towards the viewer.

Read the rest at <http://www.gutenberg.org/files/5200/5200-h/5200-h.htm>
```

And here is what it looks like after converted into an `NSAttributedString` using `KMMarkdownParser` and set as the `attributedText` of a `UITextView`:

![](http://f.cl.ly/items/0H401D2t2c3T2p1o0j2g/KMMarkdownParser.png)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

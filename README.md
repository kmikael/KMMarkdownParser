# KMMarkdownParser

`KMMarkdownParser` is a really simple mini-markdown to `NSAttributedString` converter.
The span elements bold (`**`), italic (`*`), underline (`_`), monospace
and links (both the `<url>` and `[title](url)` variants), as well as headers (`#`, `##`, etc.)
are supported at the moment.

## Usage

Create an instance of `KMMarkdownParser`, optionally set a font name and size,
then call `attributedStringFromString:`.
Your `NSAttributedString` is ready for use in a `UILabel`, `UITextView` etc.

```objective-c
KMMarkdownParser markdownParser = [[KMMarkdownParser alloc] init];
markdownParser.fontName = @"AvenirNext-Regular";
markdownParser.fontSize = 20.0;

NSString *markdownString = @"A `markdown` string with **bold** and *italic* text.";
self.textView.attributedText = [markdownParser attributedStringFromString:markdownString];
```

See the example project for more information, the code is extremely well-documented.

## Example

Here is some markdown:

```no-highlight
**Metamorphosis**

*Franz Kafka*

_Translated by David Wyllie_

**I**

One morning, when *Gregor Samsa* woke from _troubled dreams_,
he found himself *transformed* in his bed into **a horrible vermin**.
He lay on his armour-like back, and if he lifted his head a little **he could see his brown belly**,
slightly domed and divided by arches into stiff sections.
The bedding was hardly able to cover it and seemed ready to slide off any moment. **His many legs**,
pitifully thin compared with the size of the rest of him, waved about helplessly as he looked.
```

And here is what it looks like after converted into an `NSAttributedString` using `KMMarkdownParser`
and set as the `attributedText` of a `UITextView`:

![](http://f.cl.ly/items/0H401D2t2c3T2p1o0j2g/KMMarkdownParser.png)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

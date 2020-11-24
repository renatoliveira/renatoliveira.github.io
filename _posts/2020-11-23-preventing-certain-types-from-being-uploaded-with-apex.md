---
layout: post
title: "Preventing certain file types from being uploaded with Apex using magic numbers"
date: 2020-11-23 18:15 -0300
---

Many working with the Lightning framework already know it is possible to prevent certain types of files from being uploaded to the Salesforce org using the `accept` parameter in the "file-input" web component.

It is also possible to prevent certain files from being uploaded with Apex, since they are uploaded as Content files.

It is possible to compare the file extension against a list of permitted files, sure. But one can easily rename an .exe as .pdf and bypass this validation. To check for file signatures in Apex directly from the binary data it one just needs to read the file's Magic Bytes/magic numbers/siginature. This signature is prefixed in the file's binary, and each file type has some default signatures. For example, has the following bytes in its signature: `25 50 44 46 2d`.

To check a file in Salesforce the code needs to read the file's binary. Fortunately, there is the `VersionData` field from the `ContentVersion` object. This blob can be converted to the hexadecimal data that Apex can evaluate using `EncodingUtil`'s method `convertToHex`:

```apex
String hexBody = EncodingUtil.convertToHex(fileContent);
```

With this string, Apex can read the first bytes of the file, which probably contain the file's signature. Then it can extract the first characters to check against available patterns (such as the PDF's). This is recommended because if the file is too long the platform will interpret the expression as too complex to evaluate and the code will fail.

```apex
Matcher m = magicNumberPatern.matcher(hexBody.left(32));
```

Then, if it is a match, the file is OK to upload - or not, if one decides to create a blacklist instead of a whitelist.

> Note: this makes a little trickier to upload unwanted data, but it is still possible to upload other file types.

Sources:

1. https://en.wikipedia.org/wiki/List_of_file_signatures
2. https://asecuritysite.com/forensics/magic

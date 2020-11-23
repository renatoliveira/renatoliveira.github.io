---
layout: post
title: "Preventing certain file types from being uploaded with Apex using magic numbers"
date: 2020-11-23 18:15 -0300
---

Many working with the Lightning framework already know it is possible to prevent certain types of files from being uploaded to the Salesforce org using the `accept` parameter in the "file-input" web component.

It is also possible to prevent certain files from being uploaded with Apex, since they are uploaded as Content files.

It is possible to compare the file extension against a list of permitted files, sure. But one can easily rename an .exe as .pdf and bypass this validation. We can check for file signatures in Apex, directly from the binary data using the file's Magic Bytes/magic numbers/siginature.

This signature is prefixed in the file's binary, and each file type has some default signatures we can work with.

> Note: this makes a little trickier to upload unwanted data, but it is still possible to upload other file types.

A PDF document, for example, has the following bytes in its signature: `25 50 44 46 2d`.

Sources:

1. https://en.wikipedia.org/wiki/List_of_file_signatures
2. https://asecuritysite.com/forensics/magic

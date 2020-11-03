---
layout: post
title: Listing all test methods for a given class using the Salesforce CLI and jq
date: 2020-10-29 19:00 -0300
---

First of all, we can’t query the ApexClass table directly using the IsTestClass field as criteria, because it doesn’t exist. The second problem is that we have differences between managed and unmanaged classes. The later one’s code isn’t accessible, so we can’t just search for the @IsTest annotation.

What do we do, then? Turn into one of Salesforce’s APIs: The Tooling API. It provides us with data that is interesting for a developer developing things for developers. 

Fortunately the Salesforce CLI supports this API. So we can query the ApexClass table using the Tooling API. It can return an object that represents information about the queried class. For example, the following query:

`sfdx force:data:soql:query --query "SELECT Id, SymbolTable FROM ApexClass WHERE Name = 'SObjectUnitOfWorkTest'" --usetoolingapi --targetusername playground --json`

It queries the SObjectUnitOfWorkTest class and its symbol table using the Tooling API for that. Don’t mind the “playground” thing, that’s what I call my personal dev org.

The output of this command should be a JSON of considerable size (depending on the size of the class as well). But we are interested in just one attribute of the response: the “methods” attribute of the SymbolTable attribute. This attribute contains a list of the methods in the class we queried, and the output is something like this:

```json
"methods": [
  {
    "annotations": [
      {
        "name": "IsTest"
      }
    ],
    "location": {
      "column": 25,
      "line": 39
    },
    "modifiers": [
      "private",
      "static",
      "testMethod"
    ],
    "name": "test_inserts",
    "parameters": [],
    "references": [],
    "returnType": "void",
    "type": null
  },
  // and more methods below, if the class contains more than one method
]
```

Using a command line tool like jq we can easily extract the methods annotated with IsTest using a command like this:

`cat test.apxc | jq '.result.records[0].SymbolTable.methods | .[] | select((.annotations | length > 0) and .annotations[0].name == "IsTest")'`

If you just want the methods’ names, the command differs just a bit at the end:

`cat test.apxc | jq '.result.records[0].SymbolTable.methods | .[] | select((.annotations | length > 0) and .annotations[0].name == "IsTest") | .name'`

For the class I used before, I get the following output:

```shell
? cat test.apxc | jq '.result.records[0].SymbolTable.methods | .[] | select((.annotations | length > 0) and .annotations[0].name == "IsTest") | .name'
"test_inserts"
"test_updates"
"testUnitOfWorkEmail"
"testDerivedUnitOfWork_CommitDMLFail"
"testDerivedUnitOfWork_CommitDoWorkFail"
```

And that’s it! A not so easy way of extracting the test methods of a single class. But at least it can be automated.

But what if I want to get the methods for multiple classes at once?
It might take a while to run the query, but Salesforce definitely delivers a result to your terminal. Then the biggest issue is parsing the JSON result. I don’t know how to pretty parse and/or reshape the output using jq alone, but it definitely seems possible! And I’m sure that one can use a scripting language (like Python or PowerShell) to automate this.

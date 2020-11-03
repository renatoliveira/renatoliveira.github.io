---
layout: post
title: "Cannot specify a gender for a gender neutral language” error when creating a new package version using 2GP? 🤔"
date: 2019-11-11 19:00 -0300 
---

Salesforce released Second Generation Packaging (2GP) in this latest platform version (it was in Beta before, but now is GA).

When generating a new package version of your app, if you are not in the US and your language isn’t gender neutral, you might face this little issue when generating a new package version:

```
$ sfdx force:package:version:create --package "My App" --wait 10 -x
Request in progress. Sleeping 30 seconds. Will wait a total of 600 more seconds before timing out. Current Status='Initializing'
Request in progress. Sleeping 30 seconds. Will wait a total of 570 more seconds before timing out. Current Status='Verifying metadata'
ERROR running force:package:version:create:  Object__c: Cannot specify a gender for a gender neutral language
```

It doesn’t tell much, but I know I got confused since my scratch org was created with the language parameter of pt_BR. That was part of my mistake. The other part was that I didn’t specify a definitionFile parameter in my sfdx-project.json file.

Turns out that Salesforce uses another org/worker to create the package. If you don’t specify a definition file, it will use a default org (probably with English from the U.S. as the default). When I specified the same definition file as my current scratch org (which contains the non-English language attribute), I got the package generated without this annoying error!

```
$ sfdx force:package:version:create --package "My App" --wait 10 --installationkey xZmyga9nVhGPQ7aQbu6iNisQU2
Request in progress. Sleeping 30 seconds. Will wait a total of 600 more seconds before timing out. Current Status='Initializing'
Request in progress. Sleeping 30 seconds. Will wait a total of 570 more seconds before timing out. Current Status='Verifying features and settings'
Request in progress. Sleeping 30 seconds. Will wait a total of 540 more seconds before timing out. Current Status='Verifying metadata'
Request in progress. Sleeping 30 seconds. Will wait a total of 510 more seconds before timing out. Current Status='Finalizing package version'
sfdx-project.json has been updated.
Successfully created the package version [08c00000000XXXXAAA]. Subscriber Package Version Id: 04t00000000XXXXAAA
Package Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t00000000XXXXAAA
As an alternative, you can use the "sfdx force:package:install" command.
```

Notice how the definitionFile attribute is market as “not required” on the documentation on unlocked package development. It actually isn’t required on a simple scenario. But with multiple languages this might be required, after all.

Experimenting, getting angry, confused and finally: learning. 😌

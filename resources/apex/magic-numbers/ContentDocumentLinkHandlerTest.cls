@IsTest
private class ContentDocumentLinkHandlerTest {

    @TestSetup
    static void makeData() {
        Account accountRecord = new Account(
          Name = 'Hello world!'
        );
        insert accountRecord;

        Case caseRecord = new Case(
            AccountId = accountRecord.Id
        );
        insert caseRecord;
    }

    @IsTest
    static void testInsertFail() {
        Case caseRecord = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        ContentVersion file = new ContentVersion(
            PathOnClient = 'test.pdf',
          Title = 'test.pdf',
            VersionData = EncodingUtil.base64Decode('hello world')
        );
        insert file;

        file = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :file.Id];

        try {
            insert new ContentDocumentLink(
                LinkedEntityId = caseRecord.Id,
                ShareType = 'V',
                Visibility = 'AllUsers',
                ContentDocumentId = file.ContentDocumentId
            );
            System.assert(false, 'Should NOT have allowed file insertion.');
        } catch (DmlException e) {
            System.assert(true, 'Should NOT have allowed file insertion. - ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testInsertSuccess() {
        String helloWorldSignature = EncodingUtil.convertToHex(EncodingUtil.base64Decode('hello world')).left(8);
        ContentDocumentLinkHandler.extensions.put('.pdf', new List<String>{helloWorldSignature});

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        ContentVersion file = new ContentVersion(
            PathOnClient = 'test.pdf',
          Title = 'test.pdf',
            VersionData = EncodingUtil.base64Decode('hello world')
        );
        insert file;

        file = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :file.Id];

        try {
            insert new ContentDocumentLink(
                LinkedEntityId = caseRecord.Id,
                ShareType = 'V',
                Visibility = 'AllUsers',
                ContentDocumentId = file.ContentDocumentId
            );
            System.assert(true, 'Should have allowed file insertion.');
        } catch (DmlException e) {
            System.assert(false, 'Should have allowed file insertion. - ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testInsertSuccessNotOnCase() {
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        ContentVersion file = new ContentVersion(
            PathOnClient = 'test.pdf',
          Title = 'test.pdf',
            VersionData = EncodingUtil.base64Decode('hello world')
        );
        insert file;

        file = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :file.Id];

        try {
            insert new ContentDocumentLink(
                LinkedEntityId = accountRecord.Id,
                ShareType = 'V',
                Visibility = 'AllUsers',
                ContentDocumentId = file.ContentDocumentId
            );
            System.assert(true, 'Should have allowed file insertion.');
        } catch (DmlException e) {
            System.assert(false, 'Should have allowed file insertion. - ' + e.getMessage());
        }
        Test.stopTest();
    }
}

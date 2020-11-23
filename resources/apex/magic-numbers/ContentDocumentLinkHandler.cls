public inherited sharing class ContentDocumentLinkHandler {

    private static final List<String> CASE_RECORD_TYPES_NAMES = new List<String>{ /* add case's specific record type names here */ };

    @TestVisible
    private static Map<String, List<String>> extensions = new Map<String, List<String>>{
        '.doc' => new List<String>{'D0CF11E0A1B11AE1'},
        '.docx' => new List<String>{'504B0304', '504B0506', '504B0708'},
        '.jpg' => new List<String>{'FFD8FFDB', 'FFD8FFE000104A4649460001'},
        '.jpeg' => new List<String>{'FFD8FFEE', 'FFD8FFE1.{4}457869660000'},
        '.pdf' => new List<String>{'255044462d'}
        };

    public void run() {
        checkFileSignature();
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    private void checkFileSignature() {
        Set<Id> contentDocumentIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        String casePrefix = Schema.Case.getSObjectType().getDescribe().getKeyPrefix();

        for (ContentDocumentLink record : (List<ContentDocumentLink>) Trigger.new) {
            if (String.valueOf(record.LinkedEntityId).startsWith(casePrefix)) {
                caseIds.add(record.LinkedEntityId);
                contentDocumentIds.add(record.ContentDocumentId);
            }
        }

        Map<Id, Case> cases = new Map<Id, Case>([
            SELECT
            Id, RecordType.DeveloperName
            FROM Case
            WHERE Id IN :caseIds
            AND RecordType.DeveloperName IN :CASE_RECORD_TYPES_NAMES
        ]);

        List<Pattern> patterns = new List<Pattern>();

        for (String ext : extensions.keySet()) {
            for (String regex : extensions.get(ext)) {
                patterns.add(Pattern.compile('\\b' + regex.toLowerCase()));
            }
        }

        for (ContentVersion record : [
            SELECT VersionData, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
        ]) {
            Boolean verify = false;
            for (ContentDocumentLink link : (List<ContentDocumentLink>) Trigger.new) {
                verify = (
                    String.valueOf(link.LinkedEntityId).startsWith(casePrefix) &&
                    cases.containsKey(link.LinkedEntityId) &&
                    record.ContentDocumentId == link.ContentDocumentId
                );
                if (verify) {
                    break;
                }
            }

            if (verify) {
                Boolean isValid = false;
                for (Pattern p : patterns) {
                    isValid = isValidFile(p, record.VersionData);
                }
                if (!isValid) {
                    throw new DmlException('Arquivo com extensão inválida.');
                }
            }
        }
    }

    private Boolean isValidFile(Pattern magicNumberPatern, Blob fileContent) {
        String hexBody = EncodingUtil.convertToHex(fileContent);
        Matcher m = magicNumberPatern.matcher(hexBody.left(32));
        System.debug(LoggingLevel.FINE, hexBody.left(32));
        return m.find();
    }
}

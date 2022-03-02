public class ImportToSalesLoft {

    private final List<sObject> selectedRecords;
    private final List<SObject> records;
    private final String importUrlBase = 'https://app.salesloft.com/app/import/crm?';

    private String filterName = '';
    private List<String> selectedRecordIds = new List<String> {};

    public String importUrl { get { return importUrl(); } }


    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public ImportToSalesLoft(ApexPages.StandardController controller) {
        selectedRecords = new List<sObject> { controller.getRecord() };
        records = selectedRecords;

     	selectedRecordIds.add(selectedRecords[0].id);
    }

    public ImportToSalesLoft(ApexPages.StandardSetController controller) {
        selectedRecords = controller.getSelected();
        records = controller.getRecords();
        filterName = controller.getFilterId();

        for(sObject selectedRecord : selectedRecords) {
          selectedRecordIds.add(selectedRecord.id);
        }
    }

    public PageReference redirect() {
        return buildPageRef(importUrl());
    }

    private String importUrl() {
        String objectType;
        String queryValue;

        if(selectedRecords.size() < 1) {
            String recordId = records[0].id;

            objectType = getObjectType(recordId);
            queryValue = filterName;

            String url = importUrlBase + objectType + '_listview=' + queryValue;
            return url;
        }

        objectType = getObjectType(selectedRecordIds[0]);
        queryValue = getQueryObject();

        String url = importUrlBase + objectType + '=' + queryValue;
        return url;
    }

    private PageReference buildPageRef(String url) {
    	PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }

    private String getQueryObject() {
        return String.join(selectedRecordIds, ',');
    }

    private String getObjectType(String recordId) {
        String idPrefix = recordId.substring(0, 3);

        return objectTypeMap().get(idPrefix);
    }

    private Map<String, String> objectTypeMap() {
        Map<String, String> m = new Map<String, String>();

        m.put('001', 'account');
        m.put('003', 'contact');
        m.put('00Q', 'lead');

        return m;
    }
}
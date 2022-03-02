@isTest
public class ImportToSalesLoftTest {
    static testmethod void handlesAccounts() {
        Account account = new Account(Id='0013B00000Y9BzFQAV');

        List<Account> accountList = new List<Account>();
        accountList.add(account);

        System.assert(accountList[0].Id != null);

        ApexPages.StandardSetController stdSetCont = new ApexPages.StandardSetController(accountList);
        stdSetCont.setSelected(accountList);

        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdSetCont);
        PageReference result = mainCont.redirect();

        String url = result.getUrl();
        String queryParam = result.getParameters().get('account');

        System.assertEquals(1, queryParam.split(',').size());
    }

    static testmethod void handlesLeads() {
        Lead lead = new Lead(Id='00Q3B00000QBvCD');

        List<Lead> leadList = new List<Lead>();
        leadList.add(lead);

        System.assert(leadList[0].Id != null);

        ApexPages.StandardSetController stdSetCont = new ApexPages.StandardSetController(leadList);
        stdSetCont.setSelected(leadList);

        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdSetCont);
        PageReference result = mainCont.redirect();

        String url = result.getUrl();
        String queryParam = result.getParameters().get('lead');

        System.assertEquals(1, queryParam.split(',').size());
    }

    static testmethod void handlesContacts() {
        Contact contact = new Contact(Id='0033B00000QBvCDQA1');

        List<Contact> contactList = new List<Contact>();
        contactList.add(contact);

        System.assert(contactList[0].Id != null);

        ApexPages.StandardSetController stdSetCont = new ApexPages.StandardSetController(contactList);
        stdSetCont.setSelected(contactList);

        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdSetCont);
        PageReference result = mainCont.redirect();

        String url = result.getUrl();
        String queryParam = result.getParameters().get('contact');

        System.assertEquals(1, queryParam.split(',').size());
    }

    static testmethod void handlesUnselectedSets() {
        Contact contact = new Contact(Id='0033B00000QBvCDQA1');

        List<Contact> contactList = new List<Contact>();
        contactList.add(contact);

        System.assert(contactList[0].Id != null);

        ApexPages.StandardSetController stdSetCont = new ApexPages.StandardSetController(contactList);

        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdSetCont);
        PageReference result = mainCont.redirect();

        String url = result.getUrl();
        String queryParam = result.getParameters().get('contact_listview');

        System.assertEquals(true, String.isNotBlank(queryParam));
        System.assertEquals(1, queryParam.split(',').size());
    }

    static testmethod void handleOneoffContact() {
        Contact contact = new Contact(Id='0033B00000QBvCDQA1');

        ApexPages.StandardController stdController = new ApexPages.StandardController(contact);

        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdController);
        PageReference result = mainCont.redirect();

        String url = result.getUrl();
        String queryParam = result.getParameters().get('contact');

           System.assertEquals(true, String.isNotBlank(queryParam));
        System.assertEquals(1, queryParam.split(',').size());
    }

    static testmethod void handleOneoffLead() {
        Lead lead = new Lead(Id='00Q3B000005aUVHUA2');

        ApexPages.StandardController stdController = new ApexPages.StandardController(lead);

        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdController);
        PageReference result = mainCont.redirect();

        String url = result.getUrl();
        String queryParam = result.getParameters().get('lead');

        System.assertEquals(true, String.isNotBlank(queryParam));
        System.assertEquals(1, queryParam.split(',').size());
    }

    static testmethod void importUrlForOneOffLead() {
        Lead lead = new Lead(Id='00Q3B000005aUVHUA2');

        ApexPages.StandardController stdController = new ApexPages.StandardController(lead);

        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdController);
        String importUrl = mainCont.importUrl;

        System.assertEquals('https://app.salesloft.com/app/import/crm?lead=' + lead.Id, importUrl);
    }

}
/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class RC_UploadContactDocumentTest {

    static testMethod void UploadContactDocumentTest()
    {
        User objUser = RC_UtilityClass.returnCommunityUser();

        system.runAs(objUser)
        {
            Test.startTest();
                Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
                Apexpages.currentPage().getParameters().put('ExpId', '');
                RC_UploadContactDocument objUploadDocument = new RC_UploadContactDocument();
            Contact cName = new contact();
            cName.FirstName = 'FirstTest';
            cName.LastName = 'LastTest';
                insert cName;
                Apexpages.currentPage().getParameters().put('ExpId', objUser.contactId);
                RC_UploadContactDocument objUploadDocumentTest = new RC_UploadContactDocument();
                //objUploadDocumentTest.objAttachment = objAttachment;
            objUploadDocumentTest.attbody = blob.valueOf('Test');
            objUploadDocumentTest.attname = 'test';
            objUploadDocumentTest.atttype = 'Application/WSword';

                objUploadDocumentTest.uploadDocument();
                objUploadDocumentTest.objAttachment.Name = 'TestAttachment';
                objUploadDocumentTest.objAttachment.body = bodyBlob;
                objUploadDocumentTest.UploadExpenseAttachment();
                //system.assertEquals(strContactId, objUploadDocumentTest.objAttachment.ParentId);
            Test.stopTest();
        }
        Attachment objAttachment = [Select ParentId,IsPrivate from Attachment ];
        system.assertEquals(objUser.contactId, objAttachment.ParentId);
        system.assertEquals(false, objAttachment.IsPrivate);
    }
    
    
    static testMethod void UploadContactDocumentTest1()
    {
        User objUser = RC_UtilityClass.returnCommunityUser();

        system.runAs(objUser)
        {
            Test.startTest();
                Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
                Apexpages.currentPage().getParameters().put('ExpId', '');
                RC_UploadContactDocument objUploadDocument = new RC_UploadContactDocument();
            Contact cName = new contact();
            cName.FirstName = 'FirstTest';
            cName.LastName = 'LastTest1';
                insert cName;
                Apexpages.currentPage().getParameters().put('ExpId', objUser.contactId);
                RC_UploadContactDocument objUploadDocumentTest = new RC_UploadContactDocument();
                //objUploadDocumentTest.objAttachment = objAttachment;
            objUploadDocumentTest.strDocumentType = 'Resume';
            objUploadDocumentTest.attbody = blob.valueOf('Test');
            objUploadDocumentTest.attname = 'test';
            objUploadDocumentTest.atttype = 'Application/WSword';

                objUploadDocumentTest.uploadDocument();
                objUploadDocumentTest.objAttachment.Name = 'TestAttachment';
                objUploadDocumentTest.objAttachment.body = bodyBlob;
                objUploadDocumentTest.UploadExpenseAttachment();
                //system.assertEquals(strContactId, objUploadDocumentTest.objAttachment.ParentId);
            Test.stopTest();
        }
       List<Attachment> objAttachment = [Select ParentId,IsPrivate from Attachment ];
        //system.assertEquals(objUser.contactId, objAttachment.ParentId);
       // system.assertEquals(false, objAttachment.IsPrivate);
    }
}
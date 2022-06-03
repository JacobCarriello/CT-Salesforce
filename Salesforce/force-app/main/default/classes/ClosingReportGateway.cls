public with sharing class ClosingReportGateway {
    // public static void onBeforeInsert (List <TR1__Closing_Report__c> listNewClosingReport) {

    // }

    // public static void onBeforeUpdate (List <TR1__Closing_Report__c> listNewClosingReport,List <TR1__Closing_Report__c> listOldClosingReport) {

    // }

    // public static void onAfterInsert (List <TR1__Closing_Report__c> listNewClosingReport) {

    // }

    // public static List <TR1__Closing_Report__c> onAfterUpdate (List <TR1__Closing_Report__c> listNewClosingReport,List <TR1__Closing_Report__c> listOldClosingReport) {

    // }

    public static List <TR1__Gross_Profit__c> checkUpdatesForGP (List <TR1__Closing_Report__c> listNewClosingReport,List <TR1__Closing_Report__c> listOldClosingReport) {
        TR1__Closing_Report__c newCL = new TR1__Closing_Report__c ();
        TR1__Closing_Report__c oldCL = new TR1__Closing_Report__c ();
        List <TR1__Closing_Report__c> listCLGetGP = new List <TR1__Closing_Report__c> ();

        for (SObject soNew : Trigger.new) {
            newCl = (TR1__Closing_Report__c)soNew;
            for (SObject soOld : Trigger.old) {
                oldCL = (TR1__Closing_Report__c)soOld;
                if (newCl.Id == oldCL.Id) {
                    if (newCl.Invoice_Number__c != oldCL.Invoice_Number__c 
                        // || newCL.Ref_of_Original_Invoice__c != oldCL.Ref_of_Original_Invoice__c 
                        || newCL.TR1__Invoice_Date__c != oldCL.TR1__Invoice_Date__c 
                        || newCL.TR1__Job_Credit__c != oldCL.TR1__Job_Credit__c 
                        // || newCL.TR1__GP_Amount__c != oldCL.TR1__GP_Amount__c 
                        /* || newCL.Team__c != oldCL.Team__c */ 
                        || newCL.TR1__Division__c != oldCL.TR1__Division__c 
                        || newCL.Placement_Date__c != oldCL.Placement_Date__c) {
                        listCLGetGP.add(newCL);
                    }
                }
            }
        }
        return getGPToUpdate(listCLGetGP);
    }

    public static List <TR1__Gross_Profit__c> getGPToUpdate (List <TR1__Closing_Report__c> listCL) {
        return [SELECT Id FROM TR1__Gross_Profit__c WHERE TR1__Closing_Report__c IN : listCL];
    }
}
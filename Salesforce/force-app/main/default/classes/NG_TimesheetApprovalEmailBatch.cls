global class NG_TimesheetApprovalEmailBatch 
	implements Database.Batchable<sObject> 
{
    global final String query;
    
    global NG_TimesheetApprovalEmailBatch(String q) {
        this.query = q;
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<TR1__Timesheet__c, String> emails = new Map<TR1__Timesheet__c, String>();

        NGCSH__c config = NGCSH__c.getOrgDefaults();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: config.TS_Sender_Email__c];
        String bccs = config.TS_BCC_Addresses__c;
        
        TR1__Timesheet__c timesheet;
        List<TR1__Timesheet__c> timesheets = new List<TR1__Timesheet__c>();
        
        for(sobject o : scope) {
            timesheet = (TR1__Timesheet__c) o;
            if(timesheet.TR1__Timesheet_Approver_Email__c != null ) {
            	emails.put(timesheet, buildApprovalEmail(timesheet, config));  
                timesheets.add(timesheet);
            }
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(TR1__Timesheet__c key : emails.keySet()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if(bccs != null) {
            	List<String> bccList = bccs.split(',');
            	mail.setBccAddresses(bccList);
        	}
            
        	mail.setToAddresses(new List<String> { key.TR1__Timesheet_Approver_Email__c });
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            
            mail.setSubject('Approve Timesheet for: ' + key.NG_Consultant_Name__c);
            
            string body = emails.get(key);
            body = body.replace('null' , '') ;
            mail.setHtmlBody(body);
            
            mails.add(mail);
        }
        
        Messaging.sendEmail(mails);
        
        for(TR1__Timesheet__c t : timesheets) {
            t.NG_Approval_Reminder_Sent__c = true;
        }
        
        update timesheets;
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];    
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Timesheet Approval Email Batch program ' + a.Status);
            mail.setPlainTextBody
            ('The batch Apex job'+'('+ BC.getJobId()+')processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception ex){}        
    }
    
    public String buildApprovalEmail(TR1__Timesheet__c trTimesheet, NGCSH__c config) {
        TimesheetDetailsController tdc = new TimesheetDetailsController();
        tdc.TR_Timesheet_ID = trTimesheet.Id;
        List<TimesheetDetailsController.TimesheetDetail> details = tdc.getDetails();

        string body = '<p>' + trTimesheet.TR1__Approver_First_Name__c + ',</p>' +
                    '<p>Please click link below to approve this timesheet for week ending ' + trTimesheet.TR1__Week_Ending__c.format() + ' at ' + trTimesheet.Worksite_Location__c + '.</p>' +
                    '<p><b><a href="' + config.TS_Approval_Domain_Url__c +'">Click Here</a></p>' +   
                    '<b>Click \'Approve\' or \'Approve All\' to submit your approval. If time is not approved, click Reject, add reason(s), and click \'Save.\'</p>' +
                    
                    '<p><b>Candidate Name:</b>  ' + trTimesheet.NG_Consultant_Name__c + '<br/>' +
                    '<b>Worksite Location:</b> ' + trTimesheet.Worksite_Location__c + '</p>';
        
        if(trTimesheet.Overtime_Threshold_Type__c == 'Weekly') {
            body += '<table style="border:solid #CCCCCC; border-width:2" border="2">' +
                        '<tr>' +
                            '<th>Start Date Time</th>' +
                            '<th>End Date Time</th>' +
                            '<th>Unpaid Break Hours</th>' +
                            '<th>Total Regular Hours</th>' +
                            '<th>On Call</th>' +
                            '<th>Total Callback Hours</th>' +
                            '<th>Provider Comments/Mileage</th>' +
                        '</tr>';

            for(TimesheetDetailsController.TimesheetDetail detail : details) {
                body += '<tr>' +
                        '<td>' + (detail.inDate + ' ' + detail.inTime) + '</td>' +
                        '<td>' + (detail.outDate + ' ' + detail.outTime) + '</td>' +
                        '<td align="right">' + detail.unpaidBreakHours + '</td>' +
                        '<td align="right">' + detail.totalRegHours + '</td>' +
                        '<td align="center">' + detail.onCall + '</td>' +
                        '<td align="right">' + detail.totalCBHours + '</td>' +
                        '<td align="left">' + detail.note + '</td>' +
                        '</tr>';
            }

            body += '</table><br/>';

            body += '<table style="border:solid #CCCCCC; border-width:2" border="2">' +
                        '<tr>' +
                            '<th>Total Weekly Hours</th>' +
                            '<th>Total Weekly Overtime Hours</th>' +  
                        '</tr>';       

            body += '<tr>' +
                    '<td align="right">' + trTimesheet.NG_Total_Weekly_Hours__c + '</td>' +
                    '<td align="right">' + trTimesheet.NG_Total_Weekly_Overtime_Hours__c + '</td>' +
                    '</tr>' +
                    '</table>';
        }
        else {
            body += '<table style="border:solid #CCCCCC; border-width:2" border="2">' +
                        '<tr>' +
                            '<th>Start Date Time</th>' +
                            '<th>End Date Time</th>' +
                            '<th>Unpaid Break Hours</th>' +
                            '<th>Total Regular Hours</th>' +
                            '<th>Total Overtime Hours</th>' +
                            '<th>On Call</th>' +
                            '<th>Total Callback Hours</th>' +
                            '<th>Provider Comments/Mileage</th>' +
                        '</tr>';

            for(TimesheetDetailsController.TimesheetDetail detail : details) {
                body += '<tr>' +
                        '<td>' + (detail.inDate + ' ' + detail.inTime) + '</td>' +
                        '<td>' + (detail.outDate + ' ' + detail.outTime) + '</td>' +
                        '<td align="right">' + detail.unpaidBreakHours + '</td>' +
                        '<td align="right">' + detail.totalRegHours + '</td>' +
                        '<td align="right">' + detail.totalOTHours + '</td>' +
                        '<td align="center">' + detail.onCall + '</td>' +
                        '<td align="right">' + detail.totalCBHours + '</td>' +
                        '<td align="left">' + detail.note + '</td>' +
                        '</tr>';
            }

            body += '</table>';
        }

        body += '<br/><p>Thank you,</p>' +
                '<p>Curative Logistics Team<br/>' +
                '<a href=mailto:logistics@curativetalent.com>logistics@curativetalent.com</a></p>';
     
        return body;
    }

}
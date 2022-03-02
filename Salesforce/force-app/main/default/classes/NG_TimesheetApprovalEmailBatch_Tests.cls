@isTest
public class NG_TimesheetApprovalEmailBatch_Tests {
	@isTest
    public static void testBatcher() {
        Contact c = MockFactory.createContact();
        TR1__Timesheet__c t = MockFactory.createTRTimesheet(c.Id);
        MockFactory.createTimesheet(t.Id);
        t.NG_Portal_Status__c = 'Submitted';
        update t;
        system.debug('bw: email batch t = ' + t);

        NG_ScheduleTimesheetApprovalEmail schd = new NG_ScheduleTimesheetApprovalEmail();
        schd.execute(null);
        
        String query = 'SELECT NG_Portal_Status__c, ' +
            				  'TR1__Approver__c, ' +
            				  'TR1__Approver_First_Name__c, ' +
            				  'TR1__Timesheet_Approver_Email__c, ' +
            			      'TR1__Approvers_Notes__c, ' +
            				  'TR1__Consultant_Email__c, ' +
            				  'TR1__Consultant_Name__c, ' +
            				  'NG_Consultant_Name__c, ' +
            				  'Worksite_Location__c, ' +
            				  'TR1__Week_Ending__c, ' +
            				  'NG_Total_Weekly_Hours__c, ' +
            				  'NG_Total_Weekly_Overtime_Hours__c, ' +
            				  'NG_UUID__c, ' +
            				  'Overtime_Threshold_Type__c ' +
            			'FROM TR1__Timesheet__c ' +
            			'WHERE NG_Approval_Reminder_Sent__c = false ' +
							/*'AND NG_Portal_Submitted__c = true ' + */
            				'AND NG_Portal_Status__c = \'Submitted\'';
        
        NG_TimesheetApprovalEmailBatch batcher = new NG_TimesheetApprovalEmailBatch(query);
        batcher.start(null);
        List<sObject> scope = database.query(query);
		system.debug('bw: email batch scope = ' + scope);
		batcher.execute(null, scope);
        
        t.Overtime_Threshold_Type__c = 'Weekly';
        update t;
        
        batcher.execute(null, scope);
        
    }
}
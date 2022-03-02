trigger HolidayAccrual on TR1__Timesheet__c (after update, before update) {

    if(trigger.isAfter && trigger.isUpdate){
       
        new RC_HolidayAccrualHandler().afterUpdateHandler(trigger.newMap, trigger.oldMap);
        
    }
    
    if(trigger.isBefore && trigger.isUpdate)
    {
        for(TR1__Timesheet__c objTS : trigger.new)
        {
            if(objTS.TR1__Status__c == 'Approved')
            {
                objTS.Accrual_Processed__c = true;
            }
            else
            {
                objTS.Accrual_Processed__c = false;
            }
        }
    }
   
}
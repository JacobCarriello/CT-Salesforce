public with sharing class RC_HolidayAccrualHandler  {

    public void afterUpdateHandler(Map<Id, TR1__Timesheet__c> mapTSNew ,Map<Id, TR1__Timesheet__c> mapTSOld)
    {
        List<TR1__Contact_Accrual__c> lstAccurals = new List<TR1__Contact_Accrual__c>(); 
       
        Set<Id> setTSIdUpdate  = new Set<Id>();
        Set<Id> setTSIdRemoveAccural  = new Set<Id>();
        
        for(TR1__Timesheet__c objTS : mapTSNew.values()){
            
            if(mapTSOld.get(objTS.Id).TR1__Status__c != 'Approved' && objTS.TR1__Status__c == 'Approved')
            {
                if(objTS.TR1__Total_Vacation_Hours__c > 0)
                {
                    lstAccurals.add(vacationHoursCal(objTS));
                }
                TR1__Contact_Accrual__c objConAcc = new TR1__Contact_Accrual__c();
                objConAcc.TR1__Timesheet__c = objTS.Id;
                objConAcc.TR1__Contact__c = objTS.TR1__Consultant__c;
                objConAcc.TR1__Type__c = 'Holiday';
                objConAcc.TR1__Effective_Date__c = objTS.TR1__Week_Ending__c;
                objConAcc.TR1__Comments__c = 'Accrued hours for week ending '+objTS.TR1__Week_Ending__c ;
                objConAcc.TR1__ExternalId__c = objTS.TR1__Consultant__c + string.valueOfGmt(objTS.TR1__Week_Ending__c) + 'Accrual';
                lstAccurals.add(objConAcc);
            }
            
            else if(mapTSOld.get(objTS.Id).TR1__Status__c == 'Approved' && objTS.TR1__Status__c == 'Approved')
            {
                if(objTS.TR1__Total_Vacation_Hours__c > 0)
                {
                    lstAccurals.add(vacationHoursCal(objTS));
                }
            }
           
            else if(mapTSOld.get(objTS.Id).TR1__Status__c == 'Approved' && objTS.TR1__Status__c != 'Approved')
            {
                if(objTS.TR1__Total_Vacation_Hours__c > 0)
                {
                    lstAccurals.add(vacationHoursCal(objTS));
                }
            }
           
        }
        
        if(!lstAccurals.isEmpty()){
          RC_AccessController.upsertContactAccrual(lstAccurals, TR1__Contact_Accrual__c.fields.TR1__ExternalId__c);  
        }
    }
 

    private TR1__Contact_Accrual__c vacationHoursCal(TR1__Timesheet__c objTS)
    {
        TR1__Contact_Accrual__c objConAccHoliday = new TR1__Contact_Accrual__c();
        objConAccHoliday.TR1__Timesheet__c = objTS.Id;
        objConAccHoliday.TR1__Contact__c = objTS.TR1__Consultant__c;
        objConAccHoliday.TR1__Type__c = 'Holiday';
        objConAccHoliday.TR1__Effective_Date__c = objTS.TR1__Week_Ending__c;
        objConAccHoliday.TR1__Hours_Accrued__c = -objTS.TR1__Total_Vacation_Hours__c;
        if(objTS.TR1__Status__c != 'Approved')
            objConAccHoliday.TR1__Hours_Accrued__c = 0;
        objConAccHoliday.TR1__ExternalId__c = objTS.TR1__Consultant__c +''+ objConAccHoliday.TR1__Timesheet__c + 'Holiday';
        objConAccHoliday.TR1__Comments__c = 'No of Vacation hours  taken for TS '+objConAccHoliday.TR1__Timesheet__c;
        return objConAccHoliday;
        
    }
}
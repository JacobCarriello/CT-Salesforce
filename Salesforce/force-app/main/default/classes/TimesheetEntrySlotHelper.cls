public with sharing class TimesheetEntrySlotHelper 
    extends BaseTriggerHelper
{
    public static boolean isExecuting = false;

    public TimesheetEntrySlotHelper() {

    }

    public override void execute(SObject so) {
        system.debug('bw-trigger: TimesheetEntrySlotHelper::' + (Trigger.isBefore ? 'Before Trigger: ' : 'After Trigger: ') + 'so = ' + so);
    }

    public override void execute(SObject so, SObject oldSo){
        system.debug('bw-trigger: TimesheetEntrySlotHelper::execute -> so = ' + so + ', oldSo = ' + oldSo);   

        if(!TimesheetEntrySlotHelper.isExecuting) {
            TimesheetEntrySlotHelper.isExecuting = true;
        //try {
            if(Trigger.isBefore && Trigger.isUpdate) {
                NG_Timesheet_Entry_Slot__c slot = (NG_Timesheet_Entry_Slot__c) so;

                Decimal totalHours = getTotalHours(slot.In_Date__c, 
                                                   slot.In_Time__c, 
                                                   slot.Out_Date__c, 
                                                   slot.Out_Time__c);
                slot.Hours__c = totalHours - (slot.Unpaid_Break_Time__c != null ? slot.Unpaid_Break_Time__c : 0);

                Decimal callbackHours = getTotalHours(slot.Custom_Callback_In_Date__c,
                                                    slot.Custom_Callback_In_Time__c,
                                                    slot.Custom_Callback_Out_Date__c,
                                                    slot.Custom_Callback_Out_Time__c);
                slot.Custom_Callback_Hours__c = callbackHours;

                if(slot.Did_Not_Work__c && slot.Note__c == null) {
                    slot.Note__c = 'Did not work.';
                }
                else if(slot.Did_Not_Work__c && !slot.Note__c.startsWith('Did not work.')) {
                    slot.Note__c = 'Did not work. ' + slot.Note__c;
                }

                synchronize(slot);    
                
                TimesheetEntrySlotHelper.isExecuting = false;
            }   
        //}
        //catch(Exception e) {
        //    system.debug('bw-trigger: TimesheetEntrySlotHelper::execute -> Exception = ' + e);
        //}
        }


    }

    private void synchronize(NG_Timesheet_Entry_Slot__c slot) {       
        // Set Regular Hours ShiftWork
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Timesheet Source Object ID = ' + slot.Timesheet_Source_Object_ID__c);
        Id rateId = TR_Rate_Gateway.fetchIdFromTimesheet(slot.Timesheet_Source_Object_ID__c, 'Regular');
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Regular.rateId = ' + rateId);
        Id shiftWorkId = null;

        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Source_Object_ID__c = ' + slot.Source_Object_ID__c);
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Timesheet_Entry_Source_Object_ID__c = ' + slot.Timesheet_Entry_Source_Object_ID__c);
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> In_Time__c = ' + slot.In_Time__c);
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> In_Date__c = ' + slot.In_Date__c);
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Out_Time__c = ' + slot.Out_Time__c);
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Out_Date__c = ' + slot.Out_Date__c);
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Hours__c = ' + slot.Hours__c);

        if((slot.In_Time__c != null && slot.Out_Time__c != null) || slot.Hours__c > 0) {
            shiftWorkId = TR_ShiftWork_Gateway.save(slot.Source_Object_ID__c, 
                                                   slot.Timesheet_Source_Object_ID__c, 
                                                   slot.Timesheet_Entry_Source_Object_ID__c, 
                                                   rateId, 
                                                   null,
                                                   slot.In_Time__c, 
                                                   date.valueOf(slot.Out_Date__c),
                                                   slot.Out_Time__c, 
                                                   slot.Hours__c);
            
            slot.Source_Object_ID__c = shiftWorkId;
            system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> slot.Source_Object_ID__c = ' + slot.Source_Object_ID__c); 
                                           
        }
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Regular.shiftWorkId = ' + shiftWorkId); 
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> fetch detail');                                           
        TR1__Timesheet_Detail__c timesheetDetail = TR_TimesheetDetail_Gateway.fetch(slot.Timesheet_Entry_Source_Object_ID__c);
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> set properties');
        timesheetDetail.NG_Unpaid_Break_Time__c = slot.Unpaid_Break_Time__c;
        timesheetDetail.NG_Shift_Notes__c = slot.Note__c;

        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> TR1__Day__c = ' + timesheetDetail.TR1__Day__c);
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> TR1__Date__c = ' + timesheetDetail.TR1__Date__c);     
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> slot.Day__c = ' + slot.Day__c);
        system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> slot.Date__c = ' + slot.Date__c);     

        if(timesheetDetail.TR1__Day__c == null || timesheetDetail.TR1__Date__c == null){
            timesheetDetail.TR1__Day__c = slot.Day__c;
            timesheetDetail.TR1__Date__c = slot.Date__c;
        }

        timesheetDetail.NG_Did_Not_Work__c = slot.Did_Not_Work__c;

        TR_TimesheetDetail_Gateway.save(timesheetDetail);

        // Set Callback Hours ShiftWork if applicable
        if(slot.Custom_Callback_Hours__c != null && slot.Custom_Callback_Hours__c > 0) {
            rateId = TR_Rate_Gateway.fetchIdFromTimesheet(slot.Timesheet_Source_Object_ID__c, 'Callback');
            system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Callback.rateId = ' + rateId);
            if(rateId != null) {
                system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Save callback shiftwork');
                shiftWorkId = TR_ShiftWork_Gateway.save(slot.Custom_Callback_Source_ID__c,
                                                        slot.Timesheet_Source_Object_ID__c,
                                                        slot.Timesheet_Entry_Source_Object_ID__c,
                                                        rateId,
                                                        slot.Custom_On_Call_Beeper__c,
                                                        slot.Custom_Callback_In_Time__c,
                                                        date.valueOf(slot.Custom_Callback_Out_Date__c),
                                                        slot.Custom_Callback_Out_Time__c,
                                                        slot.Custom_Callback_Hours__c);
                system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> Callback.shiftworkId = ' + shiftWorkId);
                slot.Custom_Callback_Source_ID__c = shiftWorkId;
                system.debug('bw-trigger: TimesheetEntrySlotHelper.synchronize -> slot.Custom_Callback_Source_ID__c = ' + slot.Custom_Callback_Source_ID__c);
            }
        }

        // Update Entry with Date and Day if necessary
        if(slot.Date__c != null && slot.Day__c != null) {
            NG_Timesheet_Entry__c entry = TimesheetEntryGateway.fetch(slot.Timesheet_Entry__c);
            entry.Name = slot.Day__c + ' - ' + slot.Date__c.format();
            entry.Day__c = slot.Day__c;
            entry.Date__c = slot.Date__c;
            TimesheetEntryGateway.save(entry);
        }
    }

    private Decimal getTotalHours(String inDate, String inTime, String outDate, String outTime) {
        System.debug('bw-trigger: getTotalHours -> inDate, inTime, outDate, outTime = ' + inDate + ', ' + inTime + ', ' + outDate + ', ' + outTime);

        if(inDate == null || inTime == null || outDate == null || outTime == null) {
            return 0;
        }

        List<Integer> inValues =    splitDateTime(inDate, inTime);
        List<Integer> outValues =   splitDateTime(outDate, outTime);

                                /* year, month, day, hour, minute, second */
        DateTime inDT =         DateTime.newInstance(inValues[0], 
                                                     inValues[1], 
                                                     inValues[2], 
                                                     inValues[3], 
                                                     inValues[4], 
                                                     0);

        DateTime outDT =        DateTime.newInstance(outValues[0],
                                                     outValues[1],
                                                     outValues[2],
                                                     outValues[3],
                                                     outValues[4],
                                                     0);

        Long inVal =            inDT.getTime();
        Long outVal =           outDT.getTime();
        System.debug('bw-trigger: getTotalHours -> inVal, outVal = ' + inVal + ', ' + outVal);

        Long diffMils =         outVal - inVal + (inVal > outVal ? 86400000 : 0);
        Decimal diff =          diffMils/1000.00/60.00/60.00;

        return diff.setScale(2);
    }

    private List<Integer> splitDateTime(String dateString, String timeString) {
        List<Integer> returnValue = new List<Integer>();

        List<String> values = new List<String>();
        values.addAll(dateString.split('-'));
        values.addAll(timeString.split(':'));

        for(Integer i=0; i<values.size();i++) {
            returnValue.add(Integer.valueOf(values[i]));
        }

        return returnValue;
    }

}
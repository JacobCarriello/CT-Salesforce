declare module "@salesforce/apex/TimesheetService.fetchTimesheet" {
  export default function fetchTimesheet(param: {timesheetId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.fetchTimesheetsForApprover" {
  export default function fetchTimesheetsForApprover(param: {approverId: any, statusFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.fetchTimesheetsForEmployee" {
  export default function fetchTimesheetsForEmployee(param: {contactId: any, statusFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.fetchTimesheetEntriesForTimesheet" {
  export default function fetchTimesheetEntriesForTimesheet(param: {timesheetId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.fetchTimesheetEntry" {
  export default function fetchTimesheetEntry(param: {entryId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.fetchTimesheetEntrySlotsForEntry" {
  export default function fetchTimesheetEntrySlotsForEntry(param: {entryId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.fetchTimesheetEntrySlot" {
  export default function fetchTimesheetEntrySlot(param: {slotId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.addTimesheetEntry" {
  export default function addTimesheetEntry(param: {timesheetId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.submitTimesheet" {
  export default function submitTimesheet(param: {timesheetId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.approveTimesheet" {
  export default function approveTimesheet(param: {timesheetId: any, usersName: any, email: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.rejectTimesheet" {
  export default function rejectTimesheet(param: {timesheetId: any, usersName: any, email: any, rejectReason: any}): Promise<any>;
}
declare module "@salesforce/apex/TimesheetService.validateApprovalToken" {
  export default function validateApprovalToken(param: {timesheetId: any, token: any}): Promise<any>;
}

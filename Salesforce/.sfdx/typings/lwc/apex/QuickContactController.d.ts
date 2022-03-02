declare module "@salesforce/apex/QuickContactController.getAccount" {
  export default function getAccount(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuickContactController.saveContactWithAccount" {
  export default function saveContactWithAccount(param: {contact: any, accountId: any}): Promise<any>;
}

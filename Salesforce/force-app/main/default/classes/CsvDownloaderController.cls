public class CsvDownloaderController {
    public String csvBody {get; set;}
    public String csvName {get; set;}    
    
    public CsvDownloaderController() {
        String objectType = ApexPages.currentPage().getParameters().get('objType');
        csvName = objectType + '.csv';
        String csvColumnHeader;
        List<String> csvRowValues = new List<String>();
        
        if (objectType == 'Contacts') {
            List<Contact> conts= [SELECT Id, Name, Email, Account.Name  FROM Contact WHERE Owner.Profile.UserLicense.Name LIKE 'GUEST%'];
            csvColumnHeader = 'Id, Name, Email, AccountName\n';
            for (Contact con : conts) {
                String conId 		= con.Id != null ? con.Id : '';
                String conName 		= con.Name != null ? con.Name : '';
                String conEmail 	= con.Email != null ? con.Email : '';
                String conAccount	= con.Account.Name != null ? con.Account.Name : '';
                
                String rowStr = conId + ',' + conName.replaceAll(',','') + ',' + conEmail.replaceAll(',','') + ',' + conAccount.replaceAll(',','');
                csvRowValues.add(rowStr);
            }
        } else if (objectType == 'Attachments') {
            List<Attachment> atts = [SELECT Id,Name,ParentId,Parent.Name FROM Attachment WHERE Owner.Profile.UserLicense.Name LIKE 'GUEST%'];
            csvColumnHeader = 'Id, Name, ParentId, ParentName\n';
            for (Attachment att : atts) {
                String attId 		= att.Id != null ? att.Id : '';
                String attName 		= att.Name != null ? att.Name : '';
                String attParentId 	= att.ParentId != null ? att.ParentId : '';
                String attParent	= att.Parent.Name != null ? att.Parent.Name : '';
                
                String rowStr = attId + ',' + attName.replaceAll(',','') + ',' + attParentId + ',' + attParent.replaceAll(',','');
                csvRowValues.add(rowStr);
            }
        }
        
        
        String csvFile  = csvColumnHeader + String.join(csvRowValues,'\n');
        csvBody = EncodingUtil.base64Encode(Blob.valueof(csvFile));
    }
}
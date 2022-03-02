public class CommunityUserController {
    @AuraEnabled
    public static String getContactId() {
        User u = [Select ContactId from User where Id = :UserInfo.getUserId()];
        system.debug('bw: userID = ' + UserInfo.getUserId() + ', contactId = ' + u.ContactId);
        
		return u.ContactId;
    }
}
public without sharing class ContactService {
    @testVisible
    public static Id userId {
        get {
            if(userId == null) {
                userId = UserInfo.getUserId();
            }
            return userId;
        } set;
    }
    
    public ContactService() {

    }

    @AuraEnabled(cacheable=true)
    public static Id fetchContactIdFromUser(){

        List<User> lstUser = [Select u.Id,u.ContactId from User u where u.Id = :userId];
            if( lstUser != null && lstUser.size() > 0 )
            {
                System.debug('lstUser[0].ContactId::' + lstUser[0].ContactId);
                return lstUser[0].ContactId;
            }

            throw new AuraHandledException('Contact Id does not exist');
    }

}
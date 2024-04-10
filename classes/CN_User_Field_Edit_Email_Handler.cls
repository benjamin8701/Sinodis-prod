/**************************************************************************************************
 * Name           : CN_User_Field_Edit_Email_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2024-01-22
 * Modify History : 
 **************************************************************************************************/
public without sharing  class CN_User_Field_Edit_Email_Handler implements Triggers.Handler{
    public void handle() {
         if(Trigger.isBefore && Trigger.isUpdate) {
             handleBeforeUpdate();
         }
		
    }

    public void handleBeforeUpdate(){
        //add by ZhangZhihao User whose EC needs to be pushed
        Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id, Name FROM Profile]);
        Set<String> salesProfileSet = new Set<String>(Constants.CN_SALES_PROFILE_Names.split(','));
         //add by ZhangZhihao User whose EC needs to be pushed
        for(User user: (List<User>)Trigger.new) {
            if (user.IsActive != true){
                continue;
            }
             //add by ZhangZhihao User whose EC needs to be pushed
            Profile userProfile = profileMap.get(user.ProfileId);
            if (userProfile == null || !salesProfileSet.contains(userProfile.Name)) {
                continue;
            }
             //add by ZhangZhihao User whose EC needs to be pushed
            String profileName = profileMap.get(user.ProfileId).Name;
            User oldUser = (User)Trigger.oldMap.get(user.Id);
            if (user.Email == oldUser.Email){
                continue;
            }
            user.CN_Target_Email__c = user.Email;
            user.CN_Email_Verified_Need_Sync__c = true;
        }
    }

}
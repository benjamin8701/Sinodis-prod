/**************************************************************************************************
 * Name           : CN_Complaint_Offline_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : He Peng
 * Create Date    : 2024-1-24
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Complaint_Offline_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            beforeInsertHandle();
        }
    }
    private void beforeInsertHandle() {     
        Id CSQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'CN_CS_Queue'].Id;
        //Case oldCase = (Case)Trigger.oldMap.get(cases.Id);
        
        String userId = UserInfo.getUserId();
        User userRecord = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id = :userId];
        for (Case cases : (List<Case>)Trigger.new) {
            if(Constants.CN_CA_STATUS_NEW.equals(cases.status) &&  Constants.CN_PROFILE_NAME_CS.equals(userRecord.Profile.Name)){
                cases.OwnerId = CSQueueId;
            }
            
        }
    }
}
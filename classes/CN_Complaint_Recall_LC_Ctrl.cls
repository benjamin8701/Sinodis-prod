/**************************************************************************************************
 * Name           : CN_Complaint_Recall_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-12-13
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Complaint_Recall_LC_Ctrl {
    @auraEnabled
    public static Map<String, Object> recallComplaint(String recordId) {
        String errorMessage = '';

        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Complaint_Not_Found);
        }
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('Case');
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_Complaint_No_Permission);
        }
        List<Case> compList = [SELECT Id,
                                        //Add by Zhang Zhihao 2023/1/14  Query submitter
                                        CN_Submitter__c,
                                         //Add by Zhang Zhihao 2023/1/14  Query submitter
                                        CreatedById,
                                        Status,
                                        CN_Recall_Button__c,
                                        CN_Recall_Date__c
                                    FROM Case
                                    WHERE Id =: recordId];
        if(compList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Complaint_Not_Found);
        }
        String ProfileName = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id = :userinfo.getUserId()].Profile.Name;
        Id CSQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'CN_CS_Queue'].Id;
        Case caseToUpdate = compList[0];
        if( Constants.CN_CA_STATUS_ASSIGNED.equals(caseToUpdate.Status)
        //Add by Zhang Zhihao 2023/1/14  The author may withdraw
        //&& userinfo.getUserId() == caseToUpdate.CreatedById) 
        && (userinfo.getUserId() == caseToUpdate.CN_Submitter__c ||  
        userinfo.getUserId() == caseToUpdate.CreatedById
        )) 
        //Add by Zhang Zhihao 2023/1/14  The author may withdraw
        {
            
            caseToUpdate.Status = Constants.CN_CA_STATUS_NEW;
            caseToUpdate.CN_Recall_Button__c = true;
            caseToUpdate.CN_Recall_Date__c = Datetime.now();
            //Add by Zhang Zhihao 2023/1/14  Assign the submitter
            //Add by He Peng recall to cs queue, new not send.  sales can recall
            if(Constants.CN_PROFILE_NAME_CS.equals(ProfileName)){
                caseToUpdate.OwnerId = CSQueueId;
            }else{
                if(caseToUpdate.CN_Submitter__c!=null){
                    caseToUpdate.OwnerId = caseToUpdate.CN_Submitter__c;
                }else{
                    caseToUpdate.OwnerId = caseToUpdate.CreatedById;
                }
            }
            caseToUpdate.CN_Need_Send_MG_Flag__c = 0;
        }else{
            throw new AuraHandledException(System.Label.CN_Complaint_Can_Not_Recall);
        }
        try{
            //Add by He Peng 2023/1/18 recall
            Constants.CA_TRIGGER_ON = false;
            update caseToUpdate;
            Constants.CA_TRIGGER_ON = true;
        }catch(exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
        return new Map<String, Object>{
            'errorMessage' => errorMessage
        };
    }
}
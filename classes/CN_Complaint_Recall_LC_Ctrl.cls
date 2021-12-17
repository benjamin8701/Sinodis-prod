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
                                        CreatedById,
                                        Status,
                                        CN_Recall_Button__c,
                                        CN_Recall_Date__c
                                    FROM Case
                                    WHERE Id =: recordId];
        if(compList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Complaint_Not_Found);
        }

        Case caseToUpdate = compList[0];
        if( Constants.CN_CA_STATUS_ASSIGNED.equals(caseToUpdate.Status)
            && userinfo.getUserId() == caseToUpdate.CreatedById) 
        {
            caseToUpdate.Status = Constants.CN_CA_STATUS_NEW;
            caseToUpdate.CN_Recall_Button__c = true;
            caseToUpdate.CN_Recall_Date__c = Datetime.now();
            caseToUpdate.OwnerId = caseToUpdate.CreatedById;
        }else{
            throw new AuraHandledException(System.Label.CN_Complaint_Can_Not_Recall);
        }
        try{
            update caseToUpdate;
        }catch(exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
        return new Map<String, Object>{
            'errorMessage' => errorMessage
        };
    }
    
}
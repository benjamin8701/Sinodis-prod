/**************************************************************************************************
 * Name           : CN_Complaint_Canceled_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-12-14
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Complaint_Canceled_LC_Ctrl {
    @auraEnabled
    public static Map<String, Object> cancelComplaint(String recordId) {
        String errorMessage = '';

        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Complaint_Not_Found);
        }
        List<Case> compList = [SELECT Id,
                                        CreatedById,
                                        Status,
                                        CN_Cancel_Button__c
                                    FROM Case
                                    WHERE Id =: recordId];
        if(compList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Complaint_Not_Found);
        }

        Case caseToUpdate = compList[0];
        if( (Constants.CN_CA_STATUS_NEW.equals(caseToUpdate.Status)|| Constants.CN_CA_STATUS_REJECTED.equals(caseToUpdate.Status))
            && userinfo.getUserId() == caseToUpdate.CreatedById) 
        {
            caseToUpdate.Status = Constants.CN_CA_STATUS_CANCELED;
            caseToUpdate.CN_Cancel_Button__c = true;
        }else{
            throw new AuraHandledException(System.Label.CN_Complaint_Can_Not_Cancel);
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
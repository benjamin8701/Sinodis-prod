/**************************************************************************************************
 * Name           : CN_Complaint_Resolved_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-08-17
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Complaint_Resolved_LC_Ctrl {
    @auraEnabled
    public static Map<String, Object> updateStatusToResolved(String recordId) {

        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String myProflieName = profileList[0].Name;
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
                                        CN_Resolved_Button__c,
                                        CN_Resolve_Reason__c
                                    FROM Case
                                    WHERE Id =: recordId];
        if(compList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Complaint_Not_Found);
        }

        Case caseToUpdate = compList[0];
        if( Constants.CN_CA_STATUS_ACCEPTED.equals(caseToUpdate.Status)
            && (Constants.CN_PROFILE_NAME_CS.equals(myProflieName) || Constants.CN_PROFILE_NAME_QA.equals(myProflieName) || Constants.CN_PROFILE_NAME_ADMIN.equals(myProflieName))
            && caseToUpdate.CN_Resolve_Reason__c != null) 
        {
            caseToUpdate.Status = Constants.CN_CA_STATUS_RESOLVED;
            caseToUpdate.OwnerId = caseToUpdate.CreatedById;
            caseToUpdate.CN_Resolved_Button__c = true;
        }else if(caseToUpdate.CN_Resolve_Reason__c == null){
            throw new AuraHandledException(System.Label.CN_Complaint_ResolveReason_Null);
        }else{
            throw new AuraHandledException(System.Label.CN_Complaint_Can_Not_Resolved);
        }
        update caseToUpdate;
        return new Map<String, Object>{
            'errorMessage' => errorMessage
        };
    }
    
}
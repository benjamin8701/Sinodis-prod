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
public with sharing class CN_Complaint_Resolved_LC_Ctrl {
    @auraEnabled
    public static Map<String, Object> updateStatusToResolved(String recordId,String resolveDescription,String resolveReason,String resolveComments) {

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
            && resolveReason != null) 
        {
            caseToUpdate.Status = Constants.CN_CA_STATUS_RESOLVED;
            caseToUpdate.OwnerId = caseToUpdate.CreatedById;
            caseToUpdate.CN_Resolved_Button__c = true;
            caseToUpdate.CN_Resolve_Description__c = resolveDescription;
            caseToUpdate.CN_Resolve_Reason__c = resolveReason;
            caseToUpdate.CN_Resolve_Comments__c = resolveComments;
            
        }else if(caseToUpdate.CN_Resolve_Reason__c == null){
            throw new AuraHandledException(System.Label.CN_Complaint_ResolveReason_Null);
        }else{
            throw new AuraHandledException(System.Label.CN_Complaint_Can_Not_Resolved);
        }
        try {
            update caseToUpdate;
        } catch (Exception e) {
            String err = e.getMessage();
            if(err.contains(System.Label.CN_Complaint_ResolveReason_VR_ErrorMsg) && err.contains('Customer Service')){
                errorMessage = System.label.CN_Complaint_Check_Reason_QA_Msg;
            }else if(err.contains(System.Label.CN_Complaint_ResolveReason_VR_ErrorMsg) && err.contains('Brand Quality')){
                errorMessage = System.label.CN_Complaint_Check_Reason_CS_Msg;
            }else{
                errorMessage = err;
            }
        }
        
        return new Map<String, Object>{
            'errorMessage' => errorMessage
        };
    }

    @auraEnabled
    public static Map<String, Object> getInitInfo(String recordId) {
        Map<String, String> options_Reason = new Map<String, String>();
        Map<String, String> options_Comment = new Map<String, String>();
        String defaultReason = '';
        String defaultComment = '';

        Schema.DescribeFieldResult fieldResult_Reason = Case.CN_Resolve_Reason__c.getDescribe();
        Schema.DescribeFieldResult fieldResult_Comment = Case.CN_Resolve_Comments__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues_Reason = fieldResult_Reason.getPicklistValues();
        for (Schema.PicklistEntry p: pValues_Reason) {
            options_Reason.put(p.getValue(), p.getLabel());
        }
        List<Schema.PicklistEntry> pValues_Comment = fieldResult_Comment.getPicklistValues();
        for (Schema.PicklistEntry p: pValues_Comment) {
            options_Comment.put(p.getValue(), p.getLabel());
        }

        Case complaint = [Select Id,CN_Resolve_Reason__c,CN_Resolve_Comments__c From Case Where Id =: recordId][0];
        if(complaint!=null){
            defaultReason = complaint.CN_Resolve_Reason__c;
            defaultComment = complaint.CN_Resolve_Comments__c;
        }
        
        return new Map<String, Object>{
            'options_Reason' => options_Reason,
            'options_Comment' => options_Comment,
            'defaultReason' => defaultReason,
            'defaultComment' => defaultComment
        };
    }
    
}
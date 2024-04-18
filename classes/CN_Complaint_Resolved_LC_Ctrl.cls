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
        //Resolve Description ----by Shuqi
        List<Case> compList = [SELECT Id,
                                        //Add by Zhang Zhihao 2023/1/14  Query submitter
                                        CN_Submitter__c,
                                        //Add by Zhang Zhihao 2023/1/14  Query submitter
                                        CreatedById,
                                        Status,
                                        Origin,
                                        CN_Resolved_Button__c,
                                        CN_Resolve_Reason__c,
                               			CN_Resolve_Description__c
                                    FROM Case
                                    WHERE Id =: recordId];
        if(compList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Complaint_Not_Found);
        }
        Case caseToUpdate = compList[0];
        if( Constants.CN_CA_STATUS_ACCEPTED.equals(caseToUpdate.Status)
            && (Constants.CN_PROFILE_NAME_CS.equals(myProflieName) 
            //add by Zhang zhihao Add simple food safety simple party 2023/12/28
            || Constants.CN_PROFILE_NAME_QA.equals(myProflieName) 
            //add by Zhang zhihao Add simple food safety simple party 2023/12/28
            || Constants.CN_PROFILE_NAME_ADMIN.equals(myProflieName) 
            || Constants.CN_PROFILE_NAME_FOODQUALITY.equals(myProflieName)
            )
            && resolveReason != null && Constants.CN_COMPLAINT_SOURCE_ECOMMERCE.equals(caseToUpdate.Origin)) 
        {
            caseToUpdate.Status = Constants.CN_CA_STATUS_RESOLVED;
            //Add by Zhang Zhihao 2023/1/14  Return to the submitter
            if(caseToUpdate.CN_Submitter__c!=null){
                caseToUpdate.OwnerId = caseToUpdate.CN_Submitter__c;
            }else{
                caseToUpdate.OwnerId = caseToUpdate.CreatedById;
            }
             //Add by Zhang Zhihao 2023/1/14  Return to the submitter
            caseToUpdate.CN_Resolved_Button__c = true;
            caseToUpdate.CN_Resolve_Description__c = resolveDescription;
            caseToUpdate.CN_Resolve_Reason__c = resolveReason;
            caseToUpdate.CN_Resolve_Comments__c = resolveComments;
            
        }//Add by He Peng Offline resolved => closed
        else if(Constants.CN_CA_STATUS_ACCEPTED.equals(caseToUpdate.Status) 
            && ((!Constants.CN_COMPLAINT_SOURCE_ECOMMERCE.equals(caseToUpdate.Origin)) 
            || Constants.CN_PROFILE_NAME_SALES.equals(myProflieName))
            && (resolveReason != null )){
            caseToUpdate.Status = Constants.CN_CA_STATUS_RESOLVED;
            if(caseToUpdate.CN_Submitter__c!=null){
                caseToUpdate.OwnerId = caseToUpdate.CN_Submitter__c;
            }else{
                caseToUpdate.OwnerId = caseToUpdate.CreatedById;
            }
            caseToUpdate.CN_Resolved_Button__c = true;
            caseToUpdate.CN_Resolve_Description__c = resolveDescription;
            caseToUpdate.CN_Resolve_Reason__c = resolveReason;
            caseToUpdate.CN_Resolve_Comments__c = resolveComments;
            caseToUpdate.CN_Closed_Button__c = true;
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
        //Resolve Description ----by Shuqi
        String defaultDescription = '';

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

        Case complaint = [Select Id,CN_Resolve_Reason__c,CN_Resolve_Comments__c,CN_Resolve_Description__c From Case Where Id =: recordId][0];
        if(complaint!=null){
            defaultReason = complaint.CN_Resolve_Reason__c;
            defaultComment = complaint.CN_Resolve_Comments__c;
            //Resolve Description ----by Shuqi
            defaultDescription = complaint.CN_Resolve_Description__c;
        }
        return new Map<String, Object>{
            'options_Reason' => options_Reason,
            'options_Comment' => options_Comment,
            'defaultReason' => defaultReason,
            'defaultComment' => defaultComment,
            //Resolve Description ----by Shuqi
            'defaultDescription' =>defaultDescription
        };
    }
    
}
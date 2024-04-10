/**************************************************************************************************
 * Name           : CN_Complaint_Rejected_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-08-16
 * Modify History : 
 **************************************************************************************************/
public with sharing class CN_Complaint_Rejected_LC_Ctrl {
    @auraEnabled
    public static Map<String, Object> updateStatusToRejected(String recordId,String rejectReason) {
		
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
                                        //Add by Zhang Zhihao 2023/1/14  Query submitter
                                        CN_Submitter__c,
                                         //Add by Zhang Zhihao 2023/1/14  Query submitter
                                        CreatedById,
                                        Status
                                    FROM Case
                                    WHERE Id =: recordId];
        if(compList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Complaint_Not_Found);
        }
        Case caseToUpdate = compList[0];
        if( Constants.CN_CA_STATUS_ASSIGNED.equals(caseToUpdate.Status)
            && (Constants.CN_PROFILE_NAME_CS.equals(myProflieName) || Constants.CN_PROFILE_NAME_QA.equals(myProflieName) || Constants.CN_PROFILE_NAME_ADMIN.equals(myProflieName) 
            //add by Zhang zhihao Add The food Quality is simplified 2023/12/28
            || Constants.CN_PROFILE_NAME_FOODQUALITY.equals(myProflieName)
            //add by Zhang zhihao Add The food Quality is simplified 2023/12/28
            )) 
        {
            caseToUpdate.Status = Constants.CN_CA_STATUS_REJECTED;
            caseToUpdate.CN_Reject_Datetime__c = System.now();
             //Add by Zhang Zhihao 2023/1/14  Assign the submitter
             //caseToUpdate.OwnerId = caseToUpdate.CreatedById;
             caseToUpdate.OwnerId = caseToUpdate.CN_Submitter__c;
             //Add by Zhang Zhihao 2023/1/14  Assign the submitter
            caseToUpdate.CN_Reject_Reason__c = rejectReason;
        }
        //Add by Zhangzhi hao CS can click the reject button 
        else if(Constants.CN_CA_STATUS_NEW.equals(caseToUpdate.Status)&&Constants.CN_PROFILE_NAME_CS.equals(myProflieName)){
            caseToUpdate.Status = Constants.CN_CA_STATUS_REJECTED;
            caseToUpdate.CN_Reject_Datetime__c = System.now();
            caseToUpdate.CN_Reject_Reason__c = rejectReason;
            //Add by He Peng cs queue=> cs user => closed
            caseToUpdate.CN_Submitter__c = UserInfo.getUserId();
            caseToUpdate.OwnerId = UserInfo.getUserId();
        }
        //Add by Zhangzhi hao CS can click the reject button 
        else{
            throw new AuraHandledException(System.Label.CN_Complaint_Can_Not_Rejected);
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
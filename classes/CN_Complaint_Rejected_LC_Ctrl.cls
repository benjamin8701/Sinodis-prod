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
public without sharing class CN_Complaint_Rejected_LC_Ctrl {
    @auraEnabled
    public static Map<String, Object> updateStatusToRejected(String recordId) {
		
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
                                        Status
                                    FROM Case
                                    WHERE Id =: recordId];
        if(compList.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_Complaint_Not_Found);
        }

        Case caseToUpdate = compList[0];
        if( Constants.CN_CA_STATUS_ASSIGNED.equals(caseToUpdate.Status)
            && (Constants.CN_PROFILE_NAME_CS.equals(myProflieName) || Constants.CN_PROFILE_NAME_QA.equals(myProflieName) || Constants.CN_PROFILE_NAME_ADMIN.equals(myProflieName))) 
        {
            caseToUpdate.Status = Constants.CN_CA_STATUS_REJECTED;
            caseToUpdate.OwnerId = caseToUpdate.CreatedById;
        }else{
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
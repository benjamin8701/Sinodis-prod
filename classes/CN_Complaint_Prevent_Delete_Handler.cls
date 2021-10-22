/**************************************************************************************************
 * Name           : CN_Complaint_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-17
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Complaint_Prevent_Delete_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }
    
    public void handleBeforeDelete() {
        Id complaintRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CN_CA_RT_API_NAME_COMPLAINT).getRecordTypeId();
        List<Case> complaintList = new List<Case>();
        for(Case comp : (List<Case>)Trigger.Old) {
            if(comp.recordTypeId==complaintRTId){
                complaintList.add(comp);
			}
        }
        if(complaintList.size() > 0){
            preventDelete(complaintList);
        }
    }
    
    public void preventDelete(List<Case> complaintList){     
        for(Case comp : complaintList) {
            comp.addError(system.Label.CN_Complaint_Cannot_Be_Delete);
        }
    }
}
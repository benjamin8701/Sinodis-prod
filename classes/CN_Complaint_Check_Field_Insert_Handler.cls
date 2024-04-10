/**************************************************************************************************
 * Name           : CN_Complaint_Check_field_Insert_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2023-11-07
 * Modify History : 
 **************************************************************************************************/
public with sharing class CN_Complaint_Check_Field_Insert_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            beforeInsertHandle();
        }
    }
    //Zhang Zhihao added 2023/12/24
     private void beforeInsertHandle() {       
        
        Set<Id> recordTypeIds = new Set<Id>();
        for (Case cases : (List<Case>)Trigger.new) {
            recordTypeIds.add(cases.RecordTypeId);
        }
    
        Map<Id, String> recordTypeNameMap = new Map<Id, String>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE Id IN :recordTypeIds]) {
            recordTypeNameMap.put(rt.Id, rt.Name);
        }

        for (Case cases : (List<Case>)Trigger.new) {
            //add by He Peng 2024/2/28 service subject
            String RecordTypeName = recordTypeNameMap.get(cases.recordTypeId);
            if(Constants.CN_RECORD_TYPE_COMPLAINT.equals(RecordTypeName)||
            Constants.CN_RECORD_TYPE_Non_Product.equals(RecordTypeName)){
                cases.Subject =cases.CN_Subject__c;
                if(Constants.CN_RECORD_TYPE_COMPLAINT.equals(RecordTypeName)){
                    if(String.isBlank(String.valueOf(cases.Description))){
                        cases.Description = cases.CN_Subject__c;
                    }
                }
            }
        }
    }


}
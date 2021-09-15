/**************************************************************************************************
 * Name           : CN_Contact_Write_Back_To_Lead_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica
 * Create Date    : 2021-07-22
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Contact_Write_Back_To_Lead_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
    }
    
    public void handleAfterInsert() {
        Id crContactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();
        Map<Id,Id> leadContactIdMap = new Map<Id,Id>();

        for(Contact con : (List<Contact>)Trigger.new) {
            if(crContactRTId.equals(con.recordTypeId) && String.isNotBlank(con.CN_Converted_From__c) && String.isNotBlank(con.CN_Change_Request__c)) {
                leadContactIdMap.put(con.CN_Converted_From__c, con.Id);
            }
        }
    
        if (leadContactIdMap.size() > 0) {
            populateLeadContactId(leadContactIdMap);
        }
    }

    public void populateLeadContactId(Map<Id, Id> leadContactIdMap) {
        Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
        Set<Id> leadIds = leadContactIdMap.keySet();
        List<Lead> leadList = [SELECT Id, RecordTypeId, CN_Converted_Contact_Id_From_CR__c FROM Lead WHERE Id in: leadIds And RecordTypeId =: cnLeadRTId];
        List<Lead> leadUpdateList = new List<Lead>();
        if(leadList.size() > 0) {
            for(Lead ldObj: leadList) {
                ldObj.CN_Converted_Contact_Id_From_CR__c = leadContactIdMap.get(ldObj.Id);
                ldObj.Status = Constants.CN_LEAD_STATUS_CLOSED_CONVERTED;
                leadUpdateList.add(ldObj);
            }
        }       
        update leadUpdateList;
    }
}
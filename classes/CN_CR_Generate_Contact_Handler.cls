/**************************************************************************************************
 * Name           : CN_CR_Generate_Contact_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica
 * Create Date    : 2021-05-20
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Generate_Contact_Handler implements Triggers.Handler{
    public static Boolean isTriggerRun = true;
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            if(CN_CR_Generate_Contact_Handler.isTriggerRun) {
                handleBeforeUpdate();
            }
        }
    }
    
    public void handleBeforeUpdate() {
        system.debug('CN_CR_Generate_Contact_Handler.handleAfterUpdate');
        Id crNewContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_NEW_CONTACT).getRecordTypeId();
        List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
        Map<Id, CN_Change_Request__c> crMap = new Map<Id, CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.New) {
            CN_Change_Request__c oldCr = (CN_Change_Request__c)Trigger.oldMap.get(cr.Id);
            if(cr.RecordTypeId == crNewContactRTId && Constants.CN_CR_STATUS_APPROVALED.equals(cr.CN_Change_Request_Status__c) && cr.CN_Change_Request_Status__c != oldCr.CN_Change_Request_Status__c) {
                crList.add(cr);
                crMap.put(cr.Id, cr);
            }
        }
        if(crList.size() > 0) {
            List<Contact> conList = new List<Contact>();
            Map<Id, Contact> conMap = new Map<Id, Contact>();
            conList = generateContacts(crList);
            if(conList.size() > 0) {
                for(Contact con: conList) {
                    conMap.put(con.Id, con);
                }
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true;
                dml.OptAllOrNone = false;
                Database.SaveResult[] srList = Database.insert(conList, dml);
                Set<Id> conSuccessIdSet = new Set<Id>();
                for(Database.SaveResult sr: srList) {
                    if(!sr.isSuccess()) {
                        Trigger.newMap.get(conMap.get(sr.getId()).CN_Change_Request__c).addError(sr.getErrors()[0]?.getMessage());
                    } else {
                        conSuccessIdSet.add(sr.getId());
                    }
                }
                for(Contact con : conList) {
                    if(conSuccessIdSet.contains(con.Id)) {
                        crMap.get(con.CN_Change_Request__c).CN_Contact__c = con.Id;
                        crMap.get(con.CN_Change_Request__c).CN_External_Id__c = con.Id;
                    }
                }
            }
            CN_CR_Generate_Contact_Handler.isTriggerRun = false;
        }
    }
    
    public List<Contact> generateContacts(List<CN_Change_Request__c> crList) {
        Id contactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();
        List<Contact> conList = new List<Contact>();
        for(CN_Change_Request__c cr : crList) {
             Contact con = new Contact(
                 RecordTypeId = contactRTId,
                 CN_Change_Request__c = cr.Id,
                 Title = cr.New_CN_Contact_Title__c,
                 LastName = cr.New_CN_Contact_CN_Last_Name__c,
                 FirstName = cr.New_CN_Contact_CN_First_Name__c,
                 CN_Contact_Name_EN__c = cr.New_CN_Contact_Name_EN__c,
                 MobilePhone = cr.New_CN_Contact_Mobile__c,
                 Email = cr.New_CN_Contact_Email__c,
                 AccountId = cr.New_CN_Contact_License_Name__c,
                 CN_Department_Of_Contact_Person__c = cr.New_CN_Contact_Dept_Of_Contact_Person__c,
                 Phone = cr.New_CN_Contact_Phone_Number__c,
                 CN_Contact_Type__c = cr.New_CN_Contact_Type__c,
                 Birthdate = cr.New_CN_Contact_Birthday__c,
                 CN_Wechat_ID__c = cr.New_CN_Contact_Wechat_ID__c,
                 ReportsToId = cr.New_CN_Contact_Reports_To__c,
                 CN_Family_Info__c = cr.New_CN_Contact_Family_Info__c,
                 CN_Open_Field_To_Comment__c = cr.New_CN_Contact_Open_Field_To_Comment__c,
                 CN_Bill_To_Address__c = cr.New_CN_Contact_Billing_To_Address__c
             );
            conList.add(con);
        }
        return conList;
    }
}
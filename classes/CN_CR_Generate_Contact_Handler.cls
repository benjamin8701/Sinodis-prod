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
                Map<Id, Id> leadIdConIdMap = new Map<Id, Id>();
                for(Contact con : conList) {
                    if(conSuccessIdSet.contains(con.Id)) {
                        crMap.get(con.CN_Change_Request__c).CN_Contact__c = con.Id;
                        crMap.get(con.CN_Change_Request__c).CN_External_Id__c = con.Id;
                        if(String.isNotBlank(con.CN_Converted_From__c)) {
                            leadIdConIdMap.put(con.CN_Converted_From__c, con.Id);
                        }
                    }
                }
                if(leadIdConIdMap.size() > 0) {
                    List<Lead> leadList = new List<Lead>();
                    for(Id leadId: leadIdConIdMap.keySet()) {
                        Lead lead = new Lead();
                        lead.Id = leadId;
                        lead.CN_Converted_Contact_Id_From_CR__c = leadIdConIdMap.get(leadId);
                        lead.Status = Constants.CN_LEAD_STATUS_CLOSED_CONVERTED;
                        leadList.add(lead);
                    }
                    if(leadList.size() > 0) {
                        Database.update(leadList, false);
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
                 // Added By Jessica Wang 2021-07-22 Start
                 CN_Converted_From__c = cr.CN_From_Lead_Id__c,
                 // Added By Jessica Wang 2021-07-22 End
                 // Added By Dezheng Du 2021-08-18 Start
                 CN_Decision_Maker__c = cr.New_CN_Contact_Decision_Maker__c,
                 CN_Working_Language__c = cr.New_CN_Contact_Working_Language__c,
                 // Added By Dezheng Du 2021-08-18 End
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
            //Add by Leo 由Lead入口而来的CR，如果是EC 需要标记。后续Trigger中进行 CS聊天用户信息合并
            if(cr.CN_CR_Source__c == Constants.CN_CR_SOURCE_ECOMMERCE && cr.CN_From_Lead__c != null && cr.New_CN_Contact_MG_Contact_ID__c != null){
                con.CN_Is_Lead_Modify__c = true;
                con.CN_MG_Contact_ID__c = cr.New_CN_Contact_MG_Contact_ID__c;
            }
            //Add by Leo 由Lead入口而来的CR，如果是EC 需要标记。后续Trigger中进行 CS聊天用户信息合并
            conList.add(con);
        }
        return conList;
    }
}
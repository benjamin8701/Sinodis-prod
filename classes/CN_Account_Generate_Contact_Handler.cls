/**************************************************************************************************
 * Name           : CN_Account_Generate_Contact_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-04-29
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Generate_Contact_Handler implements Triggers.Handler {
   public void handle() {
        //if(Trigger.isAfter && Trigger.isInsert) {
        //    handleAfterInsert();
        //}            
    }
/*     public void handleAfterInsert() {
        List<Contact> conList = new List<Contact>();
        Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();
        Id newInDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_INDIRECT).getRecordTypeId();
        List<Account> directAccList = new List<Account>();
        List<Account> inDirectAccList = new List<Account>();
        for(Account acc : (List<Account>)Trigger.New) {
            if(acc.RecordTypeId == newDirectRTId) {
                directAccList.add(acc);
            } else if(acc.RecordTypeId == newInDirectRTId) {
                inDirectAccList.add(acc);
            }
        }
        if(directAccList.size() > 0) {
        	List<Contact> directConList = new List<Contact>();
            directConList = generateContactsForDirectAccount(directAccList);
            if(directConList.size() > 0) {
				conList.addAll(directConList);
            }
        }
        if(inDirectAccList.size() > 0) {
        	List<Contact> inDirectConList = new List<Contact>();
            inDirectConList = generateContactsForInDirectAccount(inDirectAccList);
            if(inDirectConList.size() > 0) {
				conList.addAll(inDirectConList);
            }
        }
        if(conList.size() > 0) {
            insert conList;
        }
    }
    
    public List<Contact> generateContactsForDirectAccount(List<Account> accList) {
        List<Contact> conList = new List<Contact>();
        for(Account acc : accList) {
            if(acc.CN_Billing_Contact_Name_CN_First_Name__c == acc.CN_Purchasing_Contact_Name_CN_First_Name__c
              	&& acc.CN_Billing_Contact_Name_CN_Last_Name__c == acc.CN_Purchasing_Contact_Name_CN_Last_Name__c
                && acc.CN_Billing_Contact_Name_EN__c == acc.CN_Purchasing_Contact_Name_EN__c
                && acc.CN_Billing_Department_of_Contact_Person__c == acc.CN_Purchasing_Department_of_Contact__c
                && acc.CN_Billing_Mobile_Phone__c == acc.CN_Purchasing_Mobile_Phone__c
                && acc.CN_Billing_Email__c == acc.CN_Purchasing_Email__c
                && acc.CN_Billing_Phone_Number__c == acc.CN_Purchasing_Phone_Number__c) {
                	Contact con = new Contact(
                    	AccountId = acc.Id,
                        FirstName = acc.CN_Billing_Contact_Name_CN_First_Name__c,
                        LastName = acc.CN_Billing_Contact_Name_CN_Last_Name__c,
                        CN_Contact_Name_EN__c = acc.CN_Billing_Contact_Name_EN__c,
                        CN_Department_Of_Contact_Person__c = acc.CN_Billing_Department_of_Contact_Person__c,
                        CN_Contact_Type__c = '01;02',
                        Phone = acc.CN_Billing_Phone_Number__c,
                        MobilePhone = acc.CN_Billing_Mobile_Phone__c
                    );
                    conList.add(con);
                } else {
                	Contact billingCon = new Contact(
                    	AccountId = acc.Id,
                        FirstName = acc.CN_Billing_Contact_Name_CN_First_Name__c,
                        LastName = acc.CN_Billing_Contact_Name_CN_Last_Name__c,
                        CN_Contact_Name_EN__c = acc.CN_Billing_Contact_Name_EN__c,
                        CN_Department_Of_Contact_Person__c = acc.CN_Billing_Department_of_Contact_Person__c,
                        CN_Contact_Type__c = '01',
                        Phone = acc.CN_Billing_Phone_Number__c,
                        MobilePhone = acc.CN_Billing_Mobile_Phone__c,
                        Email = acc.CN_Billing_Email__c
                    );
                    conList.add(billingCon);
                	Contact purchasingCon = new Contact(
                    	AccountId = acc.Id,
                        FirstName = acc.CN_Purchasing_Contact_Name_CN_First_Name__c,
                        LastName = acc.CN_Purchasing_Contact_Name_CN_Last_Name__c,
                        CN_Contact_Name_EN__c = acc.CN_Purchasing_Contact_Name_EN__c,
                        CN_Department_Of_Contact_Person__c = acc.CN_Purchasing_Department_of_Contact__c,
                        CN_Contact_Type__c = '02',
                        Phone = acc.CN_Purchasing_Phone_Number__c,
                        MobilePhone = acc.CN_Purchasing_Mobile_Phone__c,
                        Email = acc.CN_Purchasing_Email__c
                    );
                    conList.add(purchasingCon);
                }
        }
        return conList;
    }
    public List<Contact> generateContactsForInDirectAccount(List<Account> accList) {
        List<Contact> conList = new List<Contact>();
		for(Account acc : accList) {
            Contact con = new Contact(
                AccountId = acc.Id,
                FirstName = acc.CN_Contact_Name_CN_First_Name__c,
                LastName = acc.CN_Contact_Name_CN_Last_Name__c,
                CN_Contact_Name_EN__c = acc.CN_Contact_Name_EN__c,
                CN_Department_Of_Contact_Person__c = acc.CN_Department_of_Contact_Person__c,
                CN_Contact_Type__c = '04',
                Phone = acc.CN_Contact_Phone_Number__c,
                MobilePhone = acc.CN_Contact_Mobile_Phone__c
            );
            conList.add(con);
        }
        return conList;
    }*/
}
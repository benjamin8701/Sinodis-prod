/**************************************************************************************************
 * Name           : CN_Chefs_Assigned_Chef_UT_Item_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-12-28
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chefs_Assigned_Chef_UT_Item_Handler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
        if(Trigger.isAfter && Trigger.isUndelete) {
            handleAfterInsert();
        }
    }

    public void handleBeforeDelete() {
        CN_Chefs_Assigned_Chef_UT_Item_Biz biz = new CN_Chefs_Assigned_Chef_UT_Item_Biz();
        List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();
        for(CN_Chefs_Assigned__c ca: (List<CN_Chefs_Assigned__c>)Trigger.old) {
            if(!'OFF'.equals(ca.CN_Self_Work_Type__c)) {
                caList.add(ca);
            }
        }
        if(caList.size() > 0) {
            biz.cleanChefUTItems(caList);
        }
    }

    public void handleAfterInsert() {
        CN_Chefs_Assigned_Chef_UT_Item_Biz biz = new CN_Chefs_Assigned_Chef_UT_Item_Biz();
        List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();
        for(CN_Chefs_Assigned__c ca: (List<CN_Chefs_Assigned__c>)Trigger.new) {
            if(!'OFF'.equals(ca.CN_Self_Work_Type__c)) {
                caList.add(ca);
            }
        }
        if(caList.size() > 0) {
            List<CN_Chef_UT_Item__c> cuiList = biz.generateChefUTItems(caList);
            if(cuiList.size() > 0) {
                insert cuiList;
            }
        }
    }

    public void handleAfterUpdate() {
        CN_Chefs_Assigned_Chef_UT_Item_Biz biz = new CN_Chefs_Assigned_Chef_UT_Item_Biz();
        List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();
        for(CN_Chefs_Assigned__c ca: (List<CN_Chefs_Assigned__c>)Trigger.new) {
            CN_Chefs_Assigned__c oldCa = (CN_Chefs_Assigned__c)Trigger.oldMap.get(ca.Id);
            if(!'OFF'.equals(ca.CN_Self_Work_Type__c) && (oldCa.CN_Chef_Work_Start_Date__c != ca.CN_Chef_Work_Start_Date__c || oldCa.CN_Chef_Work_End_Date__c != ca.CN_Chef_Work_End_Date__c)) {
                caList.add(ca);
            }
        }
        if(caList.size() > 0) {
            biz.cleanChefUTItems(caList);
            List<CN_Chef_UT_Item__c> cuiList = biz.generateChefUTItems(caList);
            if(cuiList.size() > 0) {
                insert cuiList;
            }
        }
    }
}
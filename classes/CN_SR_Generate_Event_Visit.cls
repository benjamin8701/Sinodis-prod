/**************************************************************************************************
 * Name           : CN_SR_Generate_Event_Visit
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Jessica Wang
 * Create Date    : 2021-08-11
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_SR_Generate_Event_Visit implements Triggers.Handler{
    Set<Id> cnRTIdSet = new Set<Id>();
    Id cnOfficeRepackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_OFFICE_REPACK_RT_API_NAME).getRecordTypeId();
    Id cnWholePackRTId = Schema.SObjectType.CN_Sample_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SR_WHOLE_PACK_RT_API_NAME).getRecordTypeId();
    Id taskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(Constants.CN_TASK_RT_API_NAME).getRecordTypeId();
    
    public void handle() {
        this.cnRTIdSet.add(this.cnOfficeRepackRTId);
        this.cnRTIdSet.add(this.cnWholePackRTId);
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        } else if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }        
    }
    public void handleAfterInsert() {
        List<CN_Sample_Request__c> srList = new List<CN_Sample_Request__c>();
        for(CN_Sample_Request__c sr : (List<CN_Sample_Request__c>)Trigger.new) {
            if(cnRTIdSet.contains(sr.RecordTypeId)) {
                srList.add(sr);
            }
        }
        if(srList.size() > 0) {
            generateEventVisit(srList);           
        }
    }
    public void handleAfterUpdate() {
        List<CN_Sample_Request__c> srList = new List<CN_Sample_Request__c>();
        for(CN_Sample_Request__c sr : (List<CN_Sample_Request__c>)Trigger.new) {
            CN_Sample_Request__c oldSr = (CN_Sample_Request__c)Trigger.oldMap.get(sr.Id);
            if(cnRTIdSet.contains(sr.RecordTypeId)) {
                if(sr.CN_SP_Records_Count_Delivery_Status_All__c != oldSr.CN_SP_Records_Count_Delivery_Status_All__c) {
                    srList.add(sr);
                }
            }
        }
        if(srList.size() > 0) {
            generateEventVisit(srList);
        }
    }
    public void generateEventVisit(List<CN_Sample_Request__c> srList) {
        List<Task> taskNewList = new List<Task>();
        for(CN_Sample_Request__c sr : srList) {
            if(sr.CN_SP_Records_Count_Delivery_Status_All__c == sr.CN_SP_Records_Count_All__c && sr.CN_SP_Records_Count_Delivery_Status_Done__c >= 1) {
                Task taskObj14 = new Task(
                    RecordTypeId = taskRTId,
                    Subject = 'Sample Feedback Reminder',
                    OwnerId = sr.OwnerId,
                    WhatId = sr.Id,
                    Status = 'Open',
                    Priority = 'Normal',
                    ActivityDate = sr.CN_Sample_Needed_Date__c + 14,
                    IsReminderSet = true,
                    ReminderDateTime  = sr.CN_Sample_Needed_Date__c + 13
                );
                taskNewList.add(taskObj14);
                Task taskObj5 = new Task(
                    RecordTypeId = taskRTId,
                    Subject = 'Sample Feedback Reminder',
                    OwnerId = sr.OwnerId,
                    WhatId = sr.Id,
                    Status = 'Open',
                    Priority = 'Normal',
                    ActivityDate = sr.CN_Sample_Needed_Date__c + 5,
                    IsReminderSet = true,
                    ReminderDateTime  = sr.CN_Sample_Needed_Date__c + 4
                );
                taskNewList.add(taskObj5);
            }
        }
        insert taskNewList;
    }
}
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
    Id eventRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EVENT_RT_API_NAME).getRecordTypeId();
    Id visitRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_VISIT_RT_API_NAME).getRecordTypeId();
    public void handle() {
        this.cnRTIdSet.add(this.cnOfficeRepackRTId);
        this.cnRTIdSet.add(this.cnWholePackRTId);
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }        
    }
    public void handleBeforeInsert() {
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
    public void handleBeforeUpdate() {
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
        List<Event> etNewList = new List<Event>();
        for(CN_Sample_Request__c sr : srList) {
            if(sr.CN_SP_Records_Count_Delivery_Status_All__c == sr.CN_SP_Records_Count_All__c && sr.CN_SP_Records_Count_Delivery_Status_Done__c >= 1) {
                Event eventObj7 = new Event(
                    RecordTypeId = eventRTId,
                    Subject = String.format(System.Label.CN_Create_Event_Subject,new List<String>{sr.Name}),
                    OwnerId = sr.OwnerId,
                    WhatId = sr.CN_Account_Name__c,
                    Type = 'Others',
                    IsAllDayEvent = true,
                    StartDateTime = sr.CN_Sample_Needed_Date__c + 7,
                    EndDateTime = sr.CN_Sample_Needed_Date__c + 7,
                    CN_Sample_Request__c = sr.Id                   
                );
                etNewList.add(eventObj7);
                Event eventObj14 = new Event(
                    RecordTypeId = eventRTId,
                    Subject = String.format(System.Label.CN_Create_Event_Subject,new List<String>{sr.Name}),
                    OwnerId = sr.OwnerId,
                    WhatId = sr.CN_Account_Name__c,
                    Type = 'Others',
                    IsAllDayEvent = true,
                    StartDateTime = sr.CN_Sample_Needed_Date__c + 14,
                    EndDateTime = sr.CN_Sample_Needed_Date__c + 14,
                    CN_Sample_Request__c = sr.Id
                );
                etNewList.add(eventObj14);
                Event visitObj = new Event(
                    RecordTypeId = visitRTId,
                    Subject = System.Label.CN_Create_Visit_Subject,
                    OwnerId = sr.OwnerId,
                    WhatId = sr.CN_Account_Name__c,
                    Type = 'Visit',
                    IsAllDayEvent = true,
                    StartDateTime = sr.CN_Sample_Needed_Date__c + 5,
                    EndDateTime = sr.CN_Sample_Needed_Date__c + 5,
                    CN_Sample_Request__c = sr.Id                   
                );
                etNewList.add(visitObj);
            }
        }
        insert etNewList;
    }
}
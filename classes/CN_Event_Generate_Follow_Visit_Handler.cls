/**************************************************************************************************
 * Name           : CN_Event_Generate_Follow_Visit_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-24
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Event_Generate_Follow_Visit_Handler implements Triggers.Handler{
    
	public void handle() {
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }
    
    public void handleAfterInsert() {
        Id visitRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EV_RT_API_NAME_NEW).getRecordTypeId();

        List<Event> generateEventList = new List<Event>();

        for(Event visit : (List<Event>)Trigger.New) {
            if(visitRTId.equals(visit.recordTypeId) && visit.CN_By_when__c != null){
                generateEventList.add(visit);
            }
        }
        if (generateEventList.size()>0) {
            generateFollowUpVisit(generateEventList);
        }
    }

    public void handleAfterUpdate() {
        Id visitRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EV_RT_API_NAME_NEW).getRecordTypeId();

        List<Event> generateEventList = new List<Event>();
        for(Event visit : (List<Event>)Trigger.New) {
            if(visitRTId.equals(visit.recordTypeId) 
                && visit.CN_By_when__c != ((Event)Trigger.OldMap.get(visit.Id)).CN_By_when__c 
                && visit.CN_By_when__c != null){
                if( ((Event)Trigger.OldMap.get(visit.Id)).CN_By_when__c == null){
                    generateEventList.add(visit);
                }
            }
            
        }
        if (generateEventList.size()>0) {
            generateFollowUpVisit(generateEventList);
        }
    }


    public void generateFollowUpVisit(List<Event> generateEventList) {
        Id visitRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EV_RT_API_NAME_NEW).getRecordTypeId();

        Map<String,Integer> byWhenStringWeekNumIntegerMap = new Map<String,Integer>();
        byWhenStringWeekNumIntegerMap.put(Constants.CN_EV_By_WHEN_ONE,7);
        byWhenStringWeekNumIntegerMap.put(Constants.CN_EV_By_WHEN_TWO,14);
        byWhenStringWeekNumIntegerMap.put(Constants.CN_EV_By_WHEN_THREE,21);

        Set<Id> accIdSet = new Set<Id>();
        for(Event visit : generateEventList){
            accIdSet.add(visit.AccountId);
        }

        List<Account> accList = [Select Id,Name From Account Where Id IN: accIdSet];
        Map<Id,String> accIdAccountNameStringName = new Map<Id,String>();
        for(Account acc : accList){
            accIdAccountNameStringName.put(acc.Id, acc.Name);
        }

        List<Event> newEventList = new List<Event>();
        for(Event visit : generateEventList){
            Event e = new Event();
            e.recordTypeId = visitRTId;
            if(visit.CN_Sample_Request__c != null){
                e.subject = System.label.CN_Event_Follow_Visit_Subject_SR + ' ' + accIdAccountNameStringName.get(visit.AccountId);
                e.CN_Sample_Request__c = visit.CN_Sample_Request__c;
            }else{
                e.subject = visit.subject;
            }
            e.StartDateTime = visit.StartDateTime.addDays(byWhenStringWeekNumIntegerMap.get(visit.CN_By_when__c));
            e.EndDateTime = visit.EndDateTime.addDays(byWhenStringWeekNumIntegerMap.get(visit.CN_By_when__c));
            e.CN_Visit_Status__c = Constants.CN_EV_VISIT_STATUS_PLANNED;
            e.WhoId = visit.WhoId;
            e.IsAllDayEvent = true;
            e.IsReminderSet = true;
            e.ReminderDateTime  = visit.StartDateTime.addDays(byWhenStringWeekNumIntegerMap.get(visit.CN_By_when__c)-1);
            e.CN_Time_Before_Event__c = Constants.CN_EV_TIME_BEFORE_EVENT_PLANNED;
            e.CN_Plan_to_Visit_Who__c = visit.CN_Plan_to_Visit_Who__c;
            e.WhatId = visit.WhatId;
            newEventList.add(e);
        }
        if(newEventList.size()>0){
            insert newEventList;
        }
    }
}
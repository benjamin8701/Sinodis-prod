/**************************************************************************************************
 * Name           : CN_Chef_Assigned_Reset_WorkDate_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-10-29
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chef_Assigned_Reset_WorkDate_Handler implements Triggers.Handler {
    Set<Id> cnRTIdSet = new Set<Id>();

    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }

    public void handleAfterUpdate() {

        List<CN_Chefs_Assigned__c> udpateEventList = new List<CN_Chefs_Assigned__c>();
        List<CN_Chefs_Assigned__c> updateTaskList = new List<CN_Chefs_Assigned__c>();

        for(CN_Chefs_Assigned__c ca : (List<CN_Chefs_Assigned__c>)Trigger.new) {
            CN_Chefs_Assigned__c oldCa = (CN_Chefs_Assigned__c)Trigger.oldMap.get(ca.Id);
            if(ca.CN_Is_Chef_Request_Confirmed__c && oldCa.CN_Is_Chef_Request_Confirmed__c) {
                if(ca.CN_Chef_Work_Start_Date__c != oldCa.CN_Chef_Work_Start_Date__c || ca.CN_Chef_Work_End_Date__c != oldCa.CN_Chef_Work_End_Date__c){
                    udpateEventList.add(ca);
                }
            }
        }
        List<Event> eventList = getUpdateEvents(udpateEventList);

        if(eventList.size()>0){
            update eventList;
        }
    }

    public List<Event> getUpdateEvents(List<CN_Chefs_Assigned__c> udpateEventList) {
        List<Event> eventList = new List<Event>();
        List<Event> eventList_update = new List<Event>();
        Map<Id,Date> chefAssignedIdWorkEndDateMap = new Map<Id,Date>();
        Map<Id,Date> chefAssignedIdWorkStartDateMap = new Map<Id,Date>();

        if(udpateEventList.size() > 0) {
            Set<Id> caIdSet = new Set<Id>();
            for(CN_Chefs_Assigned__c ca: udpateEventList) {
                caIdSet.add(ca.Id);
                chefAssignedIdWorkEndDateMap.put(ca.Id,ca.CN_Chef_Work_End_Date__c);
                chefAssignedIdWorkStartDateMap.put(ca.Id,ca.CN_Chef_Work_Start_Date__c);
            }
            if(caIdSet.size() > 0) {
                eventList = [SELECT Id, CN_Chefs_Assigned__c FROM Event WHERE CN_Chefs_Assigned__c in: caIdSet];
            }
        }
        for(Event evt : eventList){
            Date workEndDate = chefAssignedIdWorkEndDateMap.get(evt.CN_Chefs_Assigned__c);
            Date workStartDate = chefAssignedIdWorkStartDateMap.get(evt.CN_Chefs_Assigned__c);
            Date endDate = workEndDate.addDays(-1);
            Event event_update = new Event();
            event_update.Id = evt.Id;
            event_update.ReminderDateTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 8, 0, 0);
            event_update.StartDateTime = workStartDate;
            event_update.EndDateTime = workEndDate;
            eventList_update.add(event_update);
        }
        return eventList_update;
    }

}
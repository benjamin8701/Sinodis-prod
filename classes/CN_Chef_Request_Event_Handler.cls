/**************************************************************************************************
 * Name           : CN_Chef_Request_Event_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chef_Request_Event_Handler implements Triggers.Handler {
    Set<Id> cnRTIdSet = new Set<Id>();
    Id chefRequest1on1RTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_1ON1_RT_API_NAME).getRecordTypeId();
    Id chefRequestChefDemoRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_CHEF_DEMO_RT_API_NAME).getRecordTypeId();
    Id chefRequestMKTDEVRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_MKT_DEV_RT_API_NAME).getRecordTypeId();

    public void handle() {
        this.cnRTIdSet.add(this.chefRequest1on1RTId);
        this.cnRTIdSet.add(this.chefRequestChefDemoRTId);
        this.cnRTIdSet.add(this.chefRequestMKTDEVRTId);

        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }

    }

    public void handleAfterUpdate() {

        List<CN_Chef_Request__c> createEventList = new List<CN_Chef_Request__c>();
        List<CN_Chef_Request__c> deleteEventList = new List<CN_Chef_Request__c>();

        for(CN_Chef_Request__c cr : (List<CN_Chef_Request__c>)Trigger.new) {
            CN_Chef_Request__c oldCr = (CN_Chef_Request__c)Trigger.oldMap.get(cr.Id);
            if(cnRTIdSet.contains(cr.RecordTypeId)) {
                if(cr.CN_Confirmed__c && !oldCr.CN_Confirmed__c) {
                    createEventList.add(cr);
                } else if(!cr.CN_Confirmed__c && oldCr.CN_Confirmed__c) {
                    deleteEventList.add(cr);
                }
            }

        }
        if(createEventList.size() > 0) {
            List<Event> eventList = makeCreateEvents(createEventList);
            if(eventList.size() > 0) {
                insert eventList;
            }
        }

        if(deleteEventList.size() > 0) {
            List<Event> eventList = getDeleteEvents(deleteEventList);
            if(eventList.size() > 0) {
                delete eventList;
            }
        }
    }

    public List<Event> makeCreateEvents(List<CN_Chef_Request__c> createEventList) {
        List<Event> eventList = new List<Event>();
        Id chefRequestMKTDEVRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EVENT_RT_API_NAME).getRecordTypeId();
        Set<Id> crIdSet = new Set<Id>();
        if(createEventList.size() > 0) {
            for(CN_Chef_Request__c cr : createEventList) {
                if(cr.RecordTypeId == chefRequest1on1RTId) {
                    Event evt = new Event();
                    evt.RecordTypeId = chefRequestMKTDEVRTId;
                    evt.OwnerId = cr.OwnerId;
                    evt.CN_Chef_Request_Id__c = cr.Id;
                    evt.CN_Chef_Request__c = cr.Id;
                    evt.Subject = cr.CN_Account_Name__c == null? cr.CN_Campaign_Name__c: cr.CN_Account_Name__c + ' ' + cr.CN_Event_Type__c + ' ' + cr.CN_Owner_Name__c;
                    evt.IsReminderSet = true;
                    evt.Type = 'Demo';
                    evt.IsAllDayEvent = true;
                    evt.Location = cr.CN_Event_Location__c;
                    Date endDate = cr.CN_Demo_End_Date__c.addDays(-1);
                    evt.ReminderDateTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 8, 0, 0);
                    evt.StartDateTime = cr.CN_Demo_Start_Date__c;
                    evt.EndDateTime = cr.CN_Demo_End_Date__c;
                    evt.WhatId = cr.CN_Account__c;
                    eventList.add(evt);
                }
                if(cnRTIdSet.contains(cr.RecordTypeId)) {
                    crIdSet.add(cr.Id); 
                }
            }
            if(crIdSet.size() > 0) {
                List<CN_Chefs_Assigned__c> caList = [SELECT Id, 
                                                            CN_Chef_Request__c, 
                                                            CN_Chef_Request__r.CN_Account_Name__c,
                                                            CN_Chef_Request__r.CN_Campaign_Name__c, 
                                                            CN_Chef_Request__r.CN_Event_Type__c, 
                                                            CN_Chef_Request__r.CN_Event_Location__c, 
                                                            CN_Chef_Request__r.CN_Demo_Start_Date__c, 
                                                            CN_Chef_Request__r.CN_Demo_End_Date__c, 
                                                            CN_Chef_Request__r.CN_Account__c, 
                                                            CN_Chef_Request__r.CN_Campaign__c,
                                                            CN_Chef_Request__r.RecordTypeId,
                                                            CN_Chef__c,
                                                            CN_Chef_Name__c,
                                                            CN_Display_in_Calendar__c,
                                                            CN_Chef_Work_Start_Date__c,
                                                            CN_Chef_Work_End_Date__c
                                                        FROM CN_Chefs_Assigned__c 
                                                        WHERE CN_Chef_Request__c in: crIdSet
                                                        LIMIT 50000];
                if(caList.size() > 0) {
                    for(CN_Chefs_Assigned__c ca : caList) {
                        Event evt = new Event();
                        evt.RecordTypeId = chefRequestMKTDEVRTId;
                        evt.OwnerId = ca.CN_Chef__c;
                        evt.CN_Chef_Request_Id__c = ca.CN_Chef_Request__c;
                        evt.CN_Chef_Request__c = ca.CN_Chef_Request__c;
                        evt.Subject = ca.CN_Display_in_Calendar__c;
                        evt.IsReminderSet = true;
                        evt.Type = 'Demo';
                        evt.IsAllDayEvent = true;
                        evt.Location = ca.CN_Chef_Request__r.CN_Event_Location__c;
                        Date endDate = ca.CN_Chef_Work_End_Date__c.addDays(-1);
                        evt.ReminderDateTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 8, 0, 0);
                        evt.StartDateTime = ca.CN_Chef_Work_Start_Date__c;
                        evt.EndDateTime = ca.CN_Chef_Work_End_Date__c;
                        evt.WhatId = ca.CN_Chef_Request__r.CN_Account__c == null? ca.CN_Chef_Request__r.CN_Campaign__c: ca.CN_Chef_Request__r.CN_Account__c;
                        eventList.add(evt);

                        evt = new Event();
                        evt.RecordTypeId = chefRequestMKTDEVRTId;
                        evt.OwnerId = ca.CN_Chef__c;
                        evt.CN_Chef_Request_Id__c = ca.CN_Chef_Request__c;
                        evt.Subject = 'Demo Report Upload Reminder 1 : ' + ca.CN_Display_in_Calendar__c;
                        evt.IsReminderSet = true;
                        evt.Type = 'Demo';
                        evt.IsAllDayEvent = true;
                        endDate = ca.CN_Chef_Request__r.CN_Demo_End_Date__c.addDays(6);
                        evt.ReminderDateTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 8, 0, 0);
                        evt.StartDateTime = ca.CN_Chef_Request__r.CN_Demo_End_Date__c.addDays(7);
                        evt.EndDateTime = ca.CN_Chef_Request__r.CN_Demo_End_Date__c.addDays(7);
                        evt.WhatId = ca.CN_Chef_Request__c;
                        eventList.add(evt);

                        evt = new Event();
                        evt.RecordTypeId = chefRequestMKTDEVRTId;
                        evt.OwnerId = ca.CN_Chef__c;
                        evt.CN_Chef_Request_Id__c = ca.CN_Chef_Request__c;
                        evt.Subject = 'Demo Report Upload Reminder 2 : ' + ca.CN_Display_in_Calendar__c;
                        evt.IsReminderSet = true;
                        evt.Type = 'Demo';
                        evt.IsAllDayEvent = true;
                        evt.Location = ca.CN_Chef_Request__r.CN_Event_Location__c;
                        endDate = ca.CN_Chef_Request__r.CN_Demo_End_Date__c.addDays(13);
                        evt.ReminderDateTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 8, 0, 0);
                        evt.StartDateTime = ca.CN_Chef_Request__r.CN_Demo_End_Date__c.addDays(14);
                        evt.EndDateTime = ca.CN_Chef_Request__r.CN_Demo_End_Date__c.addDays(14);
                        evt.WhatId = ca.CN_Chef_Request__c;
                        eventList.add(evt);
                    }
                }
            }
        }
        return eventList;
    }

    public List<Event> getDeleteEvents(List<CN_Chef_Request__c> deleteEventList) {
        List<Event> eventList = new List<Event>();
        if(deleteEventList.size() > 0) {
            Set<Id> crIdSet = new Set<Id>();
            for(CN_Chef_Request__c cr: deleteEventList) {
                crIdSet.add(cr.Id);
            }
            if(crIdSet.size() > 0) {
                eventList = [SELECT Id, CN_Chef_Request_Id__c FROM Event WHERE CN_Chef_Request_Id__c in: crIdSet];
            }
        }
        return eventList;
    }
}
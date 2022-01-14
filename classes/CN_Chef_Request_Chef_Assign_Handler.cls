/**************************************************************************************************
 * Name           : CN_Chef_Request_Chef_Assign_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-27
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chef_Request_Chef_Assign_Handler implements Triggers.Handler {

    public void handle() {
        if(Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
    }

    public void handleAfterUpdate() {

        List<CN_Chef_Request__c> confirmCRList = new List<CN_Chef_Request__c>();
        List<CN_Chef_Request__c> unConfirmCRList = new List<CN_Chef_Request__c>();
        List<Event> eventList = new List<Event>();

        Id chefRequestChefSelfRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_CHEF_SELF_RT_API_NAME).getRecordTypeId();
        Id chefRequestMKTDEVRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EVENT_RT_API_NAME).getRecordTypeId();

        for(CN_Chef_Request__c cr: (List<CN_Chef_Request__c>)Trigger.new) {
            if(cr.RecordTypeId == chefRequestChefSelfRTId) {
                CN_Chef_Request__c oldCr = (CN_Chef_Request__c)Trigger.oldMap.get(cr.Id);
                if(!oldCr.CN_Confirmed__c && cr.CN_Confirmed__c) {
                    confirmCRList.add(cr);
                } else if(oldCr.CN_Confirmed__c && !cr.CN_Confirmed__c) {
                    unConfirmCRList.add(cr);
                }
            }
        }

        if(confirmCRList.size() > 0) {
            Id caSelfWorkRTId = Schema.SObjectType.CN_Chefs_Assigned__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEFS_ASSIGNED_SELF_WORK_RT_API_NAME).getRecordTypeId();
            List<CN_Chefs_Assigned__c> caList = generateChefAssignList(confirmCRList, caSelfWorkRTId);
            if(caList.size() > 0) {
                upsert caList CN_External_Id__c;

                List<CN_Chefs_Assigned__c> caListAfterUpsert = [SELECT Id, 
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
                                                            CN_Chef_Request__r.RecordType.Name,
                                                            CN_Chef__c,
                                                            CN_Chef_Name__c,
                                                            CN_Display_in_Calendar__c,
                                                            CN_Chef_Work_Start_Date__c,
                                                            CN_Chef_Work_End_Date__c,
                                                            CN_Chef_Work_Start_Date_AM_PM__c,
                                                            CN_Chef_Work_End_Date_AM_PM__c
                                                        FROM CN_Chefs_Assigned__c 
                                                        WHERE CN_Chef_Request__c in: confirmCRList
                                                        LIMIT 50000];

                for(CN_Chefs_Assigned__c ca: caListAfterUpsert) {
                    Event evt = new Event();
                    evt.RecordTypeId = chefRequestMKTDEVRTId;
                    evt.OwnerId = ca.CN_Chef__c;
                    evt.CN_Chef_Request_Id__c = ca.CN_Chef_Request__c;
                    evt.CN_Chef_Request__c = ca.CN_Chef_Request__c;
                    evt.Subject = ca.CN_Chef_Request__r.RecordType.Name + '-' + ca.CN_Chef_Request__r.CN_Event_Type__c + '-' + ca.CN_Chef_Name__c;
                    evt.IsReminderSet = true;
                    evt.Type = 'Chef Self Work';
                    evt.IsAllDayEvent = true;
                    Date endDate = ca.CN_Chef_Work_End_Date__c.addDays(-1);
                    evt.ReminderDateTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 8, 0, 0);
                    if('PM'.equals(ca.CN_Chef_Work_Start_Date_AM_PM__c)) {
                        evt.StartDateTime = Datetime.newInstance(ca.CN_Chef_Work_Start_Date__c, Time.newInstance(12, 0, 0, 0));
                    } else {
                        evt.StartDateTime = ca.CN_Chef_Work_Start_Date__c;
                    }
                    if('AM'.equals(ca.CN_Chef_Work_End_Date_AM_PM__c)) {
                        evt.EndDateTime = Datetime.newInstance(ca.CN_Chef_Work_End_Date__c, Time.newInstance(12, 0, 0, 0));
                    } else {
                        evt.EndDateTime = ca.CN_Chef_Work_End_Date__c;
                    }
                    evt.WhatId = ca.CN_Chef_Request__c;
                    eventList.add(evt);
                }
                if(eventList.size() > 0) {
                    insert eventList;
                }
            }
        }
        if(unConfirmCRList.size() > 0) {
            Set<Id> crIdSet = new Set<Id>();
            for(CN_Chef_Request__c cr: unConfirmCRList) {
                crIdSet.add(cr.Id);
            }
            if(crIdSet.size() > 0) {
                eventList = [SELECT Id, CN_Chef_Request_Id__c FROM Event WHERE CN_Chef_Request_Id__c in: crIdSet];
            }
            if(eventList.size() > 0) {
                delete eventList;
            }
            List<CN_Chefs_Assigned__c> caList = getDeleteChefAssignList(unConfirmCRList);
            if(caList.size() > 0) {
                delete caList;
            }
        }
    }

    public List<CN_Chefs_Assigned__c> generateChefAssignList(List<CN_Chef_Request__c> confirmCRList, String caRTId) {
        
        List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();

        if(confirmCRList.size() > 0) {
            for(CN_Chef_Request__c cr: confirmCRList) {
                CN_Chefs_Assigned__c ca = new CN_Chefs_Assigned__c();
                ca.RecordTypeId = caRTId;
                ca.CN_Chef_Request__c = cr.Id;
                ca.CN_Chef__c = cr.OwnerId;
                ca.CN_Chef_Role__c = 'Leading Chef';
                ca.CN_Chef_Work_Start_Date__c = cr.CN_Start_Date__c;
                ca.CN_Chef_Work_Start_Date_AM_PM__c = cr.CN_Start_Date_AM_PM__c;
                ca.CN_Chef_Work_End_Date__c = cr.CN_End_Date__c;
                ca.CN_Chef_Work_End_Date_AM_PM__c = cr.CN_End_Date_AM_PM__c;
                ca.CN_External_Id__c = cr.Id + '-' + cr.OwnerId;
                ca.CN_Chef_Self_Confirm_Time__c = Datetime.now();
                ca.CN_Upsert_From_Apex_DateTime__c = DateTime.now();
                ca.CN_Self_Work_Type__c = cr.CN_Event_Type__c;
                System.debug('cr.CN_Event_Type__c');
                System.debug(cr.CN_Event_Type__c);
                caList.add(ca);
            }
        }

        return caList;
    }

    public List<CN_Chefs_Assigned__c> getDeleteChefAssignList(List<CN_Chef_Request__c> unConfirmCRList) {
        
        List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();

        if(unConfirmCRList.size() > 0) {
            Set<Id> crIdSet = new Set<Id>();
            for(CN_Chef_Request__c cr: unConfirmCRList) {
                crIdSet.add(cr.Id);
            }
            if(crIdSet.size() > 0) {
                caList = [SELECT Id, CN_Chef_Request__c FROM CN_Chefs_Assigned__c WHERE CN_Chef_Request__c in: crIdSet];
            }
        }

        return caList;
    }
}
/**************************************************************************************************
 * Name           : CN_Event_Prevent_Delete_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-08-27
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Event_Prevent_Delete_Handler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
    }

    public void handleBeforeDelete() {
        Id visitRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EV_RT_API_NAME_NEW).getRecordTypeId();
        Id eventRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Constants.CN_EV_RT_API_NAME_EVENT).getRecordTypeId();
        Set<Id> cnRTIdSet = new Set<Id>();
        cnRTIdSet.add(visitRTId);
        cnRTIdSet.add(eventRTId);

        List<Event> preventDeleteList = new List<Event>();
        for(Event e : (List<Event>)Trigger.Old) {
            if(cnRTIdSet.contains(e.recordTypeId) ){
                preventDeleteList.add(e);
            }
        }
        if(preventDeleteList.size()>0){
            preventDeleteEvent(preventDeleteList);
        }
    }

    public void preventDeleteEvent(List<Event> preventDeleteList){
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String myProflieName = profileList[0].Name;
        for(Event e : preventDeleteList){
            if(Constants.CN_PROFILE_NAME_SALESLEADER.equals(myProflieName) ){
                e.addError(System.label.CN_Event_Prevent_Delete);
            }
        }
    }
}
/**************************************************************************************************
 * Name           : CN_Demo_Report_Copy_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-07-28
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Demo_Report_Copy_Handler implements Triggers.Handler{

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
    }

    public void handleAfterInsert() {
        Set<Id> chefRequestIdSet = new Set<Id>();
        for(CN_Demo_Report__c dr: (List<CN_Demo_Report__c>)Trigger.new) {
            chefRequestIdSet.add(dr.CN_Chef_Request__c);
        }
        if(chefRequestIdSet.size() > 0) {
            Map<Id,String> crIdRTNameMap = new Map<Id, String>();
            Map<Id, Id> crIdParentIdMap = new Map<Id, Id>();
            List<CN_Chef_Request__c> crList = [SELECT Id, RecordType.DeveloperName, CN_Account__c, CN_Campaign__c FROM CN_Chef_Request__c WHERE Id in: chefRequestIdSet];
            if(crList.size() > 0) {
                for(CN_Chef_Request__c cr: crList) {
                    crIdRTNameMap.put(cr.Id, cr.RecordType.DeveloperName);
                    if(cr.CN_Account__c != null || cr.CN_Campaign__c != null){
                        crIdParentIdMap.put(cr.Id, cr.CN_Account__c == null? cr.CN_Campaign__c: cr.CN_Account__c);
                    }
                }
                List<CN_Demo_Report__c> demoReportAccountList = new List<CN_Demo_Report__c>();
                List<CN_Demo_Report__c> demoReportCampaignList = new List<CN_Demo_Report__c>();

                for(CN_Demo_Report__c dr: (List<CN_Demo_Report__c>)Trigger.new) {
                    if(Constants.CN_CHEF_REQUEST_RT_NAME_1ON1.equals(crIdRTNameMap.get(dr.CN_Chef_Request__c))) {
                        demoReportAccountList.add(dr);
                    } else if(Constants.CN_CHEF_REQUEST_RT_NAME_MKT_DEMO.equals(crIdRTNameMap.get(dr.CN_Chef_Request__c)) || Constants.CN_CHEF_REQUEST_RT_NAME_MKT_DEV.equals(crIdRTNameMap.get(dr.CN_Chef_Request__c))) {
                        demoReportCampaignList.add(dr);
                    }
                }
                if(demoReportAccountList.size() > 0) {
                    List<CN_Demo_Report_Account__c> demoReportAccList = generateDemoReportForAccount(demoReportAccountList, crIdParentIdMap);
                    insert demoReportAccList;
                }
                if(demoReportCampaignList.size() > 0) {
                    List<CN_Demo_Report_Campaign__c> demoReportCamList = generateDemoReportForCampaign(demoReportCampaignList, crIdParentIdMap);
                    insert demoReportCamList;
                }
            }
        }
    }

    public void handleAfterUpdate() {
        Set<Id> drIdSet = new Set<Id>();
        for(CN_Demo_Report__c dr: (List<CN_Demo_Report__c>)Trigger.new) {
            CN_Demo_Report__c oldDr = (CN_Demo_Report__c)Trigger.oldMap.get(dr.Id);
            drIdSet.add(dr.Id);
        }

        if(drIdSet.size() > 0) {
            List<sObject> updateList = new List<sObject>();
            List<CN_Demo_Report_Account__c> drAccList = [SELECT Id, CN_Demo_Report__c FROM CN_Demo_Report_Account__c WHERE CN_Demo_Report__c in: drIdSet];
            if(drAccList.size() > 0) {
                for(CN_Demo_Report_Account__c dra: drAccList) {
                    CN_Demo_Report__c demorReport = (CN_Demo_Report__c)Trigger.newMap.get(dra.CN_Demo_Report__c);
                    CN_Demo_Report_Account__c draForUpdate = new CN_Demo_Report_Account__c();
                    draForUpdate.Id = dra.Id;
                    draForUpdate.CN_Demo_Products__c = demorReport.CN_Demo_Used_Products__c;
                    draForUpdate.CN_Comments__c = demorReport.CN_Comments__c;
                    draForUpdate.CN_Activity_Type__c = demorReport.CN_Activity_Type__c;
                    draForUpdate.CN_Channel__c = demorReport.CN_Channel__c;
                    draForUpdate.CN_City__c = demorReport.CN_City__c;
                    draForUpdate.CN_Comments__c = demorReport.CN_Comments__c;
                    draForUpdate.CN_Customer_ID__c = demorReport.CN_Customer_ID__c;
                    draForUpdate.CN_Customer_Name__c = demorReport.CN_Customer_Name__c;
                    draForUpdate.CN_Event_Theme__c = demorReport.CN_Event_Theme__c;
                    draForUpdate.CN_Guest_Chef__c = demorReport.CN_Guest_Chef__c;
                    draForUpdate.CN_Number_of_People__c = demorReport.CN_Number_of_People__c;
                    draForUpdate.CN_Number_of_Recipes__c = demorReport.CN_Number_of_Recipes__c;
                    draForUpdate.CN_Report_Creator__c = demorReport.CreatedById;
                    draForUpdate.CN_Sales_Attendance__c = 'Yes'.equals(demorReport.CN_Sales_Attendance__c)? true: false;
                    draForUpdate.CN_Sales_Name__c = demorReport.CN_Sales_Name__c;
                    draForUpdate.CN_SAP_Concur_Travel_Cost__c = demorReport.CN_SAP_Concur_Travel_Cost__c;
                    updateList.add(draForUpdate);
                }
            }
            List<CN_Demo_Report_Campaign__c> drCamList = [SELECT Id, CN_Demo_Report__c FROM CN_Demo_Report_Campaign__c WHERE CN_Demo_Report__c in: drIdSet];
            if(drCamList.size() > 0) {
                for(CN_Demo_Report_Campaign__c drc: drCamList) {
                    CN_Demo_Report_Campaign__c drcForUpdate = new CN_Demo_Report_Campaign__c();
                    CN_Demo_Report__c demorReport = (CN_Demo_Report__c)Trigger.newMap.get(drc.CN_Demo_Report__c);
                    drcForUpdate.Id = drc.Id;
                    drcForUpdate.CN_Demo_Products__c = demorReport.CN_Demo_Used_Products__c;
                    drcForUpdate.CN_Comments__c = demorReport.CN_Comments__c;
                    drcForUpdate.CN_Activity_Type__c = demorReport.CN_Activity_Type__c;
                    drcForUpdate.CN_Channel__c = demorReport.CN_Channel__c;
                    drcForUpdate.CN_City__c = demorReport.CN_City__c;
                    drcForUpdate.CN_Comments__c = demorReport.CN_Comments__c;
                    drcForUpdate.CN_Customer_ID__c = demorReport.CN_Customer_ID__c;
                    drcForUpdate.CN_Customer_Name__c = demorReport.CN_Customer_Name__c;
                    drcForUpdate.CN_Event_Theme__c = demorReport.CN_Event_Theme__c;
                    drcForUpdate.CN_Guest_Chef__c = demorReport.CN_Guest_Chef__c;
                    drcForUpdate.CN_Number_of_People__c = demorReport.CN_Number_of_People__c;
                    drcForUpdate.CN_Number_of_Recipes__c = demorReport.CN_Number_of_Recipes__c;
                    drcForUpdate.CN_Report_Creator__c = demorReport.CreatedById;
                    drcForUpdate.CN_Sales_Attendance__c = 'Yes'.equals(demorReport.CN_Sales_Attendance__c)? true: false;
                    drcForUpdate.CN_Sales_Name__c = demorReport.CN_Sales_Name__c;
                    drcForUpdate.CN_SAP_Concur_Travel_Cost__c = demorReport.CN_SAP_Concur_Travel_Cost__c;
                    updateList.add(drcForUpdate);
                }
            }
            if(updateList.size() > 0) {
                update updateList;
            }
        }

    }

    public void handleBeforeDelete() {
        Set<Id> drIdSet = new Set<Id>();
        for(CN_Demo_Report__c dr: (List<CN_Demo_Report__c>)Trigger.old) {
            drIdSet.add(dr.Id);
        }
        if(drIdSet.size() > 0) {
            List<sObject> objList = new List<sObject>();
            List<CN_Demo_Report_Account__c> drAccList = [SELECT Id, CN_Demo_Report__c FROM CN_Demo_Report_Account__c WHERE CN_Demo_Report__c in: drIdSet];
            if(drAccList.size() > 0) {
                objList.addAll(drAccList);
            }
            List<CN_Demo_Report_Campaign__c> drCamList = [SELECT Id, CN_Demo_Report__c FROM CN_Demo_Report_Campaign__c WHERE CN_Demo_Report__c in: drIdSet];
            if(drCamList.size() > 0) {
                objList.addAll(drCamList);
            }
            if(objList.size() > 0) {
                delete objList;
            }
        }
    }

    List<CN_Demo_Report_Account__c> generateDemoReportForAccount(List<CN_Demo_Report__c> demoReportAccountList, Map<Id, Id> crIdParentIdMap) {
        List<CN_Demo_Report_Account__c> demoReportList = new List<CN_Demo_Report_Account__c>();
        if(demoReportAccountList.size() > 0) {
            for(CN_Demo_Report__c dr: demoReportAccountList) {
                if(crIdParentIdMap.containsKey(dr.CN_Chef_Request__c)){
                    CN_Demo_Report_Account__c dra = new CN_Demo_Report_Account__c();
                    dra.CN_Chef_Request__c = dr.CN_Chef_Request__c;
                    dra.Name = dr.Name;
                    dra.CN_Demo_Report__c = dr.Id;
                    dra.CN_Account__c = crIdParentIdMap.get(dr.CN_Chef_Request__c);
                    dra.CN_Activity_Type__c = dr.CN_Activity_Type__c;
                    dra.CN_Channel__c = dr.CN_Channel__c;
                    dra.CN_City__c = dr.CN_City__c;
                    dra.CN_Comments__c = dr.CN_Comments__c;
                    dra.CN_Customer_ID__c = dr.CN_Customer_ID__c;
                    dra.CN_Customer_Name__c = dr.CN_Customer_Name__c;
                    dra.CN_Event_Theme__c = dr.CN_Event_Theme__c;
                    dra.CN_Guest_Chef__c = dr.CN_Guest_Chef__c;
                    dra.CN_Number_of_People__c = dr.CN_Number_of_People__c;
                    dra.CN_Number_of_Recipes__c = dr.CN_Number_of_Recipes__c;
                    dra.CN_Report_Creator__c = dr.CreatedById;
                    dra.CN_Sales_Attendance__c = 'Yes'.equals(dr.CN_Sales_Attendance__c)? true: false;
                    dra.CN_Sales_Name__c = dr.CN_Sales_Name__c;
                    dra.CN_SAP_Concur_Travel_Cost__c = dr.CN_SAP_Concur_Travel_Cost__c;
                    demoReportList.add(dra);
                }
            }
        }
        return demoReportList;
    }

    List<CN_Demo_Report_Campaign__c> generateDemoReportForCampaign(List<CN_Demo_Report__c> demoReportCampaignList, Map<Id, Id> crIdParentIdMap) {
        List<CN_Demo_Report_Campaign__c> demoReportList = new List<CN_Demo_Report_Campaign__c>();
        if(demoReportCampaignList.size() > 0) {
            for(CN_Demo_Report__c dr: demoReportCampaignList) {
                if(crIdParentIdMap.containsKey(dr.CN_Chef_Request__c)){
                    CN_Demo_Report_Campaign__c dra = new CN_Demo_Report_Campaign__c();
                    dra.CN_Chef_Request__c = dr.CN_Chef_Request__c;
                    dra.Name = dr.Name;
                    dra.CN_Demo_Report__c = dr.Id;
                    dra.CN_Campaign__c = crIdParentIdMap.get(dr.CN_Chef_Request__c);
                    dra.CN_Activity_Type__c = dr.CN_Activity_Type__c;
                    dra.CN_Channel__c = dr.CN_Channel__c;
                    dra.CN_City__c = dr.CN_City__c;
                    dra.CN_Comments__c = dr.CN_Comments__c;
                    dra.CN_Customer_ID__c = dr.CN_Customer_ID__c;
                    dra.CN_Customer_Name__c = dr.CN_Customer_Name__c;
                    dra.CN_Event_Theme__c = dr.CN_Event_Theme__c;
                    dra.CN_Guest_Chef__c = dr.CN_Guest_Chef__c;
                    dra.CN_Number_of_People__c = dr.CN_Number_of_People__c;
                    dra.CN_Number_of_Recipes__c = dr.CN_Number_of_Recipes__c;
                    dra.CN_Report_Creator__c = dr.CreatedById;
                    dra.CN_Sales_Attendance__c =  'Yes'.equals(dr.CN_Sales_Attendance__c)? true: false;
                    dra.CN_Sales_Name__c = dr.CN_Sales_Name__c;
                    dra.CN_SAP_Concur_Travel_Cost__c = dr.CN_SAP_Concur_Travel_Cost__c;
                    demoReportList.add(dra);
                }
            }
        }
        return demoReportList;
    }
}
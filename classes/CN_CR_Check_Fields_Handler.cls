/**************************************************************************************************
 * Name           : CN_CR_Check_Fields_Change_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng
 * Create Date    : 2021-05-31
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_CR_Check_Fields_Handler implements Triggers.Handler {
    Set<Id> CN_RTIds = new Set<Id>();

    Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();

    Map<Id, Set<String>> crIdChangedFieldNameMap = new Map<Id, Set<String>>();
    public void handle() {
        CN_RTIds.add(updateAccountRTId);
        CN_RTIds.add(Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_ACCOUNT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_Mass_UPDATE_ACCOUNT_OWNER).getRecordTypeId());
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
    }
    public void handleBeforeUpdate() {
        Map<Id,Id> changeRequestIdSalesPersonIdMap = new Map<Id,Id>();
        Set<ID> errorchangeRequestIdSet = new Set<ID>();
        Map<Id, CN_Change_Request__c> changeRequestOwnerIdMap = new Map<Id, CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
            CN_Change_Request__c oldCr = (CN_Change_Request__c)Trigger.oldMap.get(cr.Id);
            if(cr.RecordTypeId==updateAccountRTId && oldCr.New_CN_Account_Owner__c != cr.New_CN_Account_Owner__c ){
                changeRequestIdSalesPersonIdMap.put(cr.Id,cr.New_CN_Account_Owner__c);
            }

            if(CN_RTIds.contains(cr.RecordTypeId) && oldCr.New_CN_Account_Owner__c != cr.New_CN_Account_Owner__c){
                changeRequestOwnerIdMap.put(cr.New_CN_Account_Owner__c, cr);
            }
        }
        if(changeRequestIdSalesPersonIdMap.size() > 0) {
            errorchangeRequestIdSet = checkFinanceAR(changeRequestIdSalesPersonIdMap);
        }
        if(errorchangeRequestIdSet.size()!=0){
            salesPersonIsNotTrue(errorchangeRequestIdSet,(List<CN_Change_Request__c>)Trigger.new);
        }
        if(changeRequestOwnerIdMap.size() > 0){
            updateBUAndST(changeRequestOwnerIdMap);
        }
    }

    public void handleBeforeInsert() {
        Map<Id,Id> changeRequestIdSalesPersonIdMap = new Map<Id,Id>();
        Set<ID> errorchangeRequestIdSet = new Set<ID>();
        Map<Id, CN_Change_Request__c> changeRequestOwnerIdMap = new Map<Id, CN_Change_Request__c>();
        for(CN_Change_Request__c cr : (List<CN_Change_Request__c>)Trigger.new) {
            if(cr.RecordTypeId==updateAccountRTId && cr.CN_Account_Owner__c != cr.New_CN_Account_Owner__c ){
                changeRequestIdSalesPersonIdMap.put(cr.Id,cr.New_CN_Account_Owner__c);
            }

            if(CN_RTIds.contains(cr.RecordTypeId) && cr.CN_Account_Owner__c != cr.New_CN_Account_Owner__c){
                changeRequestOwnerIdMap.put(cr.New_CN_Account_Owner__c, cr);
            }
        }
        if(changeRequestIdSalesPersonIdMap.size() > 0) {
            errorchangeRequestIdSet = checkFinanceAR(changeRequestIdSalesPersonIdMap);
        }
        if(errorchangeRequestIdSet.size()!=0){
            salesPersonIsNotTrue(errorchangeRequestIdSet,(List<CN_Change_Request__c>)Trigger.new);
        }
        if(changeRequestOwnerIdMap.size() > 0){
            updateBUAndST(changeRequestOwnerIdMap);
        }
    }

    /**
     * 根据Owner信息更新CR上对应的BU & Sales Team
     */
    public void updateBUAndST(Map<Id, CN_Change_Request__c> changeRequestOwnerIdMap){
        Set<Id> ownerIdSet = changeRequestOwnerIdMap.keySet();
        Map<Id, String> userIdSalesTeamMap = new Map<Id, String>();
        for (User userObj : [SELECT Id, CN_Sales_Team__c FROM User WHERE Id IN: ownerIdSet]) {
            userIdSalesTeamMap.put(userObj.Id, userObj.CN_Sales_Team__c);
        }

        List<CN_Sales_Team__c> salesTeamList = [
            SELECT Id, CN_Business_Unit__c, CN_Sales_Team_Code__c 
            FROM CN_Sales_Team__c 
            WHERE CN_Sales_Team_Code__c IN: userIdSalesTeamMap.values()
        ];

        Map<String, Id> salesTeamCodeBUIdMap = new Map<String, Id>();
        Map<String, Id> salesTeamCodeSTIdMap = new Map<String, Id>();
        for (CN_Sales_Team__c salesTeamObj : salesTeamList) {
            salesTeamCodeBUIdMap.put(salesTeamObj.CN_Sales_Team_Code__c, salesTeamObj.CN_Business_Unit__c);
            salesTeamCodeSTIdMap.put(salesTeamObj.CN_Sales_Team_Code__c, salesTeamObj.Id);
        }

        for (CN_Change_Request__c crObj : changeRequestOwnerIdMap.values()) {
            crObj.New_CN_Account_Business_Unit__c = salesTeamCodeBUIdMap?.get(userIdSalesTeamMap?.get(crObj.New_CN_Account_Owner__c));
            crObj.New_CN_Account_Sales_Team__c = salesTeamCodeSTIdMap?.get(userIdSalesTeamMap?.get(crObj.New_CN_Account_Owner__c));
        }

    }

    public Set<ID> checkFinanceAR(Map<Id,Id> changeRequestIdSalesPersonIdMap) {
        Set<Id> salesPersonIdSet = new Set<Id>();
        salesPersonIdSet.addAll(changeRequestIdSalesPersonIdMap.values());
        List<User> salesPersonList = [Select id,CN_User_Personnel_Number__c From user Where id In: salesPersonIdSet];
        Map<String,Id> personnelNumberStringSalesPersonIdMap = new Map<String,Id>();
        for(User u : salesPersonList){
            if(u.CN_User_Personnel_Number__c != null){
                personnelNumberStringSalesPersonIdMap.put(u.CN_User_Personnel_Number__c,u.Id);
            }
        }
        if(personnelNumberStringSalesPersonIdMap.size()==0){
            return changeRequestIdSalesPersonIdMap.keySet();
        }
        
        List<CN_Internal_Employee__c> employeeList = [Select id,CN_Personnel_Number__c From CN_Internal_Employee__c Where CN_Personnel_Number__c IN: personnelNumberStringSalesPersonIdMap.keySet()];
        if(employeeList.size()==0){
            return changeRequestIdSalesPersonIdMap.keySet();
        }
        Set<String> personnelNumberStringSet = new Set<String>();
        for(CN_Internal_Employee__c employee : employeeList){
            personnelNumberStringSet.add(employee.CN_Personnel_Number__c);
        }

        Set<ID> errorSalesPersonIdSet = new Set<ID>();
        Set<ID> errorchangeRequestIdSet = new Set<ID>();
        for(String personnelNumber : personnelNumberStringSet){
            if(!personnelNumberStringSalesPersonIdMap.keySet().contains(personnelNumber)){
                errorSalesPersonIdSet.add(personnelNumberStringSalesPersonIdMap.get(personnelNumber));
            }
        }
        if(errorSalesPersonIdSet.size()==0){
            return errorchangeRequestIdSet;
        }

        for(Id changeRequestId : changeRequestIdSalesPersonIdMap.keySet()){
            if(errorSalesPersonIdSet.contains(changeRequestIdSalesPersonIdMap.get(changeRequestId))){
                errorchangeRequestIdSet.add(changeRequestId);
            }
        }
        if(errorchangeRequestIdSet.size()==0){
            return errorchangeRequestIdSet;
        }else{
            return errorchangeRequestIdSet;
        }
    }

    public void salesPersonIsNotTrue(Set<ID> errorchangeRequestIdSet,List<CN_Change_Request__c> changeList) {
        for(CN_Change_Request__c change : changeList){
            if(errorchangeRequestIdSet.contains(change.Id)){
                change.addError(system.label.CN_Not_Found_IN_InternalEmployee);     
            }
        }
    }
}
/**************************************************************************************************
 * Name           : CN_Account_Populate_Fields_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-04-30
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Account_Populate_Fields_Handler implements Triggers.Handler{
    Set<Id> CN_RTIds = new Set<Id>();
       
    public void handle() {
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_DIRECT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_INDIRECT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_INDIRECT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_APPROVE_DIRECT).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_Prospect).getRecordTypeId());
        CN_RTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_Prospect).getRecordTypeId());
        
        if(Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
		if(Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
        
    }
    
    public void handleBeforeInsert() {
        Map<Account,Id>  accountOwnerIdMap = new Map<Account,Id>();
        for(Account acc : (List<Account>)Trigger.New){
            if(CN_RTIds.contains(acc.RecordTypeId)) {
                accountOwnerIdMap.put(acc,acc.OwnerId);
            }
        }
        Set<Id> OwnerIdSet = new Set<Id>();
        OwnerIdSet.addAll(accountOwnerIdMap.values());
        Id userId_FinanceAR = CN_Approve_Process_Settings__c.getInstance().CN_Finance_AR_UserId__c;
        if(userId_FinanceAR == NULL){
            for(Account acc : accountOwnerIdMap.keySet()){
                acc.addError(system.Label.CN_Not_Found_FinanceAR);
			}
            return ;
        }
        OwnerIdSet.add(userId_FinanceAR);
        List<User> ownerUserList = [SELECT id,CN_User_Personnel_Number__c,CN_Sales_Team__c,CN_Sales_Office__c FROM User Where id IN :OwnerIdSet];
        updateAccountSalesPerson(accountOwnerIdMap,ownerUserList,True);
        updateAccountSalesTeamsAndBusinessUnit(accountOwnerIdMap,ownerUserList);
        updateAccountSalesOffice(accountOwnerIdMap,ownerUserList);
    }
    
    public void handleBeforeUpdate() {
        Map<Account,Id>  accountOwnerIdMap = new Map<Account,Id>();
        for(Account acc : (List<Account>)Trigger.New) {
            if(CN_RTIds.contains(acc.RecordTypeId) && acc.OwnerId <> ((Account)Trigger.oldMap.get(acc.Id)).OwnerId) {
                accountOwnerIdMap.put(acc,acc.OwnerId);
            }
        }
        
        Set<Id> OwnerIdSet = new Set<Id>();
        OwnerIdSet.addAll(accountOwnerIdMap.values());
        List<User> ownerUserList = [SELECT id,CN_User_Personnel_Number__c,CN_Sales_Team__c,CN_Sales_Office__c FROM User Where id IN :OwnerIdSet];
        updateAccountSalesPerson(accountOwnerIdMap,ownerUserList,False);
        //updateAccountSalesTeamsAndBusinessUnit(accountOwnerIdMap,ownerUserList);
        updateAccountSalesOffice(accountOwnerIdMap,ownerUserList);
    }
   
    public void updateAccountSalesPerson(Map<Account,Id> accountOwnerIdMap,List<User> ownerUserList,Boolean isCreate) {
        Map<Id,String>  userIdEmployeeNumberMap = new Map<Id,String>();
        for(User u : ownerUserList){
            if(u.CN_User_Personnel_Number__c<>NULL){
                userIdEmployeeNumberMap.put(u.id, u.CN_User_Personnel_Number__c);
            }
        }
        Set<String> employeeNumberSet = new Set<String>();
        employeeNumberSet.addAll(userIdEmployeeNumberMap.values());
        if(employeeNumberSet.size()==0){
            for(Account acc : accountOwnerIdMap.keySet()){
                acc.addError(system.Label.CN_Not_Found_IN_InternalEmployee);
            }
            return;
        }
        List<CN_Internal_Employee__c> internalEmployeeList = [SELECT id,CN_Personnel_Number__c FROM CN_Internal_Employee__c WHERE CN_Personnel_Number__c IN :employeeNumberSet];
        if(internalEmployeeList.size()>0){
            Map<String,Id>  EmployeeNumberEmployeeIdMap = new Map<String,Id>();
            Map<Id,Id> accIdEmployeeIdMap = new Map<Id,Id>();
            for(CN_Internal_Employee__c employee : internalEmployeeList){
                EmployeeNumberEmployeeIdMap.put(employee.CN_Personnel_Number__c, employee.id);               
            }
            Map<Id,Id>  userIdEmployeeIdMap = new Map<Id,Id>();
            for(Id userId : userIdEmployeeNumberMap.keySet()){
                Id EmployeeId = EmployeeNumberEmployeeIdMap.get(userIdEmployeeNumberMap.get(userId));
                if(EmployeeId <> NULL){
                    userIdEmployeeIdMap.put(userId,EmployeeId);
                }
                
            }
            for(Account acc : accountOwnerIdMap.keySet()){
                if(userIdEmployeeIdMap.keySet().contains(acc.OwnerId)){
                    acc.CN_Sales_Person_Name__c = userIdEmployeeIdMap.get(acc.OwnerId);
                }else{
                    acc.addError(system.Label.CN_Not_Found_IN_InternalEmployee);
                }
            }
            if(isCreate==True){
                updateAccountFinAR(accountOwnerIdMap,ownerUserList,EmployeeNumberEmployeeIdMap,userIdEmployeeNumberMap);
            }
        }else{
            for(Account acc : accountOwnerIdMap.keySet()){
                  acc.addError(system.Label.CN_Not_Found_IN_InternalEmployee);
            }
            return;
        }
    }
	public void updateAccountFinAR(Map<Account,Id> accountOwnerIdMap,List<User> ownerUserList,Map<String,Id>  EmployeeNumberEmployeeIdMap,Map<Id,String> userIdEmployeeNumberMap) {
        User FinARUser = new User();
        for(User user : ownerUserList){
            if(user.Id == CN_Approve_Process_Settings__c.getInstance().CN_Finance_AR_UserId__c){
                FinARUser = user;
                break;
            }
        }
        Id EmployeeId = EmployeeNumberEmployeeIdMap.get(userIdEmployeeNumberMap.get(FinARUser.Id));
        if(EmployeeId == NULL){
            for(Account acc : accountOwnerIdMap.keySet()){
                acc.addError(system.Label.CN_Not_Found_FinanceAR);
            }
            return ;
        } 
        for(Account acc : accountOwnerIdMap.keySet()){
            acc.CN_Sinodis_Finance_AR__c = EmployeeId;
        }
    }
    
    public void updateAccountSalesTeamsAndBusinessUnit(Map<Account,Id> accountOwnerIdMap,List<User> ownerUserList) {
        Map<Id,String>  userIdSalesTeamCodeMap = new Map<Id,String>();
        Set<String> salesTeamSet = new Set<String>();
        for(User u : ownerUserList){
            if(u.CN_Sales_Team__c<>NULL){
                userIdSalesTeamCodeMap.put(u.id, u.CN_Sales_Team__c);
            	salesTeamSet.add(u.CN_Sales_Team__c);
            }   
        }
        if(salesTeamSet.size()==0){
            for(Account acc : accountOwnerIdMap.keySet()){
                acc.addError(system.Label.CN_Not_Found_SalesTeam);
            }
            return;
        }
        List<CN_Sales_Team__c> salesTeamList = [SELECT Id,CN_Business_Unit__c,CN_Sales_Team_Code__c FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c IN: salesTeamSet];
        if(salesTeamList.size() > 0){
            updateAccountSalesTeams(salesTeamList,accountOwnerIdMap,userIdSalesTeamCodeMap);
            updateAccountBusinessUnit(salesTeamList,accountOwnerIdMap,userIdSalesTeamCodeMap);
        }else{
            for(Account acc : accountOwnerIdMap.keySet()){
                acc.addError(system.Label.CN_Not_Found_SalesTeamOrBusinessUnit);
            }
        }
    }
    public void updateAccountSalesTeams(List<CN_Sales_Team__c> salesTeamList,Map<Account,Id> accountOwnerIdMap,Map<Id,String>  userIdSalesTeamCodeMap) {
        Map<String,Id>  SalesTeamCodeSalesTeamIdMap = new Map<String,Id>();
        for(CN_Sales_Team__c salesTeam : salesTeamList){
            SalesTeamCodeSalesTeamIdMap.put(salesTeam.CN_Sales_Team_Code__c,salesTeam.Id);
        }
        for(Account acc : accountOwnerIdMap.keySet()){
            if(userIdSalesTeamCodeMap.keySet().contains(acc.OwnerId)){
                Id SalesTeamId = SalesTeamCodeSalesTeamIdMap.get(userIdSalesTeamCodeMap.get(acc.OwnerId));
                if(SalesTeamId <> NULL){
                    acc.CN_Sales_Team_UI__c = SalesTeamId;
                }else{
                    acc.addError(system.Label.CN_Not_Found_SalesTeam);
                }
            }else{
                acc.addError(system.Label.CN_Not_Found_SalesTeam);
            }
        } 
    }
    public void updateAccountBusinessUnit(List<CN_Sales_Team__c> salesTeamList,Map<Account,Id> accountOwnerIdMap,Map<Id,String>  userIdSalesTeamCodeMap) {
        Map<String,Id> salesTeamCodeBusinessIdMap = new Map<String,Id>();
        for(CN_Sales_Team__c salesTeam : salesTeamList){
            salesTeamCodeBusinessIdMap.put(salesTeam.CN_Sales_Team_Code__c,salesTeam.CN_Business_Unit__c);
        }
        for(Account acc : accountOwnerIdMap.keySet()){	
            if(userIdSalesTeamCodeMap.keySet().contains(acc.OwnerId)){
                Id businessId = salesTeamCodeBusinessIdMap.get(userIdSalesTeamCodeMap.get(acc.OwnerId));
                if(businessId<>NULL){
                    acc.CN_Business_Unit_UI__c = businessId;
                }     
            }else{
                acc.addError(system.Label.CN_Not_Found_BusinessUnit);
            }
        }
    }
    
    public void updateAccountSalesOffice(Map<Account,Id> accountOwnerIdMap,List<User> ownerUserList) {
        Map<Id,String>  userIdSalesOfficeStringMap = new Map<Id,String>();
        Set<String> salesOfficeValuesStringSet = new Set<String>();
        salesOfficeValuesStringSet.add(Constants.CN_ACCOUNT_SALESOFFICE_VALUE_K010);
        salesOfficeValuesStringSet.add(Constants.CN_ACCOUNT_SALESOFFICE_VALUE_K020);
        salesOfficeValuesStringSet.add(Constants.CN_ACCOUNT_SALESOFFICE_VALUE_K030);
        salesOfficeValuesStringSet.add(Constants.CN_ACCOUNT_SALESOFFICE_VALUE_K040);
        salesOfficeValuesStringSet.add(Constants.CN_ACCOUNT_SALESOFFICE_VALUE_K050);
        salesOfficeValuesStringSet.add(Constants.CN_ACCOUNT_SALESOFFICE_VALUE_K060);
        for(User u : ownerUserList){
            if(u.CN_Sales_Office__c<>NUll){
                userIdSalesOfficeStringMap.put(u.id, u.CN_Sales_Office__c);
            }
        }
        for(Account acc : accountOwnerIdMap.keySet()){
            if(userIdSalesOfficeStringMap.keySet().contains(acc.OwnerId) && salesOfficeValuesStringSet.contains(userIdSalesOfficeStringMap.get(acc.OwnerId))){
                acc.CN_Sales_Office__c = userIdSalesOfficeStringMap.get(acc.OwnerId);
            }else{
                acc.addError(system.Label.CN_Not_Found_SalesOffice);
            }
        }
    }
}
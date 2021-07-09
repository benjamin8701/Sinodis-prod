/**************************************************************************************************
 * Name           : CN_BU_Prevent_Delete_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_BU_Prevent_Delete_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeDelete() {
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        Trigger_Switcher_Setting__c setting = new Trigger_Switcher_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            EnableFlow__c = true,
            EnableTrigger__c = true,
            EnableValidationRule__c = true
        );
        insert setting;
        CN_Approve_Process_Settings__c approveSetting = new CN_Approve_Process_Settings__c(
            CN_CEO_UserId__c = lastNameUserIdMap.get('CEO'),
            CN_CFO_UserId__c = lastNameUserIdMap.get('CFO'),
            CN_Finance_AR_UserId__c = lastNameUserIdMap.get('FinanceAR'),
            CN_Finance_MDM_UserId__c = lastNameUserIdMap.get('FinanceMDM'),
            CN_Sales_MDM_UserId__c = lastNameUserIdMap.get('SalesMDM')
        );
        insert approveSetting;

        User salesMDM = [SELECT Id FROM User WHERE lastName = 'salesMDM'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        CN_Group__c gr = [SELECT Id FROM CN_Group__c WHERE CN_Group_Code__c = 'drink group'][0];
        

        System.runAs(salesMDM) {

            CN_Business_Unit__c bu = new CN_Business_Unit__c();
            bu.Name = 'Test BusinessUnit';
            bu.CN_Business_Unit_Code__c = '00001';
            bu.CurrencyIsoCode = 'CNY';
            insert bu;

            CN_Business_Unit__c bu_update = new CN_Business_Unit__c();
            bu_update.Id =  bu.Id;
            bu_update.CN_Sync_Status__c = 'Success';
            update bu_update;

            test.startTest();
            
            CN_Business_Unit__c bu_delete = new CN_Business_Unit__c();
            bu_delete.Id = bu.Id;
            try{
                delete bu_delete;
            }catch(exception e){

            }
            
            test.stopTest();
        }
    }
}
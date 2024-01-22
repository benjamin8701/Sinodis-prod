/*
 * ************************************************************************************************
 * Name : CN_CR_Populate_Approver_Handler_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Leo Dicaprio
 * Create Date : 2024/1/3
 * Modify History :
 * ************************************************************************************************
 */
@IsTest
public class CN_CR_Populate_Approver_Handler_Test {
	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}
	@isTest
	private static void handleInactiveShiptoTest() {
		TestDataFactory testFactory = new TestDataFactory();
		testFactory.makeAccounts(10,false);
		User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
		Account acc = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
		acc.CN_Sync_Status__c = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
		update acc;

		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		Id inactiveShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_INACTIVE_SHIPTO).getRecordTypeId();
		Test.startTest();
		System.runAs(salesRep){
			CN_Change_Request__c cr = new CN_Change_Request__c();

			Map<String, Object> cR_LC_Ctrl_ResultMap = CN_SHIPTO_CHANGE_REQUEST_LC_CTRL.getShipTo(shipToParty.Id);
			for(String field : ((Map<String, String>)cR_LC_Ctrl_ResultMap.get('fieldMap')).keySet()){
				CN_Ship_to_Party__c con_source = (CN_Ship_to_Party__c)cR_LC_Ctrl_ResultMap.get('sourceShipTo');
				cr.put(field,con_source.get(((Map<String, String>)cR_LC_Ctrl_ResultMap.get('fieldMap')).get(field)));
			}
			cr.CN_ShipTo_Address_ID__c = '1';
			cr.CN_Is_Generate_From_Action__c = true;
			cr.New_CN_Contact_CN_Last_Name__c = 'Test CR_update';
			cr.New_CN_ShipTo_Customer_Name__c = 'Test CR_update';
			cr.RecordTypeId = inactiveShiptoRTId;
			cr.OwnerId = salesRep.Id;
			insert cr;

			Trigger_Switcher_Setting__c setting = new Trigger_Switcher_Setting__c(
					SetupOwnerId = UserInfo.getOrganizationId(),
					EnableFlow__c = true,
					EnableTrigger__c = true,
					EnableValidationRule__c = false
			);
			insert setting;

			try {
				cr.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_READY_FOR_APPROVAL;
				update cr;
			} catch (Exception e) {

			}
		}
		Test.stopTest();
	}
}
/*
 * ************************************************************************************************
 * Name : CN_Download_By_Url_Batch_Test
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
public class CN_Download_By_Url_Batch_Test {

	@TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}


	@IsTest
	private static void handle() {
		TestDataFactory factory = new TestDataFactory();
		factory.makeAccounts(1,false);
		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		CN_Download_By_Url_Info__c cnDownloadByUrlInfo = CN_Download_By_Url_Helper.convert(shipToParty.Id,'title','http://MG_file.pdf','CN_Ship_to_Party__c','Lis');
		insert cnDownloadByUrlInfo;
		Test.setMock(HttpCalloutMock.class, new TestHttpMock());
		Test.startTest();
		Database.executeBatch(new CN_Download_By_Url_Batch(),1);
		Test.stopTest();
	}

	@IsTest
	private static void handle500() {
		TestDataFactory factory = new TestDataFactory();
		factory.makeAccounts(1,false);
		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		CN_Download_By_Url_Info__c cnDownloadByUrlInfo = CN_Download_By_Url_Helper.convert(shipToParty.Id,'title','http://MG_file_500.pdf','CN_Ship_to_Party__c','Lis');
		insert cnDownloadByUrlInfo;
		Test.setMock(HttpCalloutMock.class, new TestHttpMock());
		Test.startTest();
		Database.executeBatch(new CN_Download_By_Url_Batch(),1);
		Test.stopTest();
	}

	@IsTest
	private static void handle404() {
		TestDataFactory factory = new TestDataFactory();
		factory.makeAccounts(1,false);
		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		CN_Download_By_Url_Info__c cnDownloadByUrlInfo = CN_Download_By_Url_Helper.convert(shipToParty.Id,'title','http://MG_file_404.pdf','CN_Ship_to_Party__c','Lis');
		insert cnDownloadByUrlInfo;
		Test.setMock(HttpCalloutMock.class, new TestHttpMock());
		Test.startTest();
		Database.executeBatch(new CN_Download_By_Url_Batch(),1);
		Test.stopTest();
	}

	@IsTest
	private static void handle503() {
		TestDataFactory factory = new TestDataFactory();
		factory.makeAccounts(1,false);
		CN_Ship_to_Party__c shipToParty = [SELECT Id FROM CN_Ship_to_Party__c WHERE CN_ShipTo_Address_ID__c = '1'];
		CN_Download_By_Url_Info__c cnDownloadByUrlInfo = CN_Download_By_Url_Helper.convert(shipToParty.Id,'title','http://MG_file_503.pdf','CN_Ship_to_Party__c','Lis');
		insert cnDownloadByUrlInfo;
		Test.setMock(HttpCalloutMock.class, new TestHttpMock());
		Test.startTest();
		Database.executeBatch(new CN_Download_By_Url_Batch(),1);
		Test.stopTest();
	}

}
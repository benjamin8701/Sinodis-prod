/**************************************************************************************************
 * Name           : CN_Campaign_Generate_Opp_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Campaign_Generate_Opp_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_Campaign_Generate_Opp_LC_Ctrl_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        //add by Zhangzhihao  Create a TalendSetting 2024/4/6
        testFactory.makeTalendSetting();    
        //add by Zhangzhihao  Create a TalendSetting 2024/4/6
        Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Contact con_factory = [SELECT Id, Name FROM Contact WHERE AccountId =: acc_factory.Id];

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        List<Product2> SKUList = [SELECT Id FROM Product2];

        campaign cam = testFactory.makeCampaign();
        insert cam;

        CN_Campaign_Product__c cp = new CN_Campaign_Product__c();
        cp.CN_Campaign__c = cam.Id;
        cp.CN_Product__c = SKUList[0].Id;
        insert cp;

        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.CampaignId = cam.Id;
        cms.Label = Constants.CN_CM_STATUS_ATTENDED;
        // cms.SortOrder = 1;
        cms.IsDefault = true;
        cms.HasResponded = true;
        insert cms;

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cam.Id;
        cm.AccountId = acc_factory.Id;
        cm.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm;

        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = cam.Id;
        cm1.ContactId = con_factory.Id;
        cm1.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm1;

        System.debug([Select Id,IsDeleted,CampaignId,Label,SortOrder,IsDefault,HasResponded,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp From CampaignMemberStatus]);
System.debug([SELECT Id, Name, CampaignId, Status, CN_Type_Formula__c FROM CampaignMember]);
        Test.startTest();

        CN_Campaign_Generate_Opp_LC_Ctrl.getStageFieldValue(cam.Id);

        Opportunity opp = testFactory.makeOpp(acc_factory);

        CN_Campaign_Generate_Opp_LC_Ctrl.generateOpp(opp, cam.Id);
        Test.stopTest();
    }
}
/**************************************************************************************************
 * Name           : CN_Promotion_Validation_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Promotion_Validation_Handler_Test {

    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleAfterUpdateTest() {
        TestDataFactory testFactory = new TestDataFactory();
        List<Account> accListFactory = testFactory.makeFactoryAccount();
        List<User> userList = [SELECT Id, LastName FROM User WHERE lastName in ('Sales1', 'Sales3', 'ChefManager', 'Chef', 'CCE1_KA')];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }
        User salesRep = lastNameUserMap.get('Sales1');
        User cce = lastNameUserMap.get('CCE1_KA');

        CN_Promotion__c promotion = new CN_Promotion__c(
            Name = 'TestPromotion',
            CN_Start_Date__c = Date.today().addMonths(3),
            CN_End_Date__c = Date.today().addMonths(3).addDays(13),
            CN_Promotion_Type__c = 'Discount',
            Channel__c = 'KA',
            CN_Status__c = 'Planned',
            Customer_Category__c = 'BAPA',
            CN_Sales_Office__c = 'K010'
        );

        Account acc_factory = [SELECT Id,Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        List<Product2> SKUList = [SELECT Id, Name FROM Product2];

        Test.startTest();
        System.runAs(cce) {
            insert promotion;

            promotion.CN_Status__c = Constants.CN_PROMOTION_STATUS_READY;
            try {
                update promotion;
            } catch (Exception e) {
                
            }

            CN_Promotion_Line_Item__c pli = new CN_Promotion_Line_Item__c(
                CN_Promotion__c = promotion.Id,
                CN_Product__c = SKUList[0].Id,
                CN_Promotion_Price__c = 99.9
            );
            insert pli;

            CN_Promotion_Generate_ProMember_LC_Ctrl.generateProMember(promotion.Id);

            CN_Promotion_Member__c pm = new CN_Promotion_Member__c(
                CN_Promotion__c = promotion.Id,
                CN_Account__c = acc_factory.Id
            );

            insert pm;
            
            promotion.CN_Status__c = Constants.CN_PROMOTION_STATUS_READY;
            update promotion;
            try {
                delete promotion;
            } catch (Exception e) {
                
            }

            try {
                delete pm;
            } catch (Exception e) {
                
            }

            try {
                delete pli;
            } catch (Exception e) {
                
            }

            CN_Promotion_Publish_LC_Ctrl.prmtPublish(promotion.Id);
        }
        Test.stopTest();
    }
}
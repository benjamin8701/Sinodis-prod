@isTest
public class CN_Product_Description_Check_HandlerTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();

        Trigger_Switcher_Setting__c setting = new Trigger_Switcher_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            EnableFlow__c = true,
            EnableTrigger__c = true,
            EnableValidationRule__c = true
        );
        insert setting;
    }

    @isTest
    private static void handleBeforeUpdate1(){
        User cceUser = [Select Id from User Where Profile.Name = 'CN CCE' and LastName = 'CCE2_DS' limit 1];
        CN_Brand_Owner_Control__c boc = new CN_Brand_Owner_Control__c();
        boc.CN_Brands__c = 'AA';
        boc.CN_Brand_Owner__c = cceUser.Id;
        insert boc;

        Product2 prd = [Select Id From Product2 Where Name = 'TestProduct00001' limit 1];
        prd.CN_Brand__c = 'AA';
        update prd;
        User cceUser2 = [Select Id from User Where Profile.Name = 'CN CCE' and LastName = 'CCE1_KA' limit 1];
        system.runAs(cceUser2){
            Product2 prd2 = [Select Id From Product2 Where Name = 'TestProduct00001' limit 1];
            prd2.CN_SKU_Description_EN__c = 'AA';
            try{
                update prd2;
            }catch(Exception ex){

            }
            
        }
    }

    @isTest
    private static void handleBeforeUpdate2(){
        User cceUser = [Select Id from User Where Profile.Name = 'CN CCE' and LastName = 'CCE2_DS' limit 1];
        CN_Brand_Owner_Control__c boc = new CN_Brand_Owner_Control__c();
        boc.CN_Brands__c = 'AA';
        boc.CN_Brand_Owner__c = cceUser.Id;
        insert boc;

        Product2 prd = [Select Id From Product2 Where Name = 'TestProduct00001' limit 1];
        prd.CN_Brand__c = 'BB';
        update prd;        
        system.runAs(cceUser){
            Product2 prd2 = [Select Id From Product2 Where Name = 'TestProduct00001' limit 1];
            prd2.CN_SKU_Description_EN__c = 'AA';
            try{
                update prd2;
            }catch(Exception ex){

            }
            
        }
    }
}
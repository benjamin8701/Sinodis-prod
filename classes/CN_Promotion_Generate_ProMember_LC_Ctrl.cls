/**************************************************************************************************
 * Name           : CN_Promotion_Generate_ProMember_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-09-10
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Promotion_Generate_ProMember_LC_Ctrl {

    @AuraEnabled 
    public static Map<String, Object> generateProMember(Id recordId){
        
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String myProflieName = profileList[0].Name;
        String errorMessage = '';

        if(String.isBlank(recordId)) {
            throw new AuraHandledException(System.Label.CN_Promotion_Not_Found);
        }
        Boolean hasCreatePermission = Untils.checkObjectCreatePermission('CN_Promotion_Member__c');
        if(!hasCreatePermission) {
            throw new AuraHandledException(System.Label.CN_PromotionMember_No_Permission);
        }

        List<CN_Promotion__c> promoList = [SELECT Id,
                                        CN_Status__c,
                                        Channel__c,
                                        Customer_Category__c,
                                        CN_Sales_Office__c,
                                        CN_Customer_Group__c,
                                        CN_Customer_Brand__c
                                   FROM CN_Promotion__c
                                   WHERE Id = :recordId];
        if(promoList.size() > 0) {
            createPromotionMember(promoList[0]);
        }

        return new Map<String, Object>{
            'errorMessage' => errorMessage
        };
    }

    public static void createPromotionMember(CN_Promotion__c promo){
        Integer resultNum = 0;

        List<CN_Promotion_Member__c> promoMemberList_delete = [SELECT Id 
                                   FROM CN_Promotion_Member__c 
                                   WHERE CN_Promotion__c = :promo.Id];

        String queryString = 'SELECT Id,OwnerId FROM Account ';
        List<String> conditionList = new List<String>();

        if(promo.CN_Customer_Group__c != null){
            conditionList.add('CN_Group_Name__c = \'' + promo.CN_Customer_Group__c + '\'');
        }
        if(promo.CN_Customer_Brand__c != null){
            conditionList.add('CN_Brand__c = \'' + promo.CN_Customer_Brand__c + '\'');
        }
        conditionList.add('CN_Sales_Team_Name__c IN (\''+String.join(promo.Channel__c.split(';'), '\',\'')+'\')');
        conditionList.add('CN_Sales_Office__c IN (\''+String.join(promo.CN_Sales_Office__c.split(';'), '\',\'')+'\')');
        conditionList.add('CN_Category__c IN (\''+String.join(promo.Customer_Category__c.split(';'), '\',\'')+'\')');

        if(conditionList.size()>0){
            queryString = queryString + 'WHERE ' + String.join(conditionList , ' AND ');
        }

        List<Account> accList = Database.query(queryString);

        List<CN_Promotion_Member__c> promoMemberList_Generate = new List<CN_Promotion_Member__c>();
        for(Account acc : accList){
            promoMemberList_generate.add(new CN_Promotion_Member__c(CN_Account__c = acc.Id,CN_Account_Owner__c=acc.OwnerId,CN_Promotion__c=promo.Id));
        }
        
        if(promoMemberList_delete.size()>0){
            delete promoMemberList_delete;
        }

        if(promoMemberList_generate.size()>0){
            insert promoMemberList_generate;
        }

    }

}
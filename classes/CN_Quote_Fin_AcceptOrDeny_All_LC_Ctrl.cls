/**************************************************************************************************
* Name           : CN_Quote_Fin_AcceptOrDeny_All_LC_Ctrl
* Object         : 
* Requirement    : 
* Target         : 
* Refer classes  :
* Author         : Houchen Wan
* Create Date    : 2021-11-05
* Modify History : 
**************************************************************************************************/
public without sharing class CN_Quote_Fin_AcceptOrDeny_All_LC_Ctrl {
    
    @AuraEnabled
    public static void acceptOrDenyAll(String QuoteId){
        system.debug('QuoteId==>'+QuoteId);
        List<QuoteLineItem> Items = [Select Id, 
                                     QuoteId,
                                     CN_Customer_Acceptance__c,CN_Finance_Acceptance__c
                                     From QuoteLineItem 
                                     Where QuoteId = :QuoteId
                                     And CN_Customer_Acceptance__c = 'Accepted'];
        if(Items.isEmpty()) {
            throw new AuraHandledException(System.Label.CN_QuoteItem_Not_Found);
        }
        
        Boolean isSameAccenptanceValue = true;
        String tempAccenptanceValue = null;
        for(Integer i = 0;i<Items.size();i++){
            if(i==0){
                tempAccenptanceValue = Items[i].CN_Finance_Acceptance__c;
            }else{
                if(tempAccenptanceValue != Items[i].CN_Finance_Acceptance__c){
                    isSameAccenptanceValue = false;
                    break;
                }
            }
        }
        for(QuoteLineItem item:Items){
            if(isSameAccenptanceValue){
                if(String.isBlank(item.CN_Finance_Acceptance__c)){
                    item.CN_Finance_Acceptance__c = 'Accepted';
                }else{
                    item.CN_Finance_Acceptance__c = item.CN_Finance_Acceptance__c == 'Accepted'?'Denied':'Accepted';
                }
            }else{
                item.CN_Finance_Acceptance__c = 'Accepted';
            }
            
        }
        try{
            Constants.CN_QU_TRIGGER_ON = false;
            update Items;
        }catch(exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    
}
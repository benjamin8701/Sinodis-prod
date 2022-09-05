public class CN_Quote_Notify_Finance_Template_Ctrl {
    public Id QId{get;set;}
    
    public List<QuoteLineItem> getItems(){
        system.debug('QId==>'+QId);
        return [Select Id,CN_Product_Code__c,
                CN_SKU_Description_CN__c,CN_SKU_Description_EN__c,
                UnitPrice,CN_List_Price__c,CN_List_Price_VAT__c,CN_Rate_API__c,CN_Selling_Unit__c,CN_Tax__c      
                From QuoteLineItem 
                Where QuoteId = :QId
                And CN_Customer_Acceptance__c = 'Accepted'];
    }
    
    public String getQuoteURL(){
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com/'+QId;
    }
    
    
}
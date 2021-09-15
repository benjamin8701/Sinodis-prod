public without sharing class CN_Account_TM_REPORT_Handler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isBefore && Trigger.isUpdate) {
            handleAfterUpdate();
        }   
    }

    public void handleAfterUpdate() {
        List<Account> accList = new List<Account>();
        for(Account acc : (List<Account>)Trigger.New) {
            Account oldAccount = (Account)Trigger.oldMap.get(acc.Id);
            if (acc.CN_Account_Status__c == 'Approved' && oldAccount.CN_Account_Status__c == 'Submitted for Approval' && acc.name.substring(0,2).equals('TM')) {
                //是否TM 客户 ： 客户审批通过时， 客户名称以TM 开头， 则是TM 客户 
                acc.CN_Is_TM_Account__c = true;
            }
            if(acc.CN_Customer_Code__c != null && oldAccount.CN_Customer_Code__c == null){
                //开户日期 ： SAP 代码生成时， 更新改日期
                acc.CN_Open_Date__c = system.today();
            }
            if(!acc.name.substring(0,2).equals('TM') && oldAccount.name.substring(0,2).equals('TM')){
                //TM变更日期 ：当客户名称 去除了 TM 开头，并审批通过时, 则更新该日期为当前日期 
                acc.CN_TM_Remove_Date__c = system.today();
            }
            if(acc.CN_Order_Block__c != null && oldAccount.CN_Order_Block__c == null){
                //Order Block  Date :  Order Block 有值时，更新成当前日期 ； Order Block 从有值更新为空时，清空
                acc.CN_Order_Block_Date__c = system.today();
            }else if(acc.CN_Order_Block__c == null && oldAccount.CN_Order_Block__c != null){
                acc.CN_Order_Block_Date__c = null;
            }
            if(acc.CN_Delivery_Block__c != null && oldAccount.CN_Delivery_Block__c == null){
                //Delivery Block Date ： Delivery Block 有值时，更新成当前日期 ； Delivery Block从有值更新为空时，清空
                acc.CN_Delivery_Block_Date__c = system.today();
            }else if(acc.CN_Delivery_Block__c == null && oldAccount.CN_Delivery_Block__c != null){
                acc.CN_Delivery_Block_Date__c = null;
            }
            if(acc.CN_Billing_Block__c != null && oldAccount.CN_Billing_Block__c == null){
                //Billing Block Date : Billing Block  有值时，更新成当前日期 ； Billing Block从有值更新为空时，清空 
                acc.CN_Billing_Block_Date__c = system.today();
            }else if(acc.CN_Billing_Block__c == null && oldAccount.CN_Billing_Block__c != null){
                acc.CN_Billing_Block_Date__c = null;
            }
        }
    }
}
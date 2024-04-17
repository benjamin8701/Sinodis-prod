/**************************************************************************************************
 * Name           : CN_User_Upsert_To_Mg_Batch
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2024-01-25
 * Modify History : 
 **************************************************************************************************/
public  class CN_User_Upsert_To_Mg_Batch implements Database.batchable<SObject>, Database.AllowsCallouts{
    public Iterable<SObject> start(Database.BatchableContext bc) {
            List<User> users = [SELECT 
            Id,
            Name,
            CN_Target_Email__c,
            CN_Email_Verified_Need_Sync__c,
            Email
            FROM User 
            WHERE CN_Email_Verified_Need_Sync__c = true
            ];

        List<User> filteredUsers = new List<User>();
        for(User user : users) {
            if(user.Email == user.CN_Target_Email__c) {
                filteredUsers.add(user);
            }
        }
		return filteredUsers;
	}

    public void execute(Database.BatchableContext bc, List<SObject> userList) {
        Set<Id> needSendId = new Set<Id>();
        List<User> users = (List<User>)userList;
        for(User user:users){
            needSendId.add(user.id);
        }

    
        List<Lead> leads = [
            SELECT Id, Name, CN_Field_Lock__c
            FROM Lead
            WHERE OwnerId = :needSendId
                AND LeadSource = :Constants.CN_LEAD_SOURCE_ECOMMERCE
                AND IsConverted = false
                AND Status NOT IN ('Closed - Dead', 'Closed - Converted')
        ];
    
        List<CN_Field_Lock__c> fieldLocksForInsert = new List<CN_Field_Lock__c>();
        Set<String> fieldLockValues = new Set<String>();
        List<Lead> emptyFieldLockLeads = new List<Lead>();
    
        for (Lead lead : leads) {
            if (lead.CN_Field_Lock__c == null) {
                CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
                fieldLocksForInsert.add(fieldLock);
                emptyFieldLockLeads.add(lead);
            } else {
                fieldLockValues.add(lead.CN_Field_Lock__c);
            }
        }
        if (!fieldLocksForInsert.isEmpty()) {
            insert fieldLocksForInsert;
        }
        for (Integer i = 0; i < emptyFieldLockLeads.size(); i++) {
            if (i < fieldLocksForInsert.size()) {
                emptyFieldLockLeads[i].CN_Field_Lock__c = fieldLocksForInsert[i].Id;
            }
        }
         //add by ZhangZhiHao  Added non-null modification check 2024/4/3
        if(emptyFieldLockLeads != null && !emptyFieldLockLeads.isEmpty()) {
            update emptyFieldLockLeads;
        }
         //add by ZhangZhiHao  Added non-null modification check 2024/4/3
        
        List<CN_Field_Lock__c> fieldLocks = [
            SELECT Id, Name, CN_Need_Send_MG_Flag__c
            FROM CN_Field_Lock__c
            WHERE Id IN :fieldLockValues
        ];
    
        for (CN_Field_Lock__c fieldLock : fieldLocks) {
            fieldLock.CN_Need_Send_MG_Flag__c = 1;
        }
        //add by ZhangZhiHao  Added non-null modification check 2024/4/3
        if(fieldLocks != null && !fieldLocks.isEmpty()) {
           update fieldLocks;
        }
        //add by ZhangZhiHao  Added non-null modification check 2024/4/3
        
        List<Account> accountList = [
            SELECT ID, Name, CN_Need_Send_MG_Flag__c 
            FROM Account
            WHERE (CN_Customer_Code__c != null OR CN_Inactive__c = true)
                AND CN_Account_Source__c = :Constants.CN_ACCOUNT_SOURCE_ECOMMERCE
                AND OwnerId = :needSendId
                AND CN_Need_Send_MG_Flag__c!=2
        ];
    
        for (Account acc : accountList) {
            acc.CN_Need_Send_MG_Flag__c = 2;
        }
    
        //add by ZhangZhiHao  Added non-null modification check 2024/4/3
        if(accountList != null && !accountList.isEmpty()) {
            update accountList;
        }
         //add by ZhangZhiHao  Added non-null modification check 2024/4/3

        List<User> usersToUpdate = new List<User>();
        for(User user : users) {
            user.CN_Email_Verified_Need_Sync__c = false;
            usersToUpdate.add(user);
        }
        try{
            if(!usersToUpdate.isEmpty()) {
                update usersToUpdate;
            }
        }catch (Exception e) {
            System.debug('An error occurred while updating User records: ' + e.getMessage());
            // Handle the exception as needed
        }
    }

    public void finish(Database.BatchableContext param1) {

	}
}
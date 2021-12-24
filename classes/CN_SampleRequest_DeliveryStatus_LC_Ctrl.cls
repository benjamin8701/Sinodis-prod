/**************************************************************************************************
 * Name           : CN_SampleRequest_DeliveryStatus_LC_Ctrl
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Chu Shuqi
 * Create Date    : 2021-12-21
 * Modify History : 
 **************************************************************************************************/
public class CN_SampleRequest_DeliveryStatus_LC_Ctrl {
    @AuraEnabled
    public static void searchSampleRequest(String recordId){
        String reId = recordId;
        system.debug('test1');
        CN_Sample_Request__c sampleRequest = Database.query('Select CN_Is_Send_Delivery_Email__c, Id from CN_Sample_Request__c where id in ( \''+reId+'\')');
        sampleRequest.CN_Is_Send_Delivery_Email__c = !sampleRequest.CN_Is_Send_Delivery_Email__c;
        update sampleRequest;
    }

}
/**************************************************************************************************
 * Name           : CN_Contact_Registered_Insert_Rest_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2023-12-24
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Contact_Registered_Insert_Rest_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    static void testPostMethod() {
        
        // Create test data
        Map<String, Object> requestBody = new Map<String, Object>();
        List<Map<String, Object>> datas = new List<Map<String, Object>>();
        
        // Prepare data for insert
        Map<String, Object> dataToInsert = new Map<String, Object>();
        dataToInsert.put('firstName', 'John');
        dataToInsert.put('lastName', 'Doe');
        dataToInsert.put('email', 'johndoe@example.com');
        dataToInsert.put('mgContactID', '1');
        dataToInsert.put('flag', '01');
        datas.add(dataToInsert);
        
        // Prepare data for inactive
        Map<String, Object> dataToInactive = new Map<String, Object>();
        dataToInactive.put('mgContactID', '2');
        dataToInactive.put('flag', '02');
        datas.add(dataToInactive);
        
        requestBody.put('datas', datas);
        String requestJson = JSON.serialize(requestBody);
        
        // Set request context
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ContactRegisteredInsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestJson);
        RestContext.request = request;
        RestContext.response= res;
        
        // Perform the callout
        Test.startTest();
        CN_Contact_Registered_Insert_Rest.post();
        Test.stopTest();
        // Add more log asserts as needed
    }

    @isTest
    static void testPostMethod_ErrorCase() {
        
        // Create test data
        Map<String, Object> requestBody = new Map<String, Object>();
        List<Map<String, Object>> datas = new List<Map<String, Object>>();
        
        // Prepare data with missing required fields for insert
        Map<String, Object> dataToInsert = new Map<String, Object>();
        dataToInsert.put('firstName', 'John');
        dataToInsert.put('lastName', 'Doe');
        // Missing email and mgContactID fields
        dataToInsert.put('flag', '01');
        datas.add(dataToInsert);
        
        Map<String, Object> dataToInsertFlagException = new Map<String, Object>();
        dataToInsertFlagException.put('firstName', 'John');
        dataToInsertFlagException.put('lastName', 'Doe');
        dataToInsertFlagException.put('email', 'johndoe@example.com');
        dataToInsertFlagException.put('mgContactID', '3');
        dataToInsertFlagException.put('flag', '04');
        datas.add(dataToInsertFlagException);

        Map<String, Object> dataToInsertFieldNullException = new Map<String, Object>();
        dataToInsertFieldNullException.put('firstName', 'John');
        dataToInsertFieldNullException.put('lastName', null);
        dataToInsertFieldNullException.put('email', 'johndoe2@example.com');
        dataToInsertFieldNullException.put('mgContactID', '4');
        dataToInsertFieldNullException.put('flag','01');
        datas.add(dataToInsertFieldNullException);

        Map<String, Object> dataToInsertMailFormatException = new Map<String, Object>();
        dataToInsertMailFormatException.put('firstName', 'John');
        dataToInsertMailFormatException.put('lastName', 'Doe');
        dataToInsertMailFormatException.put('email', '123');
        dataToInsertMailFormatException.put('mgContactID', '5');
        dataToInsertMailFormatException.put('flag', '01');
        datas.add(dataToInsertMailFormatException);

        requestBody.put('datas', datas);
        String requestJson = JSON.serialize(requestBody);
        
        // Set request context
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ContactRegisteredInsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestJson);
        RestContext.request = request;
        RestContext.response= res;
        // Perform the callout
        Test.startTest();
        CN_Contact_Registered_Insert_Rest.post();
        Test.stopTest();
    }

    @isTest
    static void testPostMethodNoneData() {

        // Create test data
        Map<String, Object> requestBody = new Map<String, Object>();

        // Set request context
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ContactRegisteredInsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = request;
        RestContext.response= res;
        // Perform the callout
        Test.startTest();
        CN_Contact_Registered_Insert_Rest.post();
        Test.stopTest();
    }

    @isTest
    static void testPostMethodNoneField() {

        // Create test data
        Map<String, Object> requestBody = new Map<String, Object>();
        List<Map<String, Object>> datas = new List<Map<String, Object>>();

        // Prepare data for insert
        Map<String, Object> dataToInsert = new Map<String, Object>();
        dataToInsert.put('firstName', 'John');
        datas.add(dataToInsert);

        requestBody.put('datas', datas);
        String requestJson = JSON.serialize(requestBody);

        // Set request context
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ContactRegisteredInsert';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestJson);
        RestContext.request = request;
        RestContext.response= res;

        // Perform the callout
        Test.startTest();
        CN_Contact_Registered_Insert_Rest.post();
        Test.stopTest();
        // Add more log asserts as needed
    }
}
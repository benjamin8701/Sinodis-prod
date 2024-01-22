@RestResource(urlMapping='/MessagingApi/*')
global without sharing class CN_MessagingHelperClass {

    private static List<Map<String, Object>> errorPathRes = new List<Map<String, Object>> {
        new Map<String, Object> {
            'message' => 'Could not find a match for URL',
            'errorCode' => 'NOT_FOUND'
        } 
    };

    @HttpPost
    global static void Post() {
        Object result;
        String functionName = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/')+1);
        switch on functionName {
            when 'returnJWT' {
                result = returnJWT();
            }
            when 'feedback' {
                result = feedback();
            }
            when else {
                result = errorPathRes;
            }
        }
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Blob responseBody = Blob.valueOf(JSON.serialize(result));
        res.responseBody = responseBody;
    }

    private static String PaddingChars(String input, Integer blockSize) {
        Integer paddingSize = blockSize - Math.mod(input.length(), blockSize);
        if (paddingSize == blockSize) {
            paddingSize = 0;
        }
        List<Integer> paddingChars = new List<Integer>();
        for (Integer i = 0; i < paddingSize; i++) {
            paddingChars.add(0);
        }
        String padding = String.fromCharArray(paddingChars);
        return input + padding;
    }

    private static Object returnJWT() {
        Map<String, Object> result = new Map<String, Object>();

        string strBody = RestContext.request.requestBody.toString();
        Map<String,Object> mapBody = (Map<String,Object>)JSON.deserializeUntyped(strBody);

        if (mapBody.containsKey('uid') == false) {
            result.put('ERROR', 'Process error');
            return result;
        }
        String uid = (String)mapBody.get('uid');
        String iss = 'savenciasinodis';
        String aud = 'MessagingJWT';
        Long exp = DateTime.now().addMinutes(5).getTime();

        CN_Messaging_Setting__mdt setting = [SELECT Id, CN_JWT_privateKey__c, CN_AES_privateKey__c, CN_AES_IV__c
            FROM CN_Messaging_Setting__mdt WHERE DeveloperName = 'CN_Messaging_Setting_Data'][0];

        try {
            Blob aeskey = Blob.valueOf(PaddingChars(setting.CN_AES_privateKey__c, 16));
            Blob aesIv = Blob.valueOf(PaddingChars(setting.CN_AES_IV__c, 16));
            Blob encrypted = EncodingUtil.base64Decode(uid);
            Blob decrypted = Crypto.decrypt('AES128', aeskey, aesIv, encrypted);
            uid = decrypted.toString();
        } catch (Exception ex) {
            result.put('ERROR', 'Process error');
            return result;
        }

        String jwtPayload = JSON.serialize(new Map<String, Object> {
            'iss' => iss,
            'sub' => uid,
            'aud' => aud,
            'exp' => exp
        });
        String jwtHeader = JSON.serialize(new Map<String, Object> {
            'kid' => mapBody.containsKey('kid') ? mapBody.get('kid') : 'JWT_Cert',
            'alg' => mapBody.containsKey('alg') ? mapBody.get('alg') : 'RS256',
            'typ' => mapBody.containsKey('typ') ? mapBody.get('typ') : 'JWT'
        });

        String jwtClearPart = String.format('{0}.{1}', new List<Object>{
            // Salesforce doesn't give us a method for base64url encoding, so we need to do that ourselves
            System.EncodingUtil.base64Encode(Blob.valueOf(jwtHeader)).replace('+', '-').replace('/', '_').replace('=', ''),
            System.EncodingUtil.base64Encode(Blob.valueOf(jwtPayload)).replace('+', '-').replace('/', '_').replace('=', '')
        });

        Blob jwtPrivateKey = EncodingUtil.base64Decode(setting.CN_JWT_privateKey__c);

        Blob jwtSig = System.Crypto.sign('RSA-SHA256', Blob.valueOf(jwtClearPart), jwtPrivateKey);
        String jwt = String.format('{0}.{1}', new List<Object>{
            jwtClearPart, 
            System.EncodingUtil.base64Encode(jwtSig).replace('+', '-').replace('/', '_').replace('=', '')
        });
        result.put('JWT', jwt);
        result.put('Get', jwtPayload);
        result.put('uid', uid);

        if (mapBody.containsKey('last_sub') || mapBody.containsKey('last_orderid')) {
            List<MessagingEndUser> ltMsgUsers = [SELECT Id FROM MessagingEndUser WHERE CN_MG_Contact_ID__c = :uid];
            if (ltMsgUsers.size() > 0) {
                ltMsgUsers[0].CN_last_sub__c = (String)mapBody.get('last_sub');
                ltMsgUsers[0].CN_last_orderid__c = (String)mapBody.get('last_orderid');
                update ltMsgUsers[0];
            }
        }

        return result;
    }

    
    private static Object feedback() {
        Map<String, Object> result = new Map<String, Object>();

        string strBody = RestContext.request.requestBody.toString();
        try {
            Map<String,Object> mapBody = (Map<String,Object>)JSON.deserializeUntyped(strBody);

            if (mapBody.containsKey('Id') && mapBody.containsKey('value')) {
                Case updateRecord = new Case();
                updateRecord.CN_Appraise__c = String.valueOf(mapBody.get('value'));
                if (mapBody.containsKey('suggestion')) {
                    updateRecord.CN_suggestion__c = String.valueOf(mapBody.get('suggestion'));
                }

                Id recordId = Id.valueOf(String.valueOf(mapBody.get('Id')));
                List<MessagingSession> ltMsgSessions = [SELECT Id, CaseId FROM MessagingSession WHERE Id = :recordId];
                if (ltMsgSessions.size() > 0) {
                    updateRecord.Id = ltMsgSessions[0].CaseId;
                    update updateRecord;
                }
            }
            result.put('message', 'OK');
            result.put('errorCode', null);
        } catch (Exception ex) {
            result.put('message', ex.getMessage());
            result.put('errorCode', 'PROCESS_ERROR');
        }

        return result;
    }
}
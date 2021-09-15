({
	doInit : function(component, event, helper) {
        
        component.set("v.moduleName", $A.get("{!$Label.c.CN_Quote_Name}"));
        component.set("v.title", helper.format($A.get("{!$Label.c.CN_Quote_Retrieve_Title}") , [component.get("v.moduleName")]));
        
        let getCFRMMsg = $A.get("{!$Label.c.CN_CustomerHierarchy_Confirm_Msg}");
        component.set("v.confirmMsg", getCFRMMsg);
        console.log("v.confirmMsg: " + getCFRMMsg);
        
        let getQuoteInfoAndCheckEditPermisisonAction = component.get("c.getQuoteInfoAndCheckEditPermisison");
        getQuoteInfoAndCheckEditPermisisonAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        let getQuoteInfoAndCheckEditPermisisonActionPromise = helper.callServerAction(component, getQuoteInfoAndCheckEditPermisisonAction);
        getQuoteInfoAndCheckEditPermisisonActionPromise.then(function(_returnValue){
            
            let hasPermission = _returnValue["hasCreatePermission"];
            console.log(hasPermission);
            let errorMsg = _returnValue["errorMsg"];
            console.log(errorMsg);
            
            if(errorMsg != null && errorMsg != undefined && errorMsg != {} && errorMsg != "") {
                component.set("v.modalContentMessage", errorMsg);
                component.set("v.isBtnDisabled", true);
            } else {
                let getSendMsg = helper.format($A.get("{!$Label.c.CN_Quote_Send_To_SAP}") , [component.get("v.moduleName")]);
                component.set("v.modalContentMessage", getSendMsg);
                component.set("v.isBtnDisabled", false);
            }
        }).catch(function(_error) {
            let errorMsg = "";
            console.error(_error);
            try {
                errorMsg = JSON.parse(_error.message)[0].message;
            } catch (error) {
                errorMsg = "";
            }
            component.set("v.modalContentMessage", errorMsg);
            component.set("v.isBtnDisabled", true);
        }).finally(function() {
        });
    },
	confirmAction : function(component, event, helper) {
        
        component.set("v.showLoading", true);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        let myAction = component.get("c.sendQuote");
        myAction.setParams({
            "recordId": component.get("v.recordId")
        });
        let myAcitonPromise = helper.callServerAction(component, myAction);
        myAcitonPromise.then(function(_returnValue) {

            // Display the total in a "toast" status message
            var resultsToast = $A.get("e.force:showToast");
            if(_returnValue["isSendSuccess"]) {
                let getSendSuccessMsg = helper.format($A.get("{!$Label.c.CN_Quote_Send_Success_Msg}") , [component.get("v.moduleName")]);
                resultsToast.setParams({
                    "type": "success",
                    "title": "Success",
                    "message": getSendSuccessMsg
                });
                resultsToast.fire();
                dismissActionPanel.fire();
            } else {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Failed",
                    "message": _returnValue["errorMessage"]
                });
                resultsToast.fire();
                component.set("v.modalContentMessage",  _returnValue["errorMessage"]);
                component.set("v.isBtnDisabled", true);
            }
        }).catch(function(_error) {
                let errorMsg = "";
                console.error(_error);
                try {
                    errorMsg = JSON.parse(_error.message)[0].message;
                } catch (error) {
                    errorMsg = "";
                }
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Failed",
                    "message": errorMsg
                });
                resultsToast.fire();
                component.set("v.modalContentMessage", errorMsg);
                component.set("v.isBtnDisabled", true);
        }).finally(function() {
            component.set("v.showLoading", false);
        });
	},
    closeAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
 		dismissActionPanel.fire();
    }
})
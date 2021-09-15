({
	doInit : function(component, event, helper) {
        let getCFRMMsg = $A.get("{!$Label.c.CN_Quote_Apply_CFRM_Msg}");
        component.set("v.confirmMsg", getCFRMMsg);
        console.log("v.confirmMsg: " + getCFRMMsg);
        let getEditPermissionAndQuoteInfoAction = component.get("c.getQuoteInfoAndCheckEditPermisison");
        getEditPermissionAndQuoteInfoAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        let getEditPermissionAndQuoteInfoActionPromise = helper.callServerAction(component, getEditPermissionAndQuoteInfoAction);
        getEditPermissionAndQuoteInfoActionPromise.then(function(_returnValue){
            let hasPermission = _returnValue["hasCreatePermission"];
            console.log(hasPermission);
            let errorMsg = _returnValue["errorMsg"];
            console.log(errorMsg);
            if(errorMsg != null && errorMsg != undefined && errorMsg != {} && errorMsg != "") {
                component.set("v.modalContentMessage", errorMsg);
                component.set("v.isBtnDisabled", true);
            } else {
                let getSendMsg = $A.get("{!$Label.c.CN_Quote_Apply}");
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
        let myAction = component.get("c.applyQuote");
        myAction.setParams({
            "recordId": component.get("v.recordId")
        });
        let myAcitonPromise = helper.callServerAction(component, myAction);
        myAcitonPromise.then(function(_returnValue) {

            // Display the total in a "toast" status message
            var resultsToast = $A.get("e.force:showToast");
            if(_returnValue["isApplySuccess"]) {
                let getSendSuccessMsg = $A.get("{!$Label.c.CN_Account_Send_Success_Msg}");
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
                component.set("v.isBtnDisabled", true);
        }).finally(function() {
            component.set("v.showLoading", false);
            $A.get('e.force:refreshView').fire();
        });
	},
    closeAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
 		dismissActionPanel.fire();
    }
})
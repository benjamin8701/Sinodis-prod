({
	doInit : function(component, event, helper) {
        let getIfAcceptedAllItemsAction = component.get("c.getIfAcceptedAllItems");
        getIfAcceptedAllItemsAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        
        let getIfAcceptedAllItemsActionPromise = helper.callServerAction(component, getIfAcceptedAllItemsAction);
        getIfAcceptedAllItemsActionPromise.then(function(_returnValue){
            let ifAcceptedAllItems = _returnValue["ifAcceptedAllItems"];
            console.log(ifAcceptedAllItems);
            component.set("v.ifAcceptedAllItems", ifAcceptedAllItems);
            //let ifApproved = _returnValue["ifApproved"];
            //console.log(ifApproved);
            //component.set("v.ifApproved", ifApproved);
            let hasQuoteItems = _returnValue["hasQuoteItems"];
            console.log(hasQuoteItems);
            component.set("v.isBtnDisabled", !hasQuoteItems);
            let errorMsg = _returnValue["errorMsg"];
            console.log(errorMsg);
            
            let modalContentMessage = "";
            
            if(errorMsg != null && errorMsg != undefined && errorMsg != {} && errorMsg != "") {
                component.set("v.modalContentMessage", errorMsg);
                component.set("v.isBtnDisabled", true);
            }else{
                if(!hasQuoteItems){
                    modalContentMessage = $A.get("{!$Label.c.CN_Quote_Not_Have_Items}");
                }else if(!ifAcceptedAllItems && hasQuoteItems){
                    modalContentMessage = $A.get("{!$Label.c.CN_Quote_CFAA_Msg}");
                }else if(ifAcceptedAllItems && hasQuoteItems){
                    modalContentMessage = $A.get("{!$Label.c.CN_Quote_CFDA_Msg}");
                }
                component.set("v.modalContentMessage", modalContentMessage);
            }
			console.log("v.modalContentMessage: " + modalContentMessage);      

        }).catch(function(_error) {
            let errorMsg = "";
            console.error(_error);
            try {
                errorMsg = JSON.parse(_error.message)[0].message;
            } catch (error) {
                errorMsg = "";
            }
            component.set("v.modalContentMessage", errorMsg);
        }).finally(function() {
        });
    },
	confirmAction : function(component, event, helper) {
        component.set("v.showLoading", true);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        let myAction = component.get("c.acceptOrDenyAllQuoteItems");
        myAction.setParams({
            "recordId": component.get("v.recordId"),
            "ifAcceptedAllItems": component.get("v.ifAcceptedAllItems")
        });
        
		let myActionPromise = helper.callServerAction(component, myAction);
        myActionPromise.then(function(_returnValue){
            var resultsToast = $A.get("e.force:showToast");
            if(_returnValue["isUpdateSuccess"]) {
                let DealSuccessMsg = $A.get("{!$Label.c.CN_Quote_Deal_Success_Msg}");
                resultsToast.setParams({
                    "type": "success",
                    "title": "Success",
                    "message": DealSuccessMsg
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
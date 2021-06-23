({
    doInit : function(component, event, helper) {
        component.set("v.modalContentMessage", $A.get("$Label.c.CN_Sales_Order_Confirm_Msg"));
    },
    doConfirm : function(component, event, helper) {
        component.set("v.showLoading", true);
        component.set("v.isBtnDisabled", true);
        let retrieveSOStatusAction = component.get("c.retrieveSOStatus");
        retrieveSOStatusAction.setParams({
            "salesOrderId" : component.get("v.recordId")
        });
        helper.callServerAction(component, retrieveSOStatusAction).then(function(_return) { 
            component.set("v.modalContentMessage", $A.get("$Label.c.CN_Sales_Order_Retrieve_Success"));
            helper.showToast(component, "Success", $A.get("$Label.c.CN_Sales_Order_Retrieve_Success"), "success");
            component.set("v.isBtnDisabled", true);
            component.set("v.buttonName", "Close");
        }).catch(function(_error) {
            let errorMsg = "";
            console.error(_error);
            try {
                errorMsg = JSON.parse(_error.message)[0].message;
            } catch (error) {
                errorMsg = "";
            }
            component.set("v.modalContentMessage", errorMsg);
            component.set("v.isBtnDisabled", false);
            helper.showToast(component, "ERROR", errorMsg, "error");
        }).finally(function() {
            component.set("v.showLoading", false);

        });
    },
    closeAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
 		dismissActionPanel.fire();
    }
})
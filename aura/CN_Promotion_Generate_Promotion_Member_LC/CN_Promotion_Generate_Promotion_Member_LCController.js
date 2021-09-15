({
	doInit : function(component, event, helper) {
        var resultsToast = $A.get("e.force:showToast");
        
        let generateProMemberAction = component.get("c.generateProMember"); 
        generateProMemberAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        let generateProMemberActionPromise = helper.callServerAction(component, generateProMemberAction);
        generateProMemberActionPromise.then(function(_returnValue){
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
            component.set("v.showLoading", false);
            $A.get('e.force:refreshView').fire();
        });
    },
    closeAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
 		dismissActionPanel.fire();
    }
})
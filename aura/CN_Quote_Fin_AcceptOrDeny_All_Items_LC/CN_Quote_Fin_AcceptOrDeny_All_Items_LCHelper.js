({
    doAction : function(component,event,helper) {
        var action = component.get("c.acceptOrDenyAll");
        action.setParams({
            "QuoteId": component.get("v.recordId")
        });	
        action.setCallback(this, function(response){
            var state = response.getState();
            $A.get("e.force:closeQuickAction").fire();
            if (state === "SUCCESS") {                
                var url = response.getReturnValue();
                console.log(url);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    title: "Success!",
                    type:"success",
                    message: $A.get("{!$Label.c.CN_Quote_Deal_Success_Msg}")                    
                });
                 $A.get('e.force:refreshView').fire();
                resultsToast.fire();
            }else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
                if (errors) {                        
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type":"error",
                        "mode":"sticky",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
    }
})
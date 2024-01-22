({
    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    confirmModel: function(component, event, helper) {
         component.set("v.isModalOpen", false);
        component.set("v.spinner", true);

        var action = component.get("c.sendMgArrivalStatus");
        var arrivalReminderIdString = component.get("v.arrivalReminderIdString");

        action.setParams({
            "arrivalReminderIdString": arrivalReminderIdString
        });

            action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('State: ', state);
            if (state === "SUCCESS") {
                var jsonResponse = response.getReturnValue();
                if(jsonResponse == 'Already notified'){
                    var toastEvent = $A.get("e.force:showToast");
                    var msg = "Already notified,please don't repeat";
                    toastEvent.setParams({
                        "type": "success",
                        "message": msg
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
            }
                console.log('jsonResponse: ',jsonResponse); // Use console.log() for debugging in Lightning component
                var responseVar = JSON.parse(jsonResponse);
                console.log('responseVar.code: ',responseVar.code); 
                if (responseVar.code == 1) {
                    // window.open(responseVar.msg);
                    var toastEvent = $A.get("e.force:showToast");
                    var msg = "OK";
                    toastEvent.setParams({
                        "type": "success",
                        "message": msg
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    console.log('Error response: ', response.getError()); // Add this line for debugging
                    var toastEvent = $A.get("e.force:showToast");
                    var msg = responseVar.msg;
                    toastEvent.setParams({
                        "type": "error",
                        "message": msg
                    });
                    toastEvent.fire();
                }
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "State not success while calling Apex method."
                });
                toastEvent.fire();
            }

            component.set("v.spinner", false);
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });

        $A.enqueueAction(action);

    }
})
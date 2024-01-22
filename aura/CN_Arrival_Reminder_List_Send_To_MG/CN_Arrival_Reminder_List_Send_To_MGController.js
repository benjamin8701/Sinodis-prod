({
    doInit: function (component, event, helper) {
        // 获取 selectedIds 属性
        var selectedIds = component.get("v.selectedIds");
        
        // 检查 selectedIds 是否为空
        if (selectedIds.length === 0) {
            // 如果为空，显示提示框
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error",
                "message": "No items are selected.",
                "type": "error"
            });
            toastEvent.fire();
        } else {
            // 执行其他逻辑，处理非空的情况
        }
    }
})
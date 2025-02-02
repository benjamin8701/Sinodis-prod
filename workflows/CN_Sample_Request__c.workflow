<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CN_SR_Approved</fullName>
        <description>CN_SR_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Sample_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>CN_SR_Approved_Process_CS</fullName>
        <description>CN_SR_Approved_Process_CS</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>CN_CS_Team_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Sample_Request_Approved_Process_CS</template>
    </alerts>
    <alerts>
        <fullName>CN_SR_Delivery_Status</fullName>
        <description>CN_SR_Delivery_Status</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_SR_Delivery_Status</template>
    </alerts>
    <alerts>
        <fullName>CN_SR_Rejected</fullName>
        <description>CN_SR_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Sample_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>CN_Sample_Request_Approval</fullName>
        <description>CN_Sample_Request_Approval</description>
        <protected>false</protected>
        <recipients>
            <field>CN_Approver1_CCE__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Sample_Request_Submit</template>
    </alerts>
    <alerts>
        <fullName>CN_Sample_Request_Approved_Cancelled</fullName>
        <description>CN_Sample_Request_Approved_Cancelled</description>
        <protected>false</protected>
        <recipients>
            <field>CN_CS_Team_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Sample_Request_Approved_Cancelled</template>
    </alerts>
    <alerts>
        <fullName>CN_Sample_Request_Approved_Cancelled_CCE</fullName>
        <description>CN_Sample_Request_Approved_Cancelled_CCE</description>
        <protected>false</protected>
        <recipients>
            <field>CN_CCE_Team_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Sample_Request_Approved_Cancelled_CCE</template>
    </alerts>
    <alerts>
        <fullName>CN_Sample_Request_Approved_Process_CCE</fullName>
        <description>CN_Sample_Request_Approved_Process_CCE</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>CN_CCE_Team_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_Sample_Request_Approved_Process_CCE</template>
    </alerts>
    <alerts>
        <fullName>CN_Sample_Request_Repack_DeliveryAll_Alert</fullName>
        <description>CN_Sample_Request_Repack_DeliveryAll_Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CN_Email_Folder/CN_SR_Repack_DeliveryAll_Sales</template>
    </alerts>
    <fieldUpdates>
        <fullName>CN_Is_Send_Delivery_Email_False</fullName>
        <field>CN_Is_Send_Delivery_Email__c</field>
        <literalValue>0</literalValue>
        <name>CN_Is_Send_Delivery_Email_False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SR_Empty_ConditionType</fullName>
        <field>CN_Condition_Type__c</field>
        <name>CN_SR_Empty_ConditionType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SR_Populate_ConditionType</fullName>
        <field>CN_Condition_Type__c</field>
        <literalValue>5CCE2404 – CCE Sample</literalValue>
        <name>CN_SR_Populate_ConditionType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SR_Populate_OrderType_ZFD1</fullName>
        <field>CN_Order_Type_for_Wholepack__c</field>
        <literalValue>ZFD1 Sample for Customer</literalValue>
        <name>CN_SR_Populate_OrderType_ZFD1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SR_Populate_OrderType_ZFD3</fullName>
        <field>CN_Order_Type_for_Wholepack__c</field>
        <literalValue>ZFD3 - BPP sample</literalValue>
        <name>CN_SR_Populate_OrderType_ZFD3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SR_Update_Approved_Date</fullName>
        <field>CN_Approved_Date__c</field>
        <formula>NOW()</formula>
        <name>CN_SR_Update_Approved_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SR_Update_Status_Approved</fullName>
        <field>CN_Sample_Request_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>CN_SR_Update_Status_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SR_Update_Status_Recalled</fullName>
        <field>CN_Sample_Request_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>CN_SR_Update_Status_Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SR_Update_Status_Rejected</fullName>
        <field>CN_Sample_Request_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>CN_SR_Update_Status_Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SR_Update_Status_Submit</fullName>
        <field>CN_Sample_Request_Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>CN_SR_Update_Status_Submit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN Send Delivery Status</fullName>
        <actions>
            <name>CN_SR_Delivery_Status</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(CN_Is_Send_Delivery_Email__c  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_SR_Populate_Approver1_CCE1</fullName>
        <active>false</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c, NOT(ISBLANK(CN_Account_Name__c)),  ISCHANGED(CN_Account_Name__c),  CN_Account_Name__r.CN_Sales_Team_UI__r.Name == &apos;KA&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_SR_Populate_OrderType_ZFD1</fullName>
        <actions>
            <name>CN_SR_Empty_ConditionType</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CN_SR_Populate_OrderType_ZFD1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Account has the customer Code , populate the Order type for wholesales with ZFD1</description>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,   RecordType.DeveloperName = &quot;CN_Whole_Pack&quot;,   OR(      ISCHANGED(CN_Opportunity_Name__c),      ISNEW()   ),   NOT(ISBLANK(CN_Opportunity_Name__r.Account.CN_Customer_Code__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_SR_Populate_OrderType_ZFD3</fullName>
        <actions>
            <name>CN_SR_Populate_ConditionType</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CN_SR_Populate_OrderType_ZFD3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Account has not the customer Code , populate the Order type for wholesales with ZFD3</description>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,   RecordType.DeveloperName = &quot;CN_Whole_Pack&quot;,   OR(      ISCHANGED(CN_Opportunity_Name__c),      ISNEW()   ),   ISBLANK(CN_Opportunity_Name__r.Account.CN_Customer_Code__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Sample_Request_Approved_Cancelled</fullName>
        <actions>
            <name>CN_Sample_Request_Approved_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,    RecordType.DeveloperName = &quot;CN_Whole_Pack&quot;, NOT(ISNEW()),   ISCHANGED( CN_Sample_Request_Status__c ),    ISPICKVAL( CN_Sample_Request_Status__c  , &apos;Canceled&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Sample_Request_Approved_Cancelled_CCE</fullName>
        <actions>
            <name>CN_Sample_Request_Approved_Cancelled_CCE</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,  RecordType.DeveloperName = &quot;CN_Office_Repack&quot;,   NOT(ISNEW()),   ISCHANGED( CN_Sample_Request_Status__c ),    ISPICKVAL( CN_Sample_Request_Status__c  , &apos;Canceled&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Sample_Request_Repack_DeliveryAll_Alert</fullName>
        <actions>
            <name>CN_Sample_Request_Repack_DeliveryAll_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,    NOT(ISNEW()),    RecordType.DeveloperName = &apos;CN_Office_Repack&apos;,   OR(     ISCHANGED(CN_SP_Records_Count_Delivery_Status_Done__c),     ISCHANGED(CN_SP_Records_Count_All__c)   ),   CN_SP_Records_Count_Delivery_Status_Done__c = CN_SP_Records_Count_All__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

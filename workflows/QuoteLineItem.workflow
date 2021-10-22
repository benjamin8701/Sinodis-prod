<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_QuoteItem_Clear_DenyReason</fullName>
        <field>CN_Denied_Reason__c</field>
        <name>CN_QuoteItem_Clear_DenyReason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_QuoteItem_Populate_ExternalId</fullName>
        <field>CN_External_Id__c</field>
        <formula>Product2Id  &amp; &apos;-&apos; &amp;  QuoteId</formula>
        <name>CN_QuoteItem_Populate_ExternalId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_QuoteItem_Populate_Tax</fullName>
        <field>CN_Tax__c</field>
        <formula>CN_Tax_Formula__c</formula>
        <name>CN_QuoteItem_Populate_Tax</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_QuoteItem_Clear_DenyReason</fullName>
        <actions>
            <name>CN_QuoteItem_Clear_DenyReason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c ,    ISCHANGED( CN_Customer_Acceptance__c ),   ISPICKVAL(CN_Customer_Acceptance__c , &quot;Accepted&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_QuoteItem_Populate_Tax</fullName>
        <actions>
            <name>CN_QuoteItem_Populate_Tax</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CN_QuoteItem_Prevent_Dupilcate</fullName>
        <actions>
            <name>CN_QuoteItem_Populate_ExternalId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(        $Setup.Trigger_Switcher_Setting__c.EnableFlow__c,     OR(         ISNEW(),         AND(           NOT(ISNEW()),           ISCHANGED( Product2Id )         )     ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

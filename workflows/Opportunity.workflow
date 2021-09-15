<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_Opp_Set_Close_Date</fullName>
        <field>CloseDate</field>
        <formula>TODAY() + 90</formula>
        <name>CN_Opp_Set_Close_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Opp_Set_Close_Date</fullName>
        <actions>
            <name>CN_Opp_Set_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c , RecordType.DeveloperName = &apos;CN_Opportunity&apos;, NOT(CN_Is_Manual__c) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

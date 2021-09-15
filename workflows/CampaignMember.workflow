<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_CM_Populate_Type</fullName>
        <field>CN_Type__c</field>
        <formula>IF(NOT(ISBLANK(AccountId)), &apos;Account&apos;, IF(NOT(ISBLANK(LeadId)), &apos;Lead&apos;, IF(NOT(ISBLANK(ContactId)), &apos;Contact&apos;, &apos;&apos;)))</formula>
        <name>CN_CM_Populate_Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_CM_Populate_Type</fullName>
        <actions>
            <name>CN_CM_Populate_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.Trigger_Switcher_Setting__c.EnableFlow__c</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

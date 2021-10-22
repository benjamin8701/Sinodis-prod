<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_Campaign_Auto_Active</fullName>
        <field>IsActive</field>
        <literalValue>1</literalValue>
        <name>CN_Campaign_Auto_Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Campaign_Auto_Active</fullName>
        <actions>
            <name>CN_Campaign_Auto_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

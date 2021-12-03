<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>User_Sales_Team</fullName>
        <field>CN_Sales_Team_For_Report__c</field>
        <formula>VALUE(CN_Sales_Team__c)</formula>
        <name>User Sales Team</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>User Sales Team</fullName>
        <actions>
            <name>User_Sales_Team</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( CN_Sales_Team__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

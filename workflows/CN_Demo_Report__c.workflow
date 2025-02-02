<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_Demo_Report_Set_External_Id</fullName>
        <field>CN_External_Id__c</field>
        <formula>CASESAFEID(CreatedById ) + &quot;-&quot; +  CASESAFEID( CN_Chef_Request__c )</formula>
        <name>CN_Demo_Report_Set_External_Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Demo_Report_Set_External_Id</fullName>
        <actions>
            <name>CN_Demo_Report_Set_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c ,   OR( ISNEW(), ISCHANGED( CN_Chef_Request__c ) )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

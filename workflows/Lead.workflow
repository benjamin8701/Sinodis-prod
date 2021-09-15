<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_Lead_Change_Status_Assigned</fullName>
        <field>Status</field>
        <literalValue>Assigned</literalValue>
        <name>CN_Lead_Change_Status_Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Lead_Empty_Is_From_Web_To_Lead</fullName>
        <field>CN_Is_From_Web_To_Lead__c</field>
        <literalValue>0</literalValue>
        <name>CN_Lead_Empty_Is_From_Web_To_Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Lead_Set_Status_To_Sales_Qualified</fullName>
        <field>Status</field>
        <literalValue>Sales Qualified</literalValue>
        <name>CN_Lead_Set_Status_To_Sales_Qualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_Lead_Status_Open</fullName>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>CN_Lead_Status_Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Lead_Empty_Is_From_Web_To_Lead</fullName>
        <actions>
            <name>CN_Lead_Empty_Is_From_Web_To_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c , 
  RecordType.DeveloperName = &apos;CN_Lead&apos;,  
  $Profile.Name = &quot;System Integration&quot;
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Lead_MDM_Change_Owner</fullName>
        <actions>
            <name>CN_Lead_Change_Status_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( $Setup.Trigger_Switcher_Setting__c.EnableFlow__c , RecordType.DeveloperName = &apos;CN_Lead&apos;,  ISPICKVAL( Status , &quot;MKT Qualified&quot;),  ISCHANGED( OwnerId ),  Owner:User.Profile.Name = &quot;CN Sales&quot; ||  Owner:User.Profile.Name = &quot;CN Sales Lead&quot; ||  Owner:User.Profile.Name = &quot;CN Sales Manager&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_Lead_MKTorCCE_Create_Lead</fullName>
        <actions>
            <name>CN_Lead_Status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   $Setup.Trigger_Switcher_Setting__c.EnableFlow__c ,    RecordType.DeveloperName = &apos;CN_Lead&apos;,   $Permission.CN_Marketing_Lead_Manager  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CN_Lead_Sales_Create_Lead</fullName>
        <actions>
            <name>CN_Lead_Set_Status_To_Sales_Qualified</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c , RecordType.DeveloperName = &apos;CN_Lead&apos;,  OR(    $Profile.Name = &quot;CN Sales&quot;,    $Profile.Name = &quot;CN Sales Manager&quot;,    $Profile.Name = &quot;CN Sales Lead&quot;  ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

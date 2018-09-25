/*
 * Copyright (c) 2018, Salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root
 */
 
 global class PEExamplePostInstall implements InstallHandler {
 
  global void onInstall(InstallContext context) {

    // Prepare two emails to inform about how post install went
    User u = [Select Id, Name, Username, Email from User where Id =:context.installerID()];
    String[] toAddresses = new String[]{ u.Email };
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toAddresses);
    mail.setSubject('Package install information');

    String message = 'Post-install information ... ';
    try {
        // Get the 'External Processing Example App' Connected Application and add it to the 'PE_Example_Access' permission set
        List<ConnectedApplication> connApps = [SELECT Id, Name FROM ConnectedApplication WHERE Name = 'Process Externally Example App'];
        ConnectedApplication connApp;
        if (connApps.size() == 0) {
             message += 'No Connected app found';       
        } else {
            connApp = connApps[0];
            message += 'Connected app = ' + connApp;
            List<SetupEntityAccess> accessRows = [SELECT Id, ParentId, SetupEntityId from SetupEntityAccess WHERE SetupEntityId=:connApp.Id];
            message += '. SetupEntityAccess = ' + accessRows;
            if (accessRows.size() == 0) {
                PermissionSet permSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'PE_Example_Access' LIMIT 1];
                message += '. PermissionSet ' + permSet;

                SetupEntityAccess entAccess = new SetupEntityAccess(parentId=permSet.Id, SetupEntityId=connApp.Id);
                message += '. SetupEntityAccess ' + entAccess;
                insert entAccess;
                message += ' saved. ';

                AssignPermissionSet(u.Id, permSet.Id);
            }
        }  
    } catch(Exception e) {
        System.debug('Exception during post install access management: ' + e);
        message += '. Exception = ' + e;
    }
    
    System.debug(message);
    mail.setPlainTextBody(message);
    //Messaging.sendEmail(new Messaging.Email[] { mail });

    RegisterWithBusinessOrg(context.installerID());
  }

  @future
  global static void AssignPermissionSet(String userId, String permSetId) {
    try {
        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId=userId, PermissionSetId=permSetId);
        insert assignment;
    } catch(Exception e) {
        System.debug('Exception during post install access management: ' + e);
    }
  }

  @future(callout=true)
  global static void RegisterWithBusinessOrg(String userId) {
    User u = [Select Id, Username, Email from User where Id =:userId];
    String[] toAddresses = new String[]{ u.Email };
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toAddresses);
    mail.setSubject('Package install information');

    String message = 'Registration information ... ';
    try {
        // Use the RegisterOrgHelper, and the information in protected custom metadata to register with the business org
        ConnectionInfo__mdt connectionInfo = [SELECT DeveloperName, fays_de1_0920__Package_Client_Id__c FROM fays_de1_0920__ConnectionInfo__mdt WHERE DeveloperName='PE_Example_Business_Org'];
        message += 'ConnectionInfo = ' + connectionInfo;
        
        RegisterOrgHelper helper = new RegisterOrgHelper();
        String result = helper.registerWithBusinessOrg(u.Username, connectionInfo.fays_de1_0920__Package_Client_Id__c);
        message += '. Registration call result = ' + result;
    } catch(Exception e) {
        System.debug('Exception during post install org registration: ' + e);
        message += '. Exception = ' + e;
    }
    mail.setPlainTextBody(message);
    Messaging.sendEmail(new Messaging.Email[] { mail });
  }

}
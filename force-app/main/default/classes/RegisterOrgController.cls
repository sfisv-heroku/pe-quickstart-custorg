/*
 * Copyright (c) 2018, Salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root
 */

public with sharing class RegisterOrgController
{

  public String custClientId { get; set; }
  public String custUsername;
  private RegisterOrgHelper helper;

  public RegisterOrgController() {

    this.helper = new RegisterOrgHelper();
    this.custUsername = UserInfo.getUserName();

  }

  public String getCustUsername() { return custUsername; }

  public void setCustUsername(String name) {
    this.custUsername = (name == null) ? UserInfo.getUserName() : name;
  } 

  public PageReference registerOrg() {

    // Use helper to register with the business org
    System.debug('In registerOrg method. custUsername = ' + custUsername + ', custClientId = ' + custClientId + ', helper = ' + helper);
    try {
        // Call to isv business org to register this one
        String result = helper.registerWithBusinessOrg(custUsername, custClientId);
        if (result == '201') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Success!  Your org is registered.'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed with status: ' + result));
        }
    } catch(Exception e) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed with exception: ' + e));
    }
    
    return null;
  }

}
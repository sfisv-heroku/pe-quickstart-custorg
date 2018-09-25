@isTest
public class RegisterOrgHelperTest {

    static testMethod void runPositiveTestCases() {

        // Get business org credentials from the custom metadata
        ConnectionInfo__mdt connectionInfo = [SELECT URL__c, Username__c, Password__c, Client_Id__c, Client_Secret__c, QualifiedApiName FROM ConnectionInfo__mdt WHERE DeveloperName='PE_Example_Business_Org'];
        String bizOrgUrl = connectionInfo.URL__c;

        // Prepare variables for use by helper
        String custUsername = UserInfo.getUserName();
        String custOrgId = UserInfo.getOrganizationId();
        String base = URL.getSalesforceBaseUrl().toExternalForm().replace('c.na','na').replace('c.cs','cs');
        String custOrgUrl = (base.contains('--')) ? base.replace('visual.','my.sales').replace('--','.') : base.replace('visual.','sales');

        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockLoginResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        Test.StartTest(); 

        // Instantiate a new helper, in this case, no parameters required
        RegisterOrgHelper helper = new RegisterOrgHelper();
        System.assert(!helper.isInitialized());

        // Verify the intialization process
        helper.initializeAndLogin();
        System.assert(helper.isInitialized());

        // Mock a login to Business org and verify mock response
        RegisterOrgHelper.AuthInput input = new RegisterOrgHelper.AuthInput(connectionInfo);  
        String token = helper.loginToBusinessOrg(input);
        System.assertNotEquals(null, token, 'The login callout returned a null token.');

        helper.initializeAndLogin('https://na53.salesforce.com', input);
        System.assert(helper.isInitialized());
        
        // Create wrapper
        String clientId = '3MVG9PE4xB9wtoY_d6OQ8ddwwB_9KRTXMBg.FFvYgyOaDPJTcp3692oYxFHM0WUM8BdwPcrxc2rFZSqA69nzP';
        RegisterOrgHelper.CustomerOrgInfoWrapper custOrgInfo = new RegisterOrgHelper.CustomerOrgInfoWrapper(custOrgUrl, custUsername, custOrgId, clientId, '');
        System.debug('Org information: ' + JSON.serialize(custOrgInfo));

        // Mock the call to register and verify that there is a value returned
        mock.setStaticResource('MockRegisterOrgResponse');
        String response = helper.registerWithBusinessOrg(bizOrgUrl, token, custOrgId, custOrgInfo);
        System.assertNotEquals(null, response, 'The register callout returned a null response.');

        // Moch additional register methods
        response = helper.registerWithBusinessOrg(custUsername, 'XXXXXXXXXX');
        System.assertNotEquals(null, response, 'The register callout returned a null response.');

        Test.StopTest(); 
    }

static testMethod void runNegativeTestCases() {

        // Get business org credentials from the custom metadata
        ConnectionInfo__mdt connectionInfo = [SELECT URL__c, Username__c, Password__c, Client_Id__c, Client_Secret__c, QualifiedApiName FROM ConnectionInfo__mdt WHERE DeveloperName='PE_Example_Business_Org'];
        String bizOrgUrl = connectionInfo.URL__c;

        // Prepare variables for use by helper
        String custUsername = UserInfo.getUserName();
        String custOrgId = UserInfo.getOrganizationId();
        String base = URL.getSalesforceBaseUrl().toExternalForm().replace('c.na','na').replace('c.cs','cs');
        String custOrgUrl = (base.contains('--')) ? base.replace('visual.','my.sales').replace('--','.') : base.replace('visual.','sales');

        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockLoginResponse');
        mock.setStatusCode(501);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        Test.StartTest(); 

        // Instantiate a new helper, in this case, no parameters required
        RegisterOrgHelper helper = new RegisterOrgHelper();
        System.assert(!helper.isInitialized());

        // Verify the intialization process
        helper.initializeVariables();
        System.assert(helper.isInitialized());

        // Create AuthInput, using the connectionInfo
        RegisterOrgHelper.AuthInput input = new RegisterOrgHelper.AuthInput(connectionInfo);  

        // Verify the failed login process
        Boolean failedLogin = false;
        String token = helper.loginToBusinessOrg(input);
        System.assert(String.isEmpty(token));

        Test.StopTest(); 
    }
}
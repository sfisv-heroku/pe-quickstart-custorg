/*
 * Copyright (c) 2018, Salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root
 */
 
public with sharing class RegisterOrgHelper
{

    private String custOrgId;
    private String custOrgUrl;
    private String bizOrgUrl;
    private String token;
    private String namespace;
    private String packageClientId;

    public void RegisterOrgHelper() {

    }
    
    public class CustomerOrgInfoWrapper {
        String usernameField {get;set;}
        String connectionInfoField {get;set;}
    
        public CustomerOrgInfoWrapper (String url, String un, String org, String client, String ns) {
            this.usernameField = un;

            ConnectionInfoWrapper connInfo = new ConnectionInfoWrapper(url, un, org, client, ns);
            String connInfoString = JSON.serialize(connInfo);
            connInfoString = connInfoString.replace('"', '\'');
            this.connectionInfoField = connInfoString;
        }
    }

    public class ConnectionInfoWrapper {
        String instance_url {get;set;}
        String username {get;set;}
        String orgId {get;set;}
        String clientId {get;set;}
        String environment {get;set;}
        String redirectUri {get;set;}
        String namespace_prefix {get;set;}
    
        public ConnectionInfoWrapper (String url, String un, String org, String client, String ns) {
            this.instance_url = url;
            this.username = un;
            this.orgId = org.substring(0, 15);
            this.clientId = client;
            this.redirectUri = 'https://login.salesforce.com/services/oauth2/callback';
            this.namespace_prefix = ns;

            // Use the url to determine if the org is test or production environment
            this.environment = url.contains('.cs') ? 'sandbox' : 'production';
            System.debug('Environment type: ' + environment);
        }
    }

    public class AuthInput {
        String username {get;set;}
        String password {get;set;}
        String clientId {get;set;}
        String clientSecret {get;set;}
    
        public AuthInput (ConnectionInfo__mdt connectionInfo) {
            this.username = connectionInfo.Username__c;
            this.password = connectionInfo.Password__c;
            this.clientId = connectionInfo.Client_Id__c;
            this.clientSecret = connectionInfo.Client_Secret__c;
        }

        public AuthInput (String un, String pw, String client, String secret) {
            this.username = un;
            this.password = pw;
            this.clientId = client;
            this.clientSecret = secret;
        }
    }
    
    public class AuthResponse {
       public String id;
       public String access_token;
    }

    public String loginToBusinessOrg(AuthInput input) {
       String token = '';
       String authReqBody = 'grant_type=password&client_id='+input.clientId+'&client_secret='+input.clientSecret+'&username='+input.username+'&password='+input.password;

       Http h = new Http();
       HttpRequest req = new HttpRequest();
       //req.setHeader('Content-Type','application/x-www-form-urlencoded');
       req.setBody(authReqBody);

       req.setMethod('POST');
       req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
       HttpResponse authRes = h.send(req);

       if (authRes.getStatusCode() == 200) {
            AuthResponse auth = (AuthResponse)JSON.deserialize(authRes.getbody(),AuthResponse.class);
            token = (String)auth.access_token;
            System.debug('Login response: '+ authRes.getbody());
            System.debug('Access token: '+ token);
       } else {
            System.debug('ERROR.  Status code returned: '+ authRes.getStatusCode());
       }

       return token;
    }

    public String registerWithBusinessOrg(String custUsername, String custClientIdOrNull) {
        if (!isInitialized()) {
            initializeAndLogin(); 
        }

        String custClientId = String.isEmpty(custClientIdOrNull) ? this.packageClientId : custClientIdOrNull;

        CustomerOrgInfoWrapper custOrgInfo = new CustomerOrgInfoWrapper(custOrgUrl, custUsername, custOrgId, custClientId, namespace);
        System.debug('Org information: ' + JSON.serialize(custOrgInfo));

        String result = registerWithBusinessOrg(bizOrgUrl, token, custOrgId, custOrgInfo);
        return result;
    }

    public String registerWithBusinessOrg(String baseUrl, String token, String orgId, CustomerOrgInfoWrapper orgInfo) {
       Http h = new Http();
       HttpRequest req = new HttpRequest();
       //req.setHeader('Content-Type','application/x-www-form-urlencoded');
       String body = JSON.serialize(orgInfo);
       body = body.replace('usernameField', 'Username__c').replace('connectionInfoField', 'ConnectionInfo__c');
       System.debug('Post body: ' + body); 
       req.setBody(body);

       req.setEndpoint(baseUrl + '/services/data/v43.0/sobjects/Customer_Org_Info__c/Org_Id__c/' + orgId.substring(0, 15) + '?_HttpMethod=PATCH');  
       req.setMethod('POST');
       req.setHeader('Content-Type','application/json');
       req.setHeader('Authorization','Bearer ' + token);            

       HttpResponse res = h.send(req);               
       System.debug('Post response statusCode: ' + res.getStatusCode() + ' and body: ' + res.getBody()); 

       return String.valueOf(res.getStatusCode());
    }

    public Boolean isInitialized() {
        return (this.custOrgId != null && this.custOrgUrl != null);
    }

    public void initializeAndLogin() {
        initializeVariables();

        // Create AuthInput from connectionInfo
        AuthInput input = initializeConnectionInfo();  

        // Login to business org to get token for future use
        this.token = loginToBusinessOrg(input);
    }

    public void initializeAndLogin(String orgUrl, AuthInput input) {
        // Initialize
        this.bizOrgUrl = orgUrl;
        initializeVariables();

        // Login to business org to get token for future use
        this.token = loginToBusinessOrg(input);
    }

    public void initializeVariables() {

        Boolean isSandbox;
        String instance;
        String pageUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('Page Url = ' + pageUrl);

        // Get information from the Organization record
        try {
            Organization org = [SELECT Id, InstanceName, IsSandbox FROM Organization LIMIT 1];
            this.custOrgId = org.Id;
            instance = org.InstanceName.toLowerCase();
            isSandbox = org.IsSandbox;
        } catch (Exception e) {
            System.debug('No Organixation record found.');
            this.custOrgId = UserInfo.getOrganizationId();
            instance = (URL.getSalesforceBaseUrl().getHost()).toLowerCase();
            isSandbox = instance.contains('cs');
        }

        this.custOrgUrl = getInstanceUrl(pageUrl, instance, isSandbox);
    }

    public AuthInput initializeConnectionInfo() {

        // Get business org credentials and package ClientId from the custom metadata
        ConnectionInfo__mdt connectionInfo = [SELECT URL__c, Username__c, Password__c, Client_Id__c, Client_Secret__c, Package_Client_Id__c, NamespacePrefix, DeveloperName FROM ConnectionInfo__mdt WHERE DeveloperName='PE_Example_Business_Org'];
        this.bizOrgUrl = connectionInfo.URL__c;
        this.namespace = connectionInfo.NamespacePrefix;
        this.packageClientId = connectionInfo.Package_Client_Id__c;

        // Create AuthInput, using the connectionInfo
        AuthInput input = new AuthInput(connectionInfo);

        return input;
    }

    private String getInstanceUrl(String originalUrl, String instance, Boolean isSandbox) {
        
        String instanceUrl;
        Boolean baseCase = false;

        if (originalUrl.contains('visual')) {
            instanceUrl = 'https://';
            String coreUrl = originalUrl.split('visual')[0].split('://')[1];

            if (coreUrl.left(2) == 'c.') {
                // No domain or namespace
                // instanceUrl += instance + '.salesforce.com';
                baseCase = true;
            } else {
                if (coreUrl.contains('--')) {
                    // Domain
                    String[] pieces = coreUrl.split('--');
                    instanceUrl += pieces[0];
                    if (pieces.size() > 2) { instanceUrl += '--' + pieces[1]; }
                    if (isSandbox) { instanceUrl += '.' + instance; }
                    instanceUrl += '.my.salesforce.com';
                } else {
                    // Namespace, but no domain
                    // instanceUrl += instance + '.salesforce.com';
                    baseCase = true;
                }
            }
        } else {
            if (originalUrl.contains('-') || originalUrl.contains('my')) {
                instanceUrl = originalUrl;
            } else {
                baseCase = true;
            }
        }
        
        if (baseCase) {
            instanceUrl = isSandbox ? 'https://test.salesforce.com' : 'https://login.salesforce.com';
        }

        System.debug('Instance Url = ' + instanceUrl + ' generated from originalUrl = ' + originalUrl + ', instance = ' + instance + ', isSandbox = ' + isSandbox);
        return instanceUrl;
    }
}
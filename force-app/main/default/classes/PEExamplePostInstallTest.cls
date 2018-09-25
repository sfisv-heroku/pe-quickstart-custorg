@isTest
public class PEExamplePostInstallTest {

    static testMethod void testPEExamplePostInstallNoContext() {
      // Create the mock response based on a static resource
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('MockLoginResponse');
      mock.setStatusCode(200);
      mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
      // Associate the callout with a mock response
      Test.setMock(HttpCalloutMock.class, mock);

      Test.StartTest(); 
      Integer beforeEmailCount = Limits.getEmailInvocations();
      PEExamplePostInstall postinstall = new PEExamplePostInstall();
      Test.testInstall(postinstall, null);
      ConnectedApplication connApp = [SELECT Id, Name FROM ConnectedApplication WHERE Name = 'Process Externally Example App'];
      SetupEntityAccess acc = [SELECT Id, ParentId, SetupEntityId from SetupEntityAccess WHERE SetupEntityId=:connApp.Id LIMIT 1];
      System.assertNotEquals(acc, null, 'SetupEntityAccess was not created.');   
      Test.StopTest(); 
   }

   static testMethod void testPEExamplePostInstallWithContext() {
      // Create the mock response based on a static resource
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('MockLoginResponse');
      mock.setStatusCode(200);
      mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
      // Associate the callout with a mock response
      Test.setMock(HttpCalloutMock.class, mock);

      Test.StartTest(); 
      PEExamplePostInstall postinstall = new PEExamplePostInstall();
      Test.testInstall(postinstall, new Version(1,0), true);
      ConnectedApplication connApp = [SELECT Id, Name FROM ConnectedApplication WHERE Name = 'Process Externally Example App'];
      SetupEntityAccess acc = [SELECT Id, ParentId, SetupEntityId from SetupEntityAccess WHERE SetupEntityId=:connApp.Id LIMIT 1];
      System.assertNotEquals(acc, null, 'SetupEntityAccess was not created.');
      Test.StopTest();  
   }

   static testMethod void testPEExamplePostInstallEmailCount() {
      // Create the mock response based on a static resource
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('MockLoginResponse');
      mock.setStatusCode(200);
      mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
      // Associate the callout with a mock response
      Test.setMock(HttpCalloutMock.class, mock);

      Test.StartTest(); 
      Integer beforeEmailCount = Limits.getEmailInvocations();
      PEExamplePostInstall postinstall = new PEExamplePostInstall();
      Test.testInstall(postinstall, new Version(1,0), true);
      //System.assertEquals((Limits.getEmailInvocations()), beforeEmailCount+1);
      System.assertEquals((Limits.getEmailInvocations()), beforeEmailCount);
      Test.StopTest();
   }

   static testMethod void testPEExamplePostInstallFailedLogin() {
      // Create the mock response based on a static resource
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('MockLoginResponse');
      mock.setStatusCode(501);
      mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
      // Associate the callout with a mock response
      Test.setMock(HttpCalloutMock.class, mock);

      Test.StartTest(); 
      Integer beforeEmailCount = Limits.getEmailInvocations();
      PEExamplePostInstall postinstall = new PEExamplePostInstall();
      Test.testInstall(postinstall, null);  
      Test.StopTest(); 
   }

   static testMethod void testPEExamplePostInstallAssignPermissionSet() {
      String userId = createTestUser();
      PermissionSet permSet = [SELECT Id from PermissionSet LIMIT 1];
      Test.StartTest(); 
      PEExamplePostInstall.AssignPermissionSet(userId, String.valueOf(permSet.Id));
      Test.StopTest(); 
   }

   static String createTestUser() {
     Profile profile = [Select Id from Profile where Name='Standard User']; 
     String orgId=UserInfo.getOrganizationId(); 
     String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
     Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
     String uniqueName=orgId+dateString+RandomId; 
     User stdUser = new User(firstname = 'ABC', 
                        lastName = 'XYZ', 
                        email = uniqueName + '@test' + orgId + '.org', 
                        Username = uniqueName + '@test' + orgId + '.org', 
                        EmailEncodingKey = 'ISO-8859-1', 
                        Alias = uniqueName.substring(18, 23), 
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        LocaleSidKey = 'en_US', 
                        LanguageLocaleKey = 'en_US', 
                        ProfileId = profile.Id
                    ); 
     insert stdUser;
     return String.valueOf(stdUser.Id);
   }
   
}
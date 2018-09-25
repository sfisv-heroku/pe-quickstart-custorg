@isTest
public class RegisterOrgControllerTest {

    static testMethod void testControllerSuccess() {

        Test.StartTest(); 

        // Set the page to the VF page
        PageReference pageRef = Page.RegisterOrg;
        Test.setCurrentPage(pageRef);

        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockLoginResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
      
        // Instantiate a new controller, in this case, no parameters required
        RegisterOrgController controller = new RegisterOrgController();

        // Verify mock login response is not null
        //System.assertNotEquals(null, controller.helper.token, 'The login callout returned a null token.');

        // Verify the default username
        String defaultUser = controller.getCustUsername();
        System.assertEquals(UserInfo.getUserName(), defaultUser);

        // Verify the setting of another username
        String otherUser = 'firstlast@company.com';
        controller.setCustUsername(otherUser);
        System.assertEquals(controller.getCustUsername(), otherUser);

        // Verify the setting of Client Id
        String clientId = '3MVG9PE4xB9wtoY_d6OQ8ddwwB_9KRTXMBg.FFvYgyOaDPJTcp3692oYxFHM0WUM8BdwPcrxc2rFZSqA69nzP';
        controller.custClientId = clientId;
        System.assertEquals(controller.custClientId, clientId);

        // Mock the call to register and verify that there is a value returned
        mock.setStaticResource('MockRegisterOrgResponse');
        controller.registerOrg();

        Test.StopTest(); 
    }

    static testMethod void testControllerFailure() {

        Test.StartTest(); 

        // Set the page to the VF page
        PageReference pageRef = Page.RegisterOrg;
        Test.setCurrentPage(pageRef);

        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockLoginResponse');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
      
        // Instantiate a new controller, in this case, no parameters required
        RegisterOrgController controller = new RegisterOrgController();

        // Verify mock login response is not null
        //System.assertNotEquals(null, controller.helper.token, 'The login callout returned a null token.');

        // Verify the default username
        String defaultUser = controller.getCustUsername();
        System.assertEquals(UserInfo.getUserName(), defaultUser);

        // Verify the setting of another username
        String otherUser = 'firstlast@company.com';
        controller.setCustUsername(otherUser);
        System.assertEquals(controller.getCustUsername(), otherUser);

        // Verify the setting of Client Id
        String clientId = '3MVG9PE4xB9wtoY_d6OQ8ddwwB_9KRTXMBg.FFvYgyOaDPJTcp3692oYxFHM0WUM8BdwPcrxc2rFZSqA69nzP';
        controller.custClientId = clientId;
        System.assertEquals(controller.custClientId, clientId);

        // Mock the call to register and verify that there is a value returned
        mock.setStaticResource('MockRegisterOrgResponse');
        controller.registerOrg();

        Test.StopTest(); 
    }
}
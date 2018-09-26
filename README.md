# Heroku + Platform Events Quick Start for Salesforce ISV's
# Customer Org Component

This example is to demonstrate and serve as a quick start for how large-scale processing can be moved from Salesforce to Heroku.  It consists of four components, each with its own git repository:

1. [Business org](https://github.com/sfisv-heroku/pe-quickstart-bizorg): A Salesforce application that keeps track of the activity happening in the Customer org and on Heroku
1. [Customer org](https://github.com/sfisv-heroku/pe-quickstart-custorg) (this project): A Salesforce application that generates Platform Events
1. [Listener](https://github.com/sfisv-heroku/pe-quickstart-listener): A Heroku application that consumes events and dispatches them to the worker
1. [Worker](https://github.com/sfisv-heroku/pe-quickstart-worker): A Heroku application that receives work from the listener and performs processing on data retrieved from the Customer org

This is an experimental project, which means that:

1. It's work in progress
1. We need your feedback
1. Code contributions are welcome

For more information, please go to the Salesforce Partner Community and view the ["Heroku for ISV's - Quick Start" Chatter Group](https://sfdc.co/herokuisvquickstart "https://sfdc.co/herokuisvquickstart")

## Table of Contents

*   Installation
    *   [Installing Heroku Platform Events Quick Start Customer Org using Salesforce DX](#installing-heroku-pe-quickstart-custorg-using-salesforce-dx)
    *   [Installing Heroku Platform Events Quick Start Customer Org using an unlocked package](#installing-pe-quickstart-custorg-using-an-unlocked-package)

## Installation

There are two ways to install the Heroku Platform Events Quick Start Customer Org component:

*   Using Salesforce DX
*   Using an unlocked package

### Installing Heroku Platform Events Quick Start Customer Org using Salesforce DX

This is the recommended installation option for developers who want to experience the app and the code.

1.  Authenticate with your SFDX hub org (if not already done):

    ```
    sfdx force:auth:web:login -d -a myhuborg
    ```

1.  Clone this repository:

    ```
    git clone https://github.com/sfisv-heroku/pe-quickstart-custorg
    cd pe-quickstart-custorg
    ```

1.  Modify the .env file to enter your business org credentials

1.  Create a scratch org, push the app, and open the org:

    ```
    ./scripts/orgInit.sh
    ```

1.  Change the access policy to permit access to the Connected App

    1. Select **Heroku PE Example App** in the App list and click "Edit"

    2. Change the "Permitted Users" setting to "Admin approved users are pre-authorized" and click Save.

1. Set the Welcome Lightning Page to be the default home page
    
    1. Go to Lightning App Builder from Setup and click Edit on the Welcome page
    
    2. Click on Activate, select the Profiles to set it for (or all), and click Save

1.  Register the newly created Customer Org with it's ClientId

    1. Go to App Manager, Select **Heroku PE Example App** in the App list and click "View".

    2. Copy the Consumer Key field and either:

        1. Use script to register
        ```
        ./scripts/registerOrg.sh <clientId>
        ```
        2. Use Visualforce page to register

        Click **Home** to get to the Welcome page and scroll down to get to the Register section, andter the ClientId and click "Register

1. Begin generating events

    Click **Home** to get to the Welcome page and click **Create Events" button to begin generating events (Optional: Change the # of events first)

1.  Modify the protected custom metadata (optional, but required for package installation)
    ```
    ./scripts/setCustomMetadata.sh <clientId>
    ```

### Installing Heroku Platform Events Quick Start Customer Org using an unlocked package

This is the recommended option for non developers. Use this option if you want to experience the sample app but do not plan to modify the code.

1.  [Sign up](https://developer.salesforce.com/signup) for a developer edition.

1.  Enable My Domain. Follow the instructions to enable My Domain [here](https://trailhead.salesforce.com/projects/quickstart-lightning-components/steps/quickstart-lightning-components1).

1.  Click [this link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0b000001qKFZ) to install the Platform Events Example App unlocked package into your developer edition org.

1.  Select **Install for All Users**. When prompted, make sure you grant access to the external sites (api.einstein.ai).

1.  Select **Platform Events Example** in the App Launcher.

1.  Click the **Create Events** tab and click the button to begin generating events.

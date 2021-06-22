# technical-test
technical test 

## Task 1:
    Custom object: 
    - Account.Total_Contacts__c
    - Contact.Active__c
    Approval process: 
    - Create_Contact_Approval_Process: update active field for contact after approval.
    Apex Trigger:
    - ContactApprovalProcessTrigger: (after insert) automatcally trigger an approval process to approve the contact
    - TriggerComputeTotalContacts: (after update, after delete) update Total Contacts after add contact to account/delete contact.
    
## Task 2, 3:
    Custom object:
    - Account.Counter__c
    - Contact.Counter__c 
    Visualforce page:
    - AccountContactPage
    Apex class:
    - AccountContactController: controller of AccountContactPage

## Task 4:
    Apex class:
    - ContactService: include a httpGet function to get test data and a httpPatch function to update contacts.

    Test information
    url: https://skedulo26-dev-ed.my.salesforce.com/services/apexrest/contact
    method: Patch
    details: import the collection "Api test.postman_collection.json" into Postman to use


@RestResource(urlMapping='/contact/*')
global with sharing class ContactService {
    
    // this function only to get data for testing
    @HttpGet
    Global static void getContact(){
        List<Contact> cnts = [select id, lastname, counter__c from contact where name like '%test%'];
        RestResponse response = RestContext.response;
        response.responseBody = Blob.valueOf(JSON.serialize(cnts));
    }
    
    @HttpPatch
    global static void updateContacts() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        string reqBody = request.RequestBody.ToString();
        
        List<Contact> conts = new List<Contact>();
        
        // return an error if request body is blank
        if(String.isBlank(reqBody)){
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new serviceResponse(false,'Request body cannot be null','ERR001')));
            return;
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            conts = (List<Contact>)JSON.Deserialize(reqBody,List<Contact>.class);
            for(Contact cont : conts){
                
                // Validation Id field
                if (String.isBlank(cont.Id)){
                    response.statusCode = 400;
                    response.responseBody = Blob.valueOf(JSON.serialize(new serviceResponse(false,'Id is required for updating records:','ERR002')));
                    return;
                }
                
                // Validation other fields
                Map<String, Object> fieldsToValue = cont.getPopulatedFieldsAsMap();
                for (String fieldName : fieldsToValue.keySet()){
                    if(fieldName == 'LastName' && String.isBlank(cont.LastName)){
                        response.statusCode = 400;
                        response.responseBody = Blob.valueOf(JSON.serialize(new serviceResponse(false,'LastName is required:' + cont.Id,'ERR003')));
                        return;
                    }
                    if(fieldName == 'Counter__c' && cont.Counter__c == null){
                        response.statusCode = 400;
                        response.responseBody = Blob.valueOf(JSON.serialize(new serviceResponse(false,'Counter__c must be a Number:' + cont.Id,'ERR004')));
                        return;
                    }
                }
            }
            
            List<Database.SaveResult> srList = Database.update(conts, false);
            
            serviceResponse rbody = new serviceResponse(true,'success','');
            rbody.data = srList;
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(rbody));
            
        } catch(Exception e) {
            // rollback if an unhandled issue occurs
            Database.rollback(sp);
            response.statusCode = 500;
            response.responseBody = Blob.valueOf(JSON.serialize(new serviceResponse(false,'Exception: ' + e.getStackTraceString(),'ERR005')));
        }
        
    }
    
    class serviceResponse {
        public boolean success {get; set;}
        public String message {get;set;}
        public String errorCode {get;set;}
        public List<Database.SaveResult> data {get;set;}
        public serviceResponse(){}
        public serviceResponse (boolean s, String m, String e){
            success = s;
            message = m;
            errorCode = e;
        }
    }
}
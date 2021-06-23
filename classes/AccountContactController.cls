public with sharing class AccountContactController {

    public String searchString {get; set;}
    public String message {get;set;}
    
    // provide data for table
    public List<TableRecord> getRecords(){
        List<TableRecord> records = new List<TableRecord>();
        if(String.isBlank(searchString))
            return null;
        List<TableRecord> accRecords = queryObject('Account', searchString);
        records.addAll(accRecords);
        List<TableRecord> cntRecords = queryObject('Contact', searchString);
        records.addAll(cntRecords);
        return records;
    }
    
    private List<TableRecord> queryObject(String sObjectName, String searchKey){
        searchKey = searchKey + '%';
        string queryString = 'Select Id, Name, Counter__c From ' + sObjectName + ' Where Name like :searchKey';
        List<sObject> sObjectList = Database.query(queryString);

        List<TableRecord> recordList = new List<TableRecord>();
        for(sObject sobj : sObjectList){
            TableRecord tr = new TableRecord();
            tr.recordId = (Id)sobj.get('Id');
            tr.name = (String) sobj.get('Name');
            tr.recordType = tr.recordId.getsobjecttype().getDescribe().getName();
            tr.counter = (Decimal) sobj.get('Counter__c') == null ? 0 : (Decimal) sobj.get('Counter__c');
            recordList.add(tr);
        }
        return recordList;
    }
    
    @RemoteAction
    public static Database.SaveResult addCounter(String recordId, String objectName){
        recordId = String.isBlank(recordId) ? '' : recordId;
        String query = 'Select id, Counter__c from ' + objectName + ' where Id = :recordId';
        List<sObject> records = Database.query(query);
        if(records.size() > 0){
            sObject obj = records.get(0);
            Decimal count = (Decimal) obj.get('Counter__c') == null ? 0 : (Decimal) obj.get('Counter__c');
            obj.put('Counter__c', count + 1);
            Database.SaveResult sr = Database.update(obj);
            return sr;
        }
        return null;
    }
    
    private class TableRecord {
        public Id recordId {get; set;}
        public String name {get; set;}
        public String recordType {get; set;}
        public decimal counter {get; set;}
        public TableRecord(){}
        public TableRecord (Id rId, String rName, String rType, decimal count){
            recordId = rId;
            name = rName;
            recordType = rType;
            counter = count != null ? count : 0;
        }
    }
}
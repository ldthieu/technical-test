trigger TriggerComputeTotalContacts on Contact (after update, after delete) {
    
    map<Id, Integer> accMap = new map<Id, Integer>();
    // compute Total Contacts of account when update record.
    if (Trigger.isUpdate){
        for(Id contactId : Trigger.newMap.keySet()){
            Contact cntNew = Trigger.newMap.get(contactId);
            Contact cntOld = Trigger.oldMap.get(contactId);
            // count +1 if active a contact
            if(cntNew.Active__c && !cntOld.Active__c && cntNew.AccountId != null){
                if (accMap.get(cntNew.AccountId) == null){
                    accMap.put(cntNew.AccountId, 1);
                } else {
                    accMap.put(cntNew.AccountId, accMap.get(cntNew.AccountId) + 1);
                }
            }
            
            // count -1 if deactive a contact
            if(!cntNew.Active__c && cntOld.Active__c && cntOld.AccountId != null){
                if (accMap.get(cntOld.AccountId) == null){
                    accMap.put(cntOld.AccountId, -1);
                } else {
                    accMap.put(cntOld.AccountId, accMap.get(cntOld.AccountId) - 1);
                }
            }
            
            // the case change AccountId
            if(cntNew.Active__c && cntOld.Active__c && cntOld.AccountId != cntNew.AccountId){
                if (cntOld.AccountId != null){
                    if (accMap.get(cntOld.AccountId) == null){
                        accMap.put(cntOld.AccountId, -1);
                    } else {
                        accMap.put(cntOld.AccountId, accMap.get(cntOld.AccountId) - 1);
                    } 
                }
                if(cntNew.AccountId != null){
                    if (accMap.get(cntNew.AccountId) == null){
                        accMap.put(cntNew.AccountId, 1);
                    } else {
                        accMap.put(cntNew.AccountId, accMap.get(cntNew.AccountId) + 1);
                    }
                }
            }
        }
        
    // decrease Total Contacts when delete an active contact
    } else if (Trigger.isDelete){
        for(Contact cnt : Trigger.old){
            if(cnt.AccountId != null && cnt.Active__c){
                if (accMap.get(cnt.AccountId) == null){
                    accMap.put(cnt.AccountId, -1);
                } else {
                    accMap.put(cnt.AccountId, accMap.get(cnt.AccountId) - 1);
                }
            }
        }
    }
    
    // update Total Contacts of accounts
    if(accMap.size() > 0){
        List<Account> accUpdateList = [Select Id, Total_Contacts__c From Account where Id in :accMap.keySet()];
        if(accUpdateList.size() > 0){
            for (Account acc: accUpdateList) {
                acc.Total_Contacts__c = acc.Total_Contacts__c + accMap.get(acc.Id) > 0 ? acc.Total_Contacts__c + accMap.get(acc.Id) : 0;
            }
            update accUpdateList;
        }
    }
}
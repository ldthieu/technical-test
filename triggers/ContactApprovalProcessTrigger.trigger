trigger ContactApprovalProcessTrigger on Contact (after insert) {

    List<Contact> cntUpdateList = new List<Contact>();
    Map<Id, Integer> accUpdateMap = new Map<Id, Integer>();
    
    // Auto trigger the approval process
    
    List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
    for(Id contactId : Trigger.newMap.keySet()){
        Contact cntNew = Trigger.newMap.get(contactId);
        //Contact cntOld = Trigger.newMap.get(contactId);
        
        if(Trigger.isInsert){
            if(cntNew.AccountId != null){
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Contact submitted for approval');
                approvalRequest.setObjectId(contactId);
                approvalRequests.add(approvalRequest);
            }
        } 
        // the case we need to trigger approval process when update:
        /*if (Trigger.isUpdate){
            if(cntNew.AccountId != null && cntOld.AccountId != cntNew.AccountId){
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Contact submitted for approval');
                approvalRequest.setObjectId(contactId);
                approvalRequests.add(approvalRequest);
            }
        }*/
    }
    
    if(approvalRequests.size() > 0){
        List<Approval.ProcessResult> approvalResults = Approval.process(approvalRequests);
    }

}
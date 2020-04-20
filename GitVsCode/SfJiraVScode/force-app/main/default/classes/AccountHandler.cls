public class AccountHandler implements ITrigger{
    List<String> AccountIds = new List<String>();
    Map<String,List<String>> AccountIdToJiraIds = new  Map<String,List<String>>();  
    List<GnrSf__JiraIssue__c> jiraissuetoupdate = new List<GnrSf__JiraIssue__c>();
    
    public void bulkBefore()
    {
        
    }
    
    public void bulkAfter()
    {
        if(trigger.isupdate){
            for(Account ac:(List<Account>)trigger.new){
                Account oldac = (Account)Trigger.oldMap.get(ac.Id);
                String OldStatus = oldac.Status__c;
                String NewStatus = ac.Status__c;
                if(NewStatus!=OldStatus){
                    AccountIds.add(ac.Id);
                }
                System.debug('aa'+AccountIds);
            }
            if(!AccountIds.isEmpty()){
                for(GnrSf__JiraRelationship__c jr:[SELECT Id,  GnrSf__CaseRelation__r.AccountId, GnrSf__JiraIssue__c  FROM GnrSf__JiraRelationship__c WHERE GnrSf__CaseRelation__r.AccountId IN :AccountIds]){
                    if(!AccountIdToJiraIds.containsKey(jr.GnrSf__CaseRelation__r.AccountId)){
                        AccountIdToJiraIds.put(jr.GnrSf__CaseRelation__r.AccountId, new List<String>{jr.GnrSf__JiraIssue__c});
                    }else{
                        AccountIdToJiraIds.get(jr.GnrSf__CaseRelation__r.AccountId).add(jr.GnrSf__JiraIssue__c);
                    }
                }
                System.debug('aa'+AccountIdToJiraIds);
                
            }
        }
    }
    public void afterInsert(SObject so)
    {
        
    }
    public void afterUpdate(SObject so, SObject oldSo)
    {
        Account ac = (Account) so;
        Account oldac = (Account) oldso;
        List<String> JiraIds = new List<String>();
        System.debug('aa'+ac.status__c+''+oldac.Status__c);
        
        if(ac.status__c!='Active' && oldac.Status__c=='Active' && AccountIdToJiraIds.containsKey(ac.Id) ){
            JiraIds=AccountIdToJiraIds.get(ac.id);
            for(String jid:JiraIds){
                GnrSf__JiraIssue__c ji = new GnrSf__JiraIssue__c (Id=jid);
                ji.GnrSf__summary__c  ='true';
                jiraissuetoupdate.add(ji);
            }
            System.debug('aa'+jiraissuetoupdate);
            
        }else if(ac.status__c=='Active' && oldac.Status__c!='Active' && AccountIdToJiraIds.containsKey(ac.Id)){
            JiraIds=AccountIdToJiraIds.get(ac.id);
            for(String jid:JiraIds){
                GnrSf__JiraIssue__c ji = new GnrSf__JiraIssue__c (Id=jid);
                ji.GnrSf__summary__c  ='false';
                jiraissuetoupdate.add(ji);
            }
            System.debug('aa'+jiraissuetoupdate);
            
        }else if(ac.status__c!='Active' && oldac.Status__c==null && AccountIdToJiraIds.containsKey(ac.Id)){
            JiraIds=AccountIdToJiraIds.get(ac.id);
            for(String jid:JiraIds){
                GnrSf__JiraIssue__c ji = new GnrSf__JiraIssue__c (Id=jid);
                ji.GnrSf__summary__c  ='true';
                jiraissuetoupdate.add(ji); 
            }
            System.debug('aa'+jiraissuetoupdate);
            
        }
    }
    public void beforeInsert(SObject so)
    {
        
    }
    public void beforeUpdate(SObject oldSo, SObject so)
    {
        
    }
    public void beforeDelete(SObject so)
    {
        
    }
    public void afterDelete(SObject so)
    {
        
    }
    public void andFinally()
    {
        if(!jiraissuetoupdate.isEmpty()){
            Update jiraissuetoupdate;
        }
    }
    
}
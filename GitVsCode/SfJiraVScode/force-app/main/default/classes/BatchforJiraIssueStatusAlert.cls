global class BatchforJiraIssueStatusAlert implements database.Batchable<sObject>{
    
    	DateTime twentyFourHoursAgo = System.now().addhours(-24);
     	private String JiraIssueHistory = 'SELECT Id, ParentId, CreatedDate, Field, OldValue, NewValue FROM GnrSf__JiraIssue__History where Parent.GnrSf__Status__c= \'Waiting For Support\'And CreatedDate >:twentyFourHoursAgo';
    
     global Database.QueryLocator start(Database.BatchableContext BC) {         
      	 return Database.getQueryLocator(JiraIssueHistory);
     }
    
     global void execute(Database.BatchableContext BC,List<sObject> scope) { 
         List<GnrSf__JiraIssue__History> DateofUpdatedStatus= (List<GnrSf__JiraIssue__History>) scope;
         Set<Id> JiraIssueId = new Set<Id>();
         Map<DateTime,GnrSf__JiraIssue__History> JiHistory= new Map<DateTime,GnrSf__JiraIssue__History>();
         List<Case>Caseupdate= new List<Case>();
             
         for(GnrSf__JiraIssue__History getStatusUpdateRecords: DateofUpdatedStatus){                                                  
    		JiHistory.put(getStatusUpdateRecords.CreatedDate,getStatusUpdateRecords);
              JiraIssueId.add(getStatusUpdateRecords.ParentId);                                                                                     
			  }
     
    	for(GnrSf__JiraRelationship__c JiRel:[SELECT Id, GnrSf__CaseRelation__c, GnrSf__JiraIssueId__c, GnrSf__JiraIssue__c
                                          FROM GnrSf__JiraRelationship__c
                                          Where GnrSf__JiraIssue__c = :JiraIssueId and GnrSf__JiraIssue__r.GnrSf__Status__c='Waiting For Support' 
                             			  and GnrSf__CaseRelation__c!=null]){  
                                              
                                              Case cs= new Case(id=JiRel.GnrSf__CaseRelation__c);
                                              Cs.JiraIssue_Id__c = JiRel.GnrSf__JiraIssue__c;
                                              cs.JiraStatusUpdate__c= datetime.valueOf(JiHistory);
                                                  if(cs.JiraStatusUpdate__c >system.now().addhours(-24)){
                                                      cs.Reason_to_send_email__c ='Waiting For Support >24hrs';
                                              }
                                              //cs.Reason_to_send_email__c ='Waiting For Support >24hrs';
            									Caseupdate.add(cs);
                                                                                           
                                          }
             
   			 if(!Caseupdate.isEmpty()){
     			update Caseupdate;
             }													 
 

	}
 	global void finish(Database.BatchableContext BC) {
        
       /* AsyncApexJob a = [SELECT Id,Status,JobType,NumberOfErrors,JobItemsProcessed,TotalJobItems,CompletedDate,ExtendedStatus
          FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        
        List<Case> EmailtocaseOwner= new List<Case>([Select Id, OwnerId, email from case]);
        List <String> toAddresses = new List<String>();
         List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage > ();
        for(Case caseownerlist: EmailtocaseOwner){
            toAddresses.add(caseownerlist.email);
                }
        for(GnrSf__JiraIssue__History mail:DateofUpdatedStatus){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
             email.setToAddresses(toAddresses});
            email.setSubject('Alert: Waiting for support>24');
             email.setPlainTextBody('Dear, Please Check and resolved the issue');
				emails.add(email);
        }
         Messaging.sendEmail(emails);*/



        }
 				
        
}
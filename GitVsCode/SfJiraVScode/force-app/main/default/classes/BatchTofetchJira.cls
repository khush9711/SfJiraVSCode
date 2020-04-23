global with Sharing class BatchTofetchJira implements Database.Batchable<String>,Database.stateful,  Database.AllowsCallouts{
    List<String> JiraKeysSet = new List<String>();
    String fields='';
    String ErrorLog='';
    List<ContentVersion> contList=new List<ContentVersion>();
    public BatchToFetchJira(Set<String> JiraKeySet,String fields){
        JiraKeysSet.addAll(JiraKeySet);
        System.debug('JiraKeysSet---'+JiraKeysSet);
        this.fields=fields;
        System.debug('fields---'+fields);
        
    }
    
    global List<String> start(Database.BatchableContext BC){
        System.debug('JiraKeysSet---'+JiraKeysSet);
        return JiraKeysSet ;
    }
    
    global void execute(Database.BatchableContext BC, List<String> scope){
        String EndPoint = GnrSf__JIRA_Login_Settings__c.getValues('JIRA')!= null? GnrSf__JIRA_Login_Settings__c.getValues('JIRA').GnrSf__End_Point__c!= null ? GnrSf__JIRA_Login_Settings__c.getValues('JIRA').GnrSf__End_Point__c : '' : '';        
        System.debug('EndPoint'+EndPoint);
        List<GnrSf__JiraIssue__c> JiraList=new List<GnrSf__JiraIssue__c>();
        
        for(String ji : scope){
            Boolean Error=false;
            HttpRequest req = new HttpRequest(); 
            Http http = new Http();
            
            HTTPResponse res=new HTTPResponse();
            String jsonInput;
            req = GnrSf.CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+ji+'?fields='+fields,'GET' ,'application/json');
            try{
                if(test.isRunningTest()){
                    JsonInput='{"expand":"renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations","id":"533603","self":"https://agile-staging.8x8.com/rest/api/2/issue/533603","key":"GRAZ-4","fields":{"summary":"Test Case Detail subject","issuetype":{"self":"https://agile-staging.8x8.com/rest/api/2/issuetype/10004","id":"10004","description":"A problem which impairs or prevents the functions of the product.","iconUrl":"https://agile-staging.8x8.com/secure/viewavatar?size=xsmall&avatarId=10303&avatarType=issuetype","name":"Bug","subtask":false,"avatarId":10303},"creator":{"self":"https://agile-staging.8x8.com/rest/api/2/user?username=integrationuser","name":"integrationuser","key":"integrationuser","emailAddress":"no-reply@8x8.com","avatarUrls":{"48x48":"https://www.gravatar.com/avatar/6237fb189ef02cfd47e6941006591b7b?d=mm&s=48","24x24":"https://www.gravatar.com/avatar/6237fb189ef02cfd47e6941006591b7b?d=mm&s=24","16x16":"https://www.gravatar.com/avatar/6237fb189ef02cfd47e6941006591b7b?d=mm&s=16","32x32":"https://www.gravatar.com/avatar/6237fb189ef02cfd47e6941006591b7b?d=mm&s=32"},"displayName":"Integration Common User","active":true,"timeZone":"Universal"},"created":"2019-09-26T09:59:09.848+0000","description":"Testing Jira(Please Ignore)","project":{"self":"https://agile-staging.8x8.com/rest/api/2/project/14900","id":"14900","key":"GRAZ","name":"Grazitti","avatarUrls":{"48x48":"https://agile-staging.8x8.com/secure/projectavatar?avatarId=10324","24x24":"https://agile-staging.8x8.com/secure/projectavatar?size=small&avatarId=10324","16x16":"https://agile-staging.8x8.com/secure/projectavatar?size=xsmall&avatarId=10324","32x32":"https://agile-staging.8x8.com/secure/projectavatar?size=medium&avatarId=10324"}},"reporter":{"self":"https://agile-staging.8x8.com/rest/api/2/user?username=integrationuser","name":"integrationuser","key":"integrationuser","emailAddress":"no-reply@8x8.com","avatarUrls":{"48x48":"https://www.gravatar.com/avatar/6237fb189ef02cfd47e6941006591b7b?d=mm&s=48","24x24":"https://www.gravatar.com/avatar/6237fb189ef02cfd47e6941006591b7b?d=mm&s=24","16x16":"https://www.gravatar.com/avatar/6237fb189ef02cfd47e6941006591b7b?d=mm&s=16","32x32":"https://www.gravatar.com/avatar/6237fb189ef02cfd47e6941006591b7b?d=mm&s=32"},"displayName":"Integration Common User","active":true,"timeZone":"Universal"},"priority":{"self":"https://agile-staging.8x8.com/rest/api/2/priority/5","iconUrl":"https://agile-staging.8x8.com/images/icons/priorities/trivial.svg","name":"Trivial","id":"5"},"resolution":{"self":"https://agile-staging.8x8.com/rest/api/2/resolution/10000","id":"10000","description":"Work has been completed on this issue.","name":"Done"},"resolutiondate":"2019-11-08T06:41:44.397+0000","assignee":null,"status":{"self":"https://agile-staging.8x8.com/rest/api/2/status/10001","description":"Issues that passed through the flow and are complete.","iconUrl":"https://agile-staging.8x8.com/","name":"Done","id":"10001","statusCategory":{"self":"https://agile-staging.8x8.com/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}}}}';
                }else{
                    res= http.send(req);
                    jsonInput= res.getBody();
                }
            }catch(Exception ex)
            {
                ErrorLog+=ji+','+res.getBody()+','+res.getStatus()+','+res.getStatusCode()+','+ex.getMessage()+'\n';
            }
            
            
            if(res.getStatusCode()==200 || test.isRunningTest() ){
                
                System.debug('-----'+jsonInput);
                GnrSf__JiraIssue__c jira=new GnrSf__JiraIssue__c();
                
                Map<String, Object> mainData = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
                
                String FieldJson = JSON.serialize(mainData.get('fields'));              
                Map<String, Object> fieldsmap = (Map<String, Object>)JSON.deserializeUntyped(FieldJson); 
                jira.Name=String.valueof(mainData.get('key'));
                jira.GnrSf__IssueKey__c=String.valueof(mainData.get('key'));
                jira.GnrSf__IssueId__c=Decimal.valueof(String.valueof(mainData.get('id')));
                jira.GnrSf__Summary__c=String.valueof(fieldsmap.get('summary'));
                jira.GnrSf__Description__c=String.valueof(fieldsmap.get('description'));
                //jira.GnrSf__Resolution__c=String.valueof(fieldsmap.get('resolution'));
                if(fieldsmap.containsKey('status')){
                    Map<String, Object> Statusmap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldsmap.get('status')));
                    jira.GnrSf__Status__c=String.valueof(Statusmap.get('name'));
                }
                if(fieldsmap.containsKey('priority')){
                    Map<String, Object> prioritymap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldsmap.get('priority')));
                    jira.GnrSf__Priority__c=String.valueof(prioritymap.get('name'));
                }
                if(fieldsmap.containsKey('reporter')){
                    Map<String, Object> reportermap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldsmap.get('reporter')));
                    // Map<String, Object> reportermap = (Map<String, Object>)fieldsmap.get('reporter');
                    System.debug('--------'+String.valueof(reportermap.get('displayName')));
                    jira.GnrSf__Reporter__c=String.valueof(reportermap.get('displayName'));
                }
                if(fieldsmap.containsKey('issuetype')){
                    
                    Map<String, Object> issuetypemap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldsmap.get('issuetype')));
                    
                    //Map<String, Object> issuetypemap = (Map<String, Object>)fieldsmap.get('issuetype');
                    System.debug('--------'+String.valueof(issuetypemap.get('name')));
                    jira.GnrSf__IssueType__c=String.valueof(issuetypemap.get('name'));
                }
                if(fieldsmap.get('assignee')!=null){
                    Map<String, Object> assigneeMap =new   Map<String, Object>();
                    assigneeMap= (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldsmap.get('assignee')));
                    jira.GnrSf__Assignee__c=assigneeMap.containsKey('displayName')?String.valueof(assigneeMap.get('displayName')):''; 
                }
                
                
                if(fieldsmap.get('resolution')!=null){
                    Map<String, Object> resolutionMap =new   Map<String, Object>();
                    resolutionMap= (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldsmap.get('resolution')));
                    
                    jira.GnrSf__resolution__c=resolutionMap.containsKey('name')?String.valueof(resolutionMap.get('name')):''; 
                    
                }
                if(fieldsmap.get('resolutiondate')!=null){
                    String  resolutiondate= JSON.serialize(fieldsmap.get('resolutiondate'));
                    
                    System.debug(resolutiondate);
                    
                    resolutiondate=resolutiondate.substring(0, resolutiondate.indexOf('.'));
                    System.debug(resolutiondate);
                    resolutiondate=resolutiondate.remove('"');
                    String[] splitDateTime = resolutiondate.split('T');
                    String[] onlyDate = splitDateTime[0].split('-');
                    String[] onlyTime = splitDateTime[1].split(':');
                    System.debug(splitDateTime);
                    System.debug(onlyDate);      
                    System.debug(onlyTime);
                    DateTime dt = DateTime.newInstanceGMT(Integer.valueOf(onlyDate[0]),Integer.valueOf(onlyDate[1]), Integer.valueOf(onlyDate[2]), Integer.valueOf(onlyTime[0]), Integer.valueOf(onlyTime[1]), Integer.valueOf(onlyTime[2]));
                    
                    jira.GnrSf__resolutiondate__c=dt; 
                }
                if(fieldsmap.get('creator')!=null){
                    Map<String, Object> creatorMap =new   Map<String, Object>();
                    creatorMap= (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldsmap.get('creator')));
                    jira.GnrSf__creator__c=creatorMap.containsKey('displayName')?String.valueof(creatorMap.get('displayName')):''; 
                    
                }
                if(fieldsmap.get('created')!=null){
                    String  created= JSON.serialize(fieldsmap.get('created'));
                    
                    System.debug(created);
                    
                    created=created.substring(0, created.indexOf('.'));
                    System.debug(created);
                    created=created.remove('"');
                    String[] splitDateTime = created.split('T');
                    String[] onlyDate = splitDateTime[0].split('-');
                    String[] onlyTime = splitDateTime[1].split(':');
                    System.debug(splitDateTime);
                    System.debug(onlyDate);      
                    System.debug(onlyTime);
                    DateTime dt = DateTime.newInstanceGMT(Integer.valueOf(onlyDate[0]),Integer.valueOf(onlyDate[1]), Integer.valueOf(onlyDate[2]), Integer.valueOf(onlyTime[0]), Integer.valueOf(onlyTime[1]), Integer.valueOf(onlyTime[2]));
                    
                    jira.GnrSf__created__c=dt;
                    
                }
                jira.GnrSf__Jira_Link__c = EndPoint != '' ? EndPoint+ '/browse/' + ji : '';
                Map<String, Object> ProjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldsmap.get('project')));
                jira.GnrSf__Project__c=String.valueOf(ProjectMap.get('key'));
                jira.GnrSf__Project_Id__c=Decimal.valueOf(String.valueOf(ProjectMap.get('id')));
                
                jira.GnrSf__JsonData__c=jsonInput;
                JiraList.add(Jira); 
            }else{
                ErrorLog+=ji+','+res.getBody()+','+res.getStatus()+','+res.getStatusCode()+'\n';
            }
            
            
            
        }
        if(!JiraList.isEmpty())
            insert JiraList; 
    }
    global void finish(Database.BatchableContext BC){
        if(ErrorLog!=''){
            ContentVersion cv=new ContentVersion();
            cv.Title='Jira_Status';
            cv.PathOnClient='Jira_Status.csv';
            cv.VersionData=Blob.valueof(ErrorLog);
            insert cv; 
        } 
        
    }
    
}
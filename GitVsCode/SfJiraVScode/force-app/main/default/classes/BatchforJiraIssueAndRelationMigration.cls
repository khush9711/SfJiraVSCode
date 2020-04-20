public class BatchforJiraIssueAndRelationMigration implements Database.Batchable<String>,  Database.AllowsCallouts, Database.Stateful {
    Map<String,List<String>> JiraKeyToListOfCaseNumbers = new Map<String,List<String>>();
    Map<String,String> CaseNumIdMap = new Map<String,String>();
    Map<String,List<String>> CaseIdJiraKeyMap = new Map<String,List<String>>();
    
    String ErrorLog='';
    List<ContentVersion> contList=new List<ContentVersion>();
    List<GnrSf__JiraErrorLogs__c> ErrorLogs = new List<GnrSf__JiraErrorLogs__c>();
    public BatchforJiraIssueAndRelationMigration(String ContDocId){
      
        ContentVersion content=[Select ContentDocumentId,VersionData,ContentBodyId,Title,Description from ContentVersion where ContentDocumentId=:ContDocId];
        
        Blob csvFileBody =content.VersionData;
        String csvAsString= csvFileBody.toString();
        List<String> csvFileLines= csvAsString.split('\n');
        Map<String,List<String>> Map1=new Map<String,List<String>>();
        
        for(String s:csvFileLines){
            List<String> List1=s.split(','); 
            
            if(Map1.ContainsKey(List1[0]))
            {
                Map1.get(List1[0]).add(List1[1]);
            }else
            { 
                Map1.put(List1[0],new List<String>{List1[1]}) ;
            }
        }
        
        Map<String,List<String>> caseJiraMap=new Map<String,List<String>>();
        
        for(String caseNum:Map1.Keyset())
        {
            List<String> JiraKeys=new List<String>();
            
            String Val=String.valueof(Map1.get(caseNum));
            if(Val!='null'){
                System.debug('Val---'+Val);
                Val=Val.replace(';','/');
                Val=Val.replace(' ','/');
                Val=Val.replace('(','');
                Val=Val.replace(')','');
                Val=Val.replace('"','');
                
                if(Val.contains('/')){
                    JiraKeys=Val.split('/');
                    System.debug(JiraKeys);
                }
                else{
                    JiraKeys.add(Val);
                    System.debug(JiraKeys);
                }
                
                for(String JiraKey:JiraKeys){
                    JiraKey=JiraKey.replace('_','-');
                    JiraKey=JiraKey.replace('--','-');
                    System.debug(JiraKey);
                    if(JiraKey!=''){
                        if(JiraKey.Contains('GC-')){
                            
                            JiraKey=JiraKey.remove(','); 
                            JiraKey=JiraKey.normalizeSpace();
                            if(caseJiraMap.ContainsKey(JiraKey))
                            {
                                caseJiraMap.get(JiraKey).add(caseNum);
                                System.debug(caseJiraMap);
                            }else
                            { 
                                caseJiraMap.put(JiraKey,new List<String>{caseNum}) ;
                                System.debug(caseJiraMap);
                                
                            }
                        }
                    }
                }
            }
        }
        
        
        System.debug(caseJiraMap);
            
        
          this.JiraKeyToListOfCaseNumbers=caseJiraMap;
        Set<String> Nums=new Set<String>();
        for(String JiraKey:JiraKeyToListOfCaseNumbers.keyset())
        {
            for(String CaseNums:JiraKeyToListOfCaseNumbers.get(JiraKey)){
                Nums.add(CaseNums);
            }
        }
        System.debug('Nums--'+Nums);
        List<Case> CaseList=[Select id,CaseNumber from Case where CaseNumber in:Nums];
        for(Case c:CaseList)
        {
            CaseNumIdMap.put(c.CaseNumber,c.id);
        }
        
    }
    public List<String> start(Database.BatchableContext BC){
        List<String> JiraIds= new List<String>();
        JiraIds.addAll(JiraKeyToListOfCaseNumbers.keySet());
        return JiraIds;
    }
    
    public void execute(Database.BatchableContext info, List<String> JiraIds) {
        for(String ji:JiraIds){
            for(String Casenum:JiraKeyToListOfCaseNumbers.get(ji)){
              
                    GnrSf.EditAddJiraIssueController.linkIssue(ji,CaseNumIdMap.get(Casenum),'case');
           
        }
    }
    }
    public void finish(Database.BatchableContext BC){
       
    }
    
    
}
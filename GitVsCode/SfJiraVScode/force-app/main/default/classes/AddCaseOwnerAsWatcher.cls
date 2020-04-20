public class AddCaseOwnerAsWatcher {
    @future(callout=true)
    public static void addwatcher(String jkey,String owneremail) {
        string body='';
        String uname;
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('http://45.79.128.241:8080/rest/api/2/user/search?username='+owneremail+'');
        req.setMethod('GET');
        String username = 'grazitti';
        String password = 'Jir@43AA$int';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        HTTPResponse resp = h.send(req);
        if(resp.getStatusCode() == 200){
            List< Object> results = (List< Object>) JSON.deserializeUntyped(resp.getBody());
            if(!results.isempty()){
                Object ownername=results[0];
                Map<String, Object> username1 = ( Map<String, Object>) ownername;
                uname =(String) username1.get('name');
                req.setEndpoint('http://45.79.128.241:8080/rest/api/2/issue/'+jkey+'/watchers');
                req.setMethod('POST');
                String usernamee = 'grazitti';
                String passwordd = 'Jir@43AA$int';
                Blob headerValuee = Blob.valueOf(usernamee + ':' + passwordd);
                String authorizationHeaderr = 'Basic ' + EncodingUtil.base64Encode(headerValuee);
                req.setHeader('Authorization', authorizationHeaderr);
                req.setHeader('Content-Type', 'application/json');
                body='"'+uname+'"';
                req.setBody(body);
                HTTPResponse resp1 = h.send(req);
                System.debug(resp1.getStatusCode()); 
                if(resp1.getStatusCode() == 204){
                }
            } 
        }
    }
}
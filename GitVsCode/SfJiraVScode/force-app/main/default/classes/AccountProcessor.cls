public class AccountProcessor
{

@future
public static void countContacts(set<id> setId)
{

    List<Account> lstAccount = [select id,(select id from contacts)from account where id in :setId ];
    List<Account> staccount =[Select Number_of_Contacts__c from account];
     for (Account acc: lstAccount)
     {
         List <contact>lstCont = acc.contacts ;
         acc.Number_of_Contacts__c = lstCont.size();
     
     
     }
     update lstAccount;
}
}
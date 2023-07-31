@RestResource(UrlMapping='/account/*/setdescription')
global with sharing class AccountResource {
    @HttpPost
    // e.g. /services/apexrest/account/{{accountId}}/setdescription?description={{description}}
	global static void setDescription(String description)
	{
        RestRequest req = RestContext.request;
        String[] uriParts = req.requestURI.split('/');
        String accountId = uriParts[2];
        IAccountService accountService = (IAccountService) Application.Service.newInstance(IAccountService.class);
        accountService.setDescription(new Set<Id>{accountId},description);
    }
}
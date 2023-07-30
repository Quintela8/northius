@RestResource(UrlMapping='/account/*/setdescription')
global with sharin class AccountResource {
    @HttpPost
    // e.g. /services/apexrest/account/{{accountId}}/setdescription?description={{description}}
	global static void setDescription(String description)
	{
        String[] uriParts = req.requestURI.split('/');
        String accountId = uriParts[2];
        String description = req.params.get('description');
        IAccountService accountService = AccountService.newInstance();
        accountService.setDescription(new Set<Id>{accountId},description);
    }
}
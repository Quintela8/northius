@IsTest
private class AccountResource_Test {

    @IsTest
	private static void callingSetAccountDescription()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
        String description = 'Sample Description';

		// Given
		Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
		Account acc = new Account(Id = accountId, Name = 'Test');

        IAccountService mockservice = (IAccountService)mocks.mock(IAccountService.class);

		Application.Service.setMock(IAccountService.class, mockService);

        String request = '{"description": "'+description+'"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/account/'+accountId+'/setdescription?description='+description;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(request);
        RestContext.request = req;
        RestContext.response = res;
		AccountResource.setDescription(description);

		// Then
        ((IAccountService) mocks.verify(mockService,1)).setDescription(new Set<Id>{accountId}, description);
	}
}
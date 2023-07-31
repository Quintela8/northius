@IsTest
private class AccountService_Test {
    @IsTest
	static void itShouldSetAccountDescription()
	{
		String description = 'Sample Description';
		// GIVEN a list of account records
		List<Account> accounts = new List<Account>
		{
			new Account(Name = 'A', Id = fflib_IDGenerator.generate(Schema.Account.SObjectType)),
			new Account(Name = 'B', Id = fflib_IDGenerator.generate(Schema.Account.SObjectType)),
			new Account(Name = 'C', Id = fflib_IDGenerator.generate(Schema.Account.SObjectType))
		};

		Set<Id> accountIds = new Map<Id, SObject>(accounts).keySet();

		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork unitOfWorkMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
		IAccountSelector selectorMock = (IAccountSelector) mocks.mock(IAccountSelector.class);
		IAccountDomain domainMock = (IAccountDomain) mocks.mock(IAccountDomain.class);

		mocks.startStubbing();
		mocks.when(selectorMock.sObjectType()).thenReturn(Schema.Account.SObjectType);
		mocks.when(selectorMock.selectSObjectsById(accountIds)).thenReturn(accounts);
		mocks.when(domainMock.getType()).thenReturn(Schema.Account.SObjectType);
		mocks.when(domainMock.getRecords()).thenReturn(accounts);
		mocks.stopStubbing();

		Application.UnitOfWork.setMock(unitOfWorkMock);
		Application.Domain.setMock(domainMock);
		Application.Selector.setMock(selectorMock);

		System.Test.startTest();
		new AccountService().setDescription(accountIds,description);
		System.Test.stopTest();

		((IAccountSelector) mocks.verify(selectorMock)).selectSObjectsById(accountIds);
		//((IAccountDomain) mocks.verify(domainMock)).setDescription(description);
		((fflib_ISObjectUnitOfWork)	mocks.verify(unitOfWorkMock)).registerDirty(accounts);
		((fflib_ISObjectUnitOfWork)	mocks.verify(unitOfWorkMock)).commitWork();
	}
}
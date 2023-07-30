@IsTest
private class AccountService_Test {
    @IsTest
	static void itShouldSetAccountDescription()
	{
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
		IAccountDomain domainMock = (IAccountDomain) mocks.mock(AccountDomain.class);

		mocks.startStubbing();
		mocks.when(selectorMock.sObjectType()).thenReturn(Schema.Account.SObjectType);
		mocks.when(selectorMock.selectSObjectsById(accountIds)).thenReturn(accounts);
		mocks.when(domainMock.getType()).thenReturn(Schema.Account.SObjectType);
		mocks.when(domainMock.getRecords()).thenReturn(accounts);
		mocks.stopStubbing();

		Application.UnitOfWork.setMock(unitOfWorkMock);
		Application.Domain.setMock(domainMock);
		Application.Selector.setMock(selectorMock);

		// WHEN we update the opportunity Activity
		System.Test.startTest();
		new AccountService().setDescription(accountIds,'test description');
		System.Test.stopTest();

		// THEN the accounts should be queried from the selector
		//     and the domain should be invoked to update the account description 
		((IAccountSelector) mocks.verify(selectorMock)).selectSObjectsById(accountIds);
		((IAccountDomain) mocks.verify(domainMock)).setDescription('test description');
		((fflib_ISObjectUnitOfWork)	mocks.verify(unitOfWorkMock)).registerDirty(accounts);
		((fflib_ISObjectUnitOfWork)	mocks.verify(unitOfWorkMock)).commitWork();
	}
}
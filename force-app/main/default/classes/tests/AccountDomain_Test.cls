@IsTest
private class AccountDomain_Test {
    
    @IsTest
	static void itShouldSetAccountDescription()
	{
		// Given a domain with few Account records with an empty description field
		AccountDomain domain = new AccountDomain(new List<Account>{	new Account(), new Account(), new Account()	});

		// WHEN we set the description field to a value
		System.Test.startTest();
		domain.setDescription('test description');
		System.Test.stopTest();

		// THEN the description should be updated
		List<Account> result = (List<Account>) domain.getRecords();
		System.assertEquals(3, result.size());
		final String expectedValue = 'test description';
		for (Account record : result)
		{
			System.assertEquals(expectedValue, record.Description);
		}
	}
}
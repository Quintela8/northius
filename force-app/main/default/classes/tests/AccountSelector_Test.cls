@IsTest
private class AccountSelector_Test {

    @IsTest
	private static void testSelectById()
	{	
		// Test data
		Account acc = new Account();
		acc.Description = 'Something';
        acc.AccountNumber = 'A2';
		acc.Name = 'name';
		insert acc;
				
		// Query
		List<Account> accounts = 
			new AccountSelector().selectById(new Set<Id> { acc.Id });
			
		// Assert
		System.assertEquals('Something', accounts[0].Description);		
		System.assertEquals('name', accounts[0].Name);			
	}
    
}
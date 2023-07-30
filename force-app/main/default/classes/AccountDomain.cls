public with sharing class AccountDomain extends fflib_SObjects implements IAccountDomain{

    public AccountDomain(List<Account> sObjectList)
	{
		super(sObjectList, Schema.Account.SObjectType);
	}

    public void setDescription(String description)
	{
		for (Account account : (List<Account>) getRecords())
		{
			account.Description = description;
		}
	}

    public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new AccountDomain((List<SObject>) objectList);
		}
	}
}
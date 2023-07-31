public with sharing class AccountDomain extends fflib_SObjectDomain implements IAccountDomain{

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

    public class Constructor implements fflib_SObjectDomain.IConstructable, di_binding.Provider
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AccountDomain(sObjectList);
        }

		public Object newInstance(Object params) {
            return new AccountDomain((List<Account>)params);
        }
	}
}
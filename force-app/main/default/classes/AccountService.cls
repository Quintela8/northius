public with sharing class AccountService implements IAccountService
{
    public static IAccountService newInstance()
	{
		return (IAccountService) Application.Service.newInstance(IAccountService.class);
	}
    /**
	 * Update last Opportunity activity on the related Accounts
	 *
	 * @param accountIds The account Ids of the records to update
	 */
	public void setDescription(Set<Id> accountIds,String description)
	{
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		IAccountDomain aDomain = (IAccountDomain) Application.Domain.newInstance( accountIds );

		aDomain.setDescription(description);

		uow.registerDirty(aDomain.getRecords());
		uow.commitWork();
	}
}
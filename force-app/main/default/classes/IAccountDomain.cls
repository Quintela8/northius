public interface IAccountDomain extends fflib_ISObjects {
    List<Account> getAccounts();
	void setDescription(String description);
}
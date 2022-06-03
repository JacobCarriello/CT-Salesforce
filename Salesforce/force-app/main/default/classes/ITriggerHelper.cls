public interface ITriggerHelper {
    List<SObjectUnitOfWork> getUnitsOfWork();
    void execute(SObject so);
	void execute(SObject so, SObject oldSo);
}
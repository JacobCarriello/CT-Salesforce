public virtual class BaseTriggerHelper
    implements ITriggerHelper
{
    protected List<SObjectUnitOfWork> m_uowList = new List<SObjectUnitOfWork>();

    public BaseTriggerHelper() {

    }

    public virtual void execute(SObject so) {}

    public virtual void execute(SObject so, SObject oldSo) {}

    public virtual List<SObjectUnitOfWork> getUnitsOfWork() {
        return m_uowList;
    }
}
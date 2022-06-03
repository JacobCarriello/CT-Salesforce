/* Interface containing methods Trigger Handlers must implement to enforce best practice and bulkification of triggers. */
public interface ITrigger {
    /* BULK Methods */
    // Use these to cache any data required into maps prior to execution of the trigger. 
    void bulkBefore();                            // This method is called prior to execution of a BEFORE trigger.
    void bulkAfter();                             // This method is called prior to execution of an AFTER trigger.

    /* BEFORE Methods */
    // Never execute any SOQL/SOSL etc in these and other iterative methods. 
    void beforeInsert(SObject so);                // This method is called iteratively for each record to be inserted during a BEFORE trigger.
    void beforeUpdate(SObject oldSo, SObject so); // This method is called iteratively for each record to be updated during a BEFORE trigger.
    void beforeDelete(SObject so);                // This method is called iteratively for each record to be deleted during a BEFORE trigger.

    /* AFTER Methods */
    // Always put field validation in the 'After' methods in case another trigger has modified any values.
    // The records are 'read only' by this point; record updates will need to be collected and passed to the andFinally method via the Handler
    void afterInsert(SObject so);                 // This method is called iteratively for each record inserted during an AFTER trigger.
    void afterUpdate(SObject oldSo, SObject so);  // This method is called iteratively for each record updated during an AFTER trigger.
    void afterDelete(SObject so);                 // This method is called iteratively for each record deleted during an AFTER trigger.

    /* ANDFINALLY Method */
    // Use this method to accomplish any final operations such as creation or updates of other records.
    void andFinally();                            // This method is called once all records have been processed by the trigger. 
}
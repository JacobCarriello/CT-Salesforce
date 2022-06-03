public with sharing class CTTriggerFactory {
    public static void createAndExecuteHandler (Type t) {                                                                     // Create and execute a Trigger Handler. Accepts the type of Handler to instantiate.
        ITrigger handler = getHandler(t);                                                                                     // Get the Handler for the object being processed.
        if (handler == null) {throw new TriggerException('No Trigger Handler found named: ' + t.getName());}                  // Verify we have a Handler registered, else throw. Must register new Handlers in getHandler.
        execute(handler);                                                                                                     // Execute the Handler to fulfill the Trigger.
    }

    private static void execute (ITrigger handler) {                                                                          // Control the execution of the Handler. Accepts a ITrigger Handler to execute.
        if (Trigger.isBefore) {
            handler.bulkBefore();                                                                                             // Call the bulkBefore to handle any caching of data and enable bulkification.
            if (Trigger.isDelete) {for (SObject so : Trigger.old) {handler.beforeDelete(so);}}                                // Iterate through the records to be deleted and pass to the Handler.
            else if (Trigger.isInsert) {for (SObject so : Trigger.new) {handler.beforeInsert(so);}}                           // Iterate through the records to be inserted and pass to the Handler.
            else if (Trigger.isUpdate) {for (SObject so : Trigger.old) {handler.beforeUpdate(so,Trigger.newMap.get(so.Id));}} // Iterate through the records to be updated and pass to the Handler.
        } else {
            handler.bulkAfter();                                                                                              // Call the bulkAfter to handle any caching of data and enable bulkification.
            if (Trigger.isDelete) {for (SObject so : Trigger.old) {handler.afterDelete(so);}}                                 // Iterate through the deleted records and pass to the Handler.
            else if (Trigger.isInsert) {for (SObject so : Trigger.new) {handler.afterInsert(so);}}                            // Iterate through the inserted records and pass to the Handler.
            else if (Trigger.isUpdate) {for (SObject so : Trigger.old) {handler.afterUpdate(so,Trigger.newMap.get(so.Id));}}  // Iterate through the updated records and pass to the Handler.
        }
        handler.andFinally();                                                                                                 // Perform any post processing.
    }

    private static ITrigger getHandler (Type t) {                                                                             // Get the named Handler. Accepts the class of Handler to instantiate.
        Object o = t.newInstance();                                                                                           // Instantiate the type.
        if (!(o instanceOf ITrigger)) {return null;}                                                                          // If it isn't an instance of ITrigger, return null.
        return (ITrigger)o;                                                                                                   // Return the Trigger Handler.
    }

    public class TriggerException extends Exception {}
}
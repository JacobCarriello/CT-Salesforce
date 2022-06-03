global class ScheduleBatchAuditTrailLog implements Schedulable {
    global void execute (SchedulableContext sc) {
        ID batch = Database.executeBatch(new BatchAuditTrailLog ());
    }
}
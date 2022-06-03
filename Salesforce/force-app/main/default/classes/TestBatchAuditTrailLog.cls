@isTest
private class TestBatchAuditTrailLog {

    @isTest
    private static void testRun () {
        Test.startTest();
        Database.executeBatch(new BatchAuditTrailLog ());
        Test.stopTest();
    }

    @isTest
    private static void testSchedule () {
        String cron = '0 0 23 ? * SAT';
        Test.startTest();
        String job = System.schedule('ScheduleBatchAuditTrailLog',cron,new ScheduleBatchAuditTrailLog ());
        Test.stopTest();
    }

    // @isTest
    // private static void testNone () {
    //     Test.startTest();
    //     BatchAuditTrailLog bATL = new BatchAuditTrailLog ();
    //     BatchAuditTrailLog.dateRange = 'NEXT_YEAR';
    //     Database.executeBatch(bATL);
    //     Test.stopTest();
    // }
}
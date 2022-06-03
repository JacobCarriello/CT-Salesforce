global class ScheduledBatch_CandidateStatusUpdate implements Schedulable {
   global void execute(SchedulableContext sc) {
      Batch_CandidateStatusUpdate b = new Batch_CandidateStatusUpdate(); 
      Database.executebatch(b);
   }
}
trigger GrossProfitTrigger on TR1__Gross_Profit__c (after insert, after update){
	Integer seconds = Datetime.now().second() + 3;
	Integer minutes = Datetime.now().minute();
	Integer hours = Datetime.now().hour();
	if (Test.isRunningTest()) {
		seconds = 65 + 3;
		minutes = 65;
	}
	if (seconds >= 60) {
		seconds -= 60;
		minutes ++;
		if (minutes >= 60) {
			minutes -= 60;
			hours ++;
		}
	}
	String hour = String.valueOf(hours);
	String min = String.valueOf(minutes);
	String ss = String.valueOf(seconds);
	String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
	system.debug('bw: nextFireTime = ' + nextFireTime);
	GrossProfitTriggerHandler_AsyncScheduled scheduleGrossProfit = new GrossProfitTriggerHandler_AsyncScheduled(Trigger.new);
	System.schedule('GrossProfitTriggerHandler_Async' + String.valueOf(Math.random()), nextFireTime, scheduleGrossProfit);
}
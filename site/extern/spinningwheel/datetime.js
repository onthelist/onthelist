function openDate() {
	var now = new Date();
	var days = { };
	var years = { };
	var months = { 1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec' };
	
	for( var i = 1; i < 32; i += 1 ) {
		days[i] = i;
	}

	for( i = now.getFullYear()-100; i < now.getFullYear()+1; i += 1 ) {
		years[i] = i;
	}

	SpinningWheel.addSlot(years, 'right', 1999);
	SpinningWheel.addSlot(months, '', 4);
	SpinningWheel.addSlot(days, 'right', 12);
	
	SpinningWheel.setCancelAction(cancel);
	SpinningWheel.setDoneAction(done);
	
	SpinningWheel.open();
}

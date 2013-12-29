#Init model counter
var catapultModel = nil;

var placeCatapultByMouse = func {
	var click_pos = geo.click_position();
	var ac = geo.aircraft_position();

	# position catapult on click
	if (!__kbd.ctrl.getBoolValue()) {
		# remove existing catapult model
		if (catapultModel != nil)
			catapultModel.getParent().removeChild(catapultModel.getName(), catapultModel.getIndex());

		# reposition catapult model
		catapultModel = geo.put_model("Aircraft/X100/Models/X100_catapult.xml", click_pos.lat(), click_pos.lon(), (click_pos.alt()), (getprop("/orientation/heading-deg")), 18);
		
		# reposition aircraft
		# setprop("/orientation/pitch-deg", 18);
		setprop("/position/latitude-deg", click_pos.lat());
		setprop("/position/longitude-deg", click_pos.lon());
		setprop("/position/altitude-ft", 3.2808399 * click_pos.alt() + 0.8);
		
		# reposition tower view
		var tower = "/sim/tower";
		setprop(tower ~ "/latitude-deg", click_pos.lat() + 0.00003);
		setprop(tower ~ "/longitude-deg", click_pos.lon() + 0.00003);
		setprop(tower ~ "/altitude-ft", 3.2808399 * click_pos.alt() + 5);
		
		# reset animations
		setprop("/sim/model/X100/launch-pad/position-norm",0);
	}
	
	# start fire on Ctrl-click
	else {
		var click_pos_fire = geo.click_position();
		wildfire.ignite(click_pos_fire);
	}
}

setlistener("/sim/signals/click",placeCatapultByMouse);

var launchCatapult = func {
	# time on catapult = 1/10 sec
	# speed when leaving catapult = 50 km/h ?
	var countdownRunning = 1;
	var count = 5;
	var countdown = func {
		if (countdownRunning) {
			if (count != 0) {
				setprop("/sim/screen/white",count);
				count = count - 1;
				settimer(countdown, 1);
			}
			else {
				countdownRunning = 0;
				setprop("/sim/screen/yellow","Go!");
				launch();
				var launchPad = aircraft.door.new("/sim/model/X100/launch-pad", 0.2);
				launchPad.toggle();
			}
		}
	}
	countdown();
	
	var launchRunning = 1;
	var magnitude = 230; # lbs, unrealisticly high, because the FDM is wrong
	var launch = func {
		if (launchRunning) {
			if (magnitude == 0){
				launchRunning = 0;
				
				# remove launcher contact points 
				setprop("/fdm/jsbsim/contact/unit[6]/pos-norm",0);
				setprop("/fdm/jsbsim/contact/unit[7]/pos-norm",0);
				setprop("/fdm/jsbsim/contact/unit[8]/pos-norm",0);
			}
			setprop("/fdm/jsbsim/external_reactions/catapult/magnitude",magnitude);
			print (magnitude);
			magnitude = 0;
			settimer(launch, 0.1);
		}
	}
}
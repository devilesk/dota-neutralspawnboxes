"use strict";

var OverlayState = {
	cbTowerDayVisionRange:true,
	cbTowerNightVisionRange:true,
	cbTowerTrueSightRange:true,
	cbTowerAttackRange:true,
	cbNeutralSpawnBox:true,
	cbDetectNeutrals:false,
	cbSentryVision:true,
	cbWardVision:true,
	cbHeroXPRange:true,
	cbFogOfWar:true,
	btnMinimize:true
}

function OnCheckBoxPressed(trigger_name) {
    OverlayState[trigger_name] = !OverlayState[trigger_name];
    $.Msg( "In function foo():", {v: OverlayState[trigger_name], t: trigger_name} );
    GameEvents.SendCustomGameEventToServer( "toggle_overlay", { "trigger_name" : trigger_name, "state" : OverlayState[trigger_name] } );
}

function OnMinimizePressed() {
    OverlayState['btnMinimize'] = !OverlayState['btnMinimize'];
    $.GetContextPanel().ToggleClass('hidden');
    $.Msg( "In function foo():", {v: OverlayState['btnMinimize']} );
}

(function() {
    $('#btn1').checked = true;
    $('#btn2').checked = true;
    $('#btn3').checked = true;
    $('#btn4').checked = true;
    $('#btn5').checked = true;
    $('#btn6').checked = false;
    $('#btn7').checked = true;
    $('#btn8').checked = true;
    $('#btn9').checked = true;
    $('#btn10').checked = true;
})();

// Code released to the public domain by Lotek Ixtar @ OsGrid
//
// Written to avoid bugs with llVolumeDetect() on older OpenSim such as 0.8
// Of course fully working on modern OpenSim as well :)
//
// Doesn't use ossl functions so should work in SL too
// ===========================================================================

float   WAIT_TIME = 10; // seconds before object is recharged

list    g_lClothing;    // holds clothes to strip

integer flip = FALSE;   // workaround
integer RLV_RC =-1812221819;

integer g_iNotecardLine;
key     g_kdsNotecard;

init() {
	if (llGetInventoryKey(".config")==NULL_KEY) {
		llOwnerSay("Error: .config not found");
		return;
	}

	llSetText("Configuring", <1,1,1>, 1);

	g_lClothing = [];
	g_iNotecardLine = 0;
	g_kdsNotecard = llGetNotecardLine("strip.config", g_iNotecardLine);
}

CovertSay(string sText)
{
	string sObjectName = llGetObjectName();
	llSetObjectName(".");
	llSay(0, sText);
	llSetObjectName(sObjectName);
}

default
{
	state_entry()
	{
		init();
	}

	on_rez(integer start_param)
	{
		init();
	}

	changed(integer iChange)
	{
		if(iChange & CHANGED_REGION_RESTART || iChange & CHANGED_INVENTORY)
		{
			init();
		}
	}

	collision_start(integer total_number)
	{
		if (flip == FALSE) {
			key kVictim = llDetectedKey(0);
			if (kVictim==NULL_KEY) return;
			CovertSay("Oh no! Your top has caught on the thorn of a bush!");
			integer i;
			for (i = 0; i < llGetListLength(g_lClothing); i++)
				llSay(RLV_RC, "strip,"+(string)kVictim+",@remoutfit:"+llList2String(g_lClothing,i)+"=force");
			for (i = 0; i < llGetInventoryNumber(INVENTORY_SOUND); i++)
				llTriggerSound(llGetInventoryName(INVENTORY_SOUND, i), 1.0);
			llSetTimerEvent(WAIT_TIME);
			flip = TRUE;
		}
	}

	timer()
	{
		// Timer ran out. Recharge.
		llSetTimerEvent(0);
		flip = FALSE;
		CovertSay("Naughty bush! Time for the weedkiller!");
	}

	dataserver(key kID, string sData)
	{
		if (kID!=g_kdsNotecard) return;

		if (sData==EOF) {
			// notecard reading finished
			flip = FALSE;
			llSetStatus(STATUS_PHANTOM, FALSE); // workaround
			llSleep(0.4);
			llVolumeDetect(TRUE);
			// trap all ready
			llSetText("", <1,1,1>, 1);
		} else {
				string sLine = llStringTrim(sData, STRING_TRIM);
			if (llGetSubString(sLine, 0, 0)!="#") g_lClothing += sData;
			g_kdsNotecard = llGetNotecardLine("strip.config", ++g_iNotecardLine);
		}
	}
}

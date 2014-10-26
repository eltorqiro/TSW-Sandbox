/**
 * ...
 * @author ElTorqiro
 */


import com.Utils.Archive;
import com.Utils.Signal;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.SpellData;
import com.GameInterface.Spell;
import com.GameInterface.Utils;
import com.GameInterface.UtilsBase;
import com.GameInterface.ProjectUtils;


// game constants
var PLAYER_MAX_ACTIVE_SPELLS:String = "PlayerMaxActiveSpells";
var PLAYER_START_SLOT_SPELLS:String = "PlayerStartSlotSpells";


function OnModuleActivated(config:Archive):Void {

	Shortcut.SignalShortcutAdded.Connect( SlotShortcutAdded, this  );
	Shortcut.SignalShortcutRemoved.Connect( SlotShortcutRemoved, this );
    Shortcut.SignalShortcutUsed.Connect( SlotShortcutUsed, this );
	
	UtilsBase.PrintChatText( "Sandbox: module activated" );
}


function OnModuleDeactivated():Archive {

    Shortcut.SignalShortcutAdded.Disconnect( SlotShortcutAdded, this );
    Shortcut.SignalShortcutRemoved.Disconnect( SlotShortcutRemoved, this );
    Shortcut.SignalShortcutUsed.Disconnect( SlotShortcutUsed, this );
	
	UtilsBase.PrintChatText( "Sandbox: module deactivated" );
	
	return;
}


function SlotShortcutAdded(itemPos:Number):Void {
	ShortcutEventHandler( itemPos, "added" );
}


function SlotShortcutRemoved(itemPos:Number):Void {
	ShortcutEventHandler( itemPos, "removed" );
}


function SlotShortcutUsed(itemPos:Number):Void {
	ShortcutEventHandler( itemPos, "used" );
}


function ShortcutEventHandler(itemPos:Number, event:String):Void {

	var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
	var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
	
	// do nothing if not an ability shortcut
	if (!( slotNo >= 0 && slotNo < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS) && 
		(shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_SpellShortcut || shortcutData == undefined) )) return;
	
	var spellData:SpellData = Spell.GetSpellData( shortcutData.m_SpellId );

	if (spellData) {
		UtilsBase.PrintChatText( "Sandbox: shortcut " + itemPos + " " + event + ", slotNo=" + slotNo + ", spell=" + spellData.m_Id + " (" + spellData.m_Name + ")" );
	}
	
}

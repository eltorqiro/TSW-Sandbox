/**
 * ...
 * @author ElTorqiro
 */

import com.GameInterface.DistributedValue;
import com.Utils.Signal;
import com.GameInterface.UtilsBase;
import com.Utils.Archive;
import flash.geom.Point;

// global vars
var vtioLoaded:DistributedValue;
var vtioIsLoaded:DistributedValue;
var vtioRegisterAddon:DistributedValue;

var addons:Object = { };
var addonCount:Number = 0;

var gridSize:Number = 24;
var widgetMargin:Number = 4;
var leftOffset:Number = 200;
var grid:Array = [];


function onLoad() : Void {

	UtilsBase.PrintChatText( "Sandbox: loading" );

	// VTIO compatible "ready to receive registrations" dv
	vtioIsLoaded = DistributedValue.Create( "VTIO_IsLoaded" );
	vtioIsLoaded.SetValue( false );

	// VTIO compatible registration listener
	vtioRegisterAddon = DistributedValue.Create( "VTIO_RegisterAddon" );
	vtioRegisterAddon.SetValue( undefined );
	vtioRegisterAddon.SignalChanged.Connect( registerAddon );

	UtilsBase.PrintChatText( "Sandbox: ready to receive VTIO compatible addon registrations" );
	vtioIsLoaded.SetValue( true );

}


function OnModuleActivated( settings:Archive ) : Void {

	UtilsBase.PrintChatText( "Sandbox: module activating" );
}


function OnModuleDeactivated() : Archive {

	UtilsBase.PrintChatText( "Sandbox: module deactivating" );
	
	return;
}

/**
 * note OnUnload is a TSW UI callback, *not* the regular Flash onUnload function
 */
function OnUnload() : Void {

	UtilsBase.PrintChatText( "Sandbox: unloading" );
	
	// ensure "ready to receive registrations" dv is set false, so after a /reloadui addons don't try to register prematurely
	vtioIsLoaded.SetValue( false );
}


function registerAddon( dv:DistributedValue ) : Void {

	// extract fields from registration string
	var regFields:Array = string(dv.GetValue()).split( "|" );
	
	UtilsBase.PrintChatText( "registration requested: " + regFields[0] );

	// create addon properties object
	var addon:Object = {
		name: regFields[0],
		author: regFields[1],
		version: regFields[2],
		dvName: regFields[3]
	};

	// don't allow re-registration
	if ( addons[ addon.name ] ) {
		UtilsBase.PrintChatText( " -- (already registered): " + addon.name );
		return;
	}
	
	// if mod has an icon, add dockable icon instance
	var iconPath:String = regFields[4];

	if ( iconPath != "undefined" && iconPath != "" ) {
		var baseIcon:MovieClip = eval( iconPath );

		var dockIcon:MovieClip = baseIcon.duplicateMovieClip( "Icon", baseIcon._parent.getNextHighestDepth() );
		
		// hide base icon
		baseIcon._visible = false;
		
		// link event handlers to dockable icon
		var handlers:Array = [
			"onPress",
			"onRollOver",
			"onRollOut",
			"onMousePress",
			"onMouseDown",
			"onMouseUp",
			"onRelease",
			"onReleaseOutside"
		];
		
		for ( var i:Number = 0; i < handlers.length; i++ ) {
			if ( baseIcon[ handlers[i] ] ) {
				dockIcon[ handlers[i] ] = baseIcon[ handlers[i] ];
			}
		}

		// push tio references into docked icon
		dockIcon.tioData = {
			addon: addon,
			tio: this,
			
			// wrap mouse event handlers so we can trigger our own code first
			wrappedOnRollOver: dockIcon.onRollOver,
			wrappedOnRollOut: dockIcon.onRollOut
		};

		dockIcon.onRollOver = function() {
			UtilsBase.PrintChatText( "slot rollover: " + this.tioData.addon.name );

			// call intended addon behaviour for this event
			this.tioData.wrappedOnRollOver.apply( this, arguments );
		}
		
		dockIcon.onRollOut = function() {
			UtilsBase.PrintChatText( "slot rollout: " + this.tioData.addon.name );
			
			// call intended addon behaviour for this event
			this.tioData.wrappedOnRollOut.apply( this, arguments );
		}
		
		// position dockable icon in dock
		var dockPos:Point = new Point( leftOffset + (grid.length * gridSize) + (widgetMargin / 2), widgetMargin / 2 );
		this.localToGlobal( dockPos );
		dockIcon._parent.globalToLocal( dockPos );
		
		dockIcon._x = dockPos.x;
		dockIcon._y = dockPos.y;

		// size dockable icon
		var iconSize:Number = gridSize - widgetMargin;
		var dockSize:Point = new Point( iconSize, iconSize );
		this.localToGlobal( dockSize );
		dockIcon._parent.globalToLocal( dockSize );
		
		dockIcon._width = dockSize.x;
		dockIcon._height = dockSize.y;

		// add icons to addon properties
		addon.baseIcon = baseIcon;
		addon.dockIcon = dockIcon;
		
		// add dockable addon to grid list
		grid.push( addon );
	}

	// add addon property object to addon list
	addons[ addon.name ] = addon;
	addonCount++;
}
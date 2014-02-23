package com.haxepunk.nape;

import com.haxepunk.HXP;
import com.haxepunk.Scene;
import flash.events.Event;

import nape.geom.Vec2;
import nape.space.Space;
import nape.util.Debug;
import nape.util.ShapeDebug;
import nape.geom.Mat23;

import flash.geom.Point;

/**
 * Updated by Engine, main game container that holds all currently active Entities and the nape Space.
 * Useful for organization, eg. "Menu", "Level1", etc.
 */
class NapeScene extends Scene
{
	/**
	 * Nape space of the scene
	 */
	public var space:Space;
	
	/**
	 * Velocity Iterations
	 * Affects performance.
	 */
	public var velocityIterations:Int;
	/**
	 * Position Iterations
	 * Affects performance.
	 */
	public var positionIterations:Int;
	
	/**
	 * If nape debug drawing should be used.
	 */
	public var debugDraw(get, set):Bool;

	/**
	 * Constructor. Can be used to set the gravity of the Scene's Space.
	 * @param	gravity				Gravity of the Scene's Space.
	 * @param	velocityIteration	How many velocity Iterations to use when updating the Scene's Space.
	 * @param	positionIteration	How many position Iterations to use when updating the Scene's Space.
	 */
	public function new(gravity:Vec2 = null, velocityIterations:Int = 10,
						positionIterations:Int = 10) 
	{
		super();
		
		space = new Space(gravity);
		this.velocityIterations = velocityIterations;
		this.positionIterations = positionIterations;
				
		debugDraw = false;
	}
	
	/**
	 * Performed by the game loop, updates all contained Entities and the nape Space.
	 * If you override this to give your Scene update code, remember
	 * to call super.update() or your Entities will not be updated.
	 */
	override public function update()
	{
		super.update();
		
		space.step(HXP.elapsed, velocityIterations, positionIterations);
		
		if (_debug != null)
		{
			_debug.clear();
			_debug.draw(space);
			_debug.flush;
		}
	}
	
	/**
	 * Adds the Entity to the Scene and to the nape Space.
	 * @param	entity		NapeEntity object you want to add.
	 * @return	The added NapeEntity object.
	 */
	public function addNapeEntity(entity:NapeEntity)
	{
		add(entity);
		entity.body.space = space;
		return entity;
	}
	
	/**
	 * Called when Scene is changed, and the active scene is no longer this.
	 * Removes all NapeEntities from the Scene's space and
	 * removes the nape debug draw from the stage.
	 * If you override this to give your Scene end code, remember
	 * to call super.end() or your Entities will not be updated.
	 */
	override public function end()
	{
		super.end();
		space.clear();
		
		debugDraw = false;
	}
	
	private function onResize(e:Event)
	{
		_debug.display.x = HXP.camera.x;
		_debug.display.y = HXP.camera.y;
		_debug.display.scaleX = HXP.screen.scaleX * HXP.screen.scale;
		_debug.display.scaleY = HXP.screen.scaleY * HXP.screen.scale;
	}
	
	private function get_debugDraw():Bool
	{
		return _debug != null;
	}
	private function set_debugDraw(value:Bool)
	{
		// create debug display if set to true and not already done
		if (value && _debug == null)
		{
			_debug = new ShapeDebug(HXP.width, HXP.height, HXP.stage.color);
			_debug.display.scrollRect = null;
			HXP.stage.addChild(_debug.display);
			HXP.stage.addEventListener(Event.RESIZE, onResize);
		}
		// remove debug display if set to false and debug display exists
		else if (!value && _debug != null)
		{
			HXP.stage.removeEventListener(Event.RESIZE, onResize);
			HXP.stage.removeChild(_debug.display);
			_debug = null;
		}
		return value;
	}
	
	// Nape debug draw
	private var _debug:Debug;
}
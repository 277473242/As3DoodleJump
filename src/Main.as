package
{
	import com.greensock.layout.ScaleMode;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Rainssong
	 */
	
	[SWF(width=320,height=480,framerate=60)]
	
	public class Main extends Sprite
	{
		public static var stageWidth:Number;
		public static var stageHeight:Number;
		
		
		private const V0:Number = -20;
		private const S:Number = 20 * 20 / 2;
		private var doodle:Doodle;
		private var timer:Timer;
		private var time:Number;
		private var normalStickArr:Vector.<NormalStick>;
		private var stageStickArr:Vector.<Stick>;
		private var keyDictionary:Dictionary;
		private const GRAVITY:Number = 1;
		private var score:int;
		private var scoreText:TextField
		private var movingStickArr:Vector.<MovingStick>;
		private var sceneLayer:Sprite;
		private var charLayer:Sprite;
		private var uiLayer:Sprite;
		private var bgLayer:Sprite;
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			//timer = new Timer(1000);
			//timer.start();
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
			
			addChild(sceneLayer = new Sprite());
			addChild(charLayer = new Sprite());
			addChild(uiLayer = new Sprite());
			keyDictionary = new Dictionary();
			normalStickArr = new Vector.<NormalStick>;
			movingStickArr = new Vector.<MovingStick>;
			
			doodle = new Doodle();
			
			scoreText = new TextField;
			uiLayer.addChild(scoreText);
			
			resetGame();
			startGame();
		}
		
		private function resetGame():void
		{
			score = 0;
			time = 0;
			doodle.vVelocity = 0;
			doodle.hVelocity = 0;
			
			charLayer.addChild(doodle);
			doodle.x = stage.stageWidth / 2;
			doodle.y = stage.stageHeight - 100;
			
			stageStickArr = new Vector.<Stick>;
			stageStickArr.push(new NormalStick());
			
			sceneLayer.addChild(stageStickArr[0]);
			stageStickArr[0].x = stage.stageWidth / 2;
			stageStickArr[0].y = stage.stageHeight - 30;
		
			//addSticks();
		}
		
		private function startGame():void
		{
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			keyDictionary[e.keyCode] = false;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			keyDictionary[e.keyCode] = true;
		}
		
		private function onEnterFrame(e:Event):void
		{
			time += 1 / stage.frameRate;
			if (keyDictionary[Keyboard.LEFT])
				doodle.hVelocity -= 4;
			if (keyDictionary[Keyboard.RIGHT])
				doodle.hVelocity += 4;
			
			doodle.x += doodle.hVelocity;
			if (doodle.y <= stage.stageHeight - S - 35 && doodle.vVelocity < 0)
			{
				for each (var stick:Stick in stageStickArr)
					stick.y -= doodle.vVelocity;
				score -= doodle.vVelocity;
				scoreText.text = String(score);
			}
			
			else
			{
				doodle.y += doodle.vVelocity;
				if (doodle.vVelocity > 0)
					for each (stick in stageStickArr)
						if (doodle.legs.hitTestObject(stick))
							doodle.vVelocity = V0;
			}
			
			for each (stick in stageStickArr)
			{
				if (stick is MovingStick)
				{
					MovingStick(stick).x += MovingStick(stick).hVelocity;
					if (MovingStick(stick).x > MovingStick(stick).x2 && MovingStick(stick).hVelocity > 0)
						MovingStick(stick).hVelocity *= -1;
					if (MovingStick(stick).x < MovingStick(stick).x1 && MovingStick(stick).hVelocity < 0)
						MovingStick(stick).hVelocity *= -1;
				}
			}
			
			refreashSticks();
			
			doodle.vVelocity += GRAVITY;
			doodle.hVelocity *= 0.5;
			
			if (doodle.x > stage.stageWidth + 25)
				doodle.x -= stage.stageWidth + 25;
			if (doodle.x < -25)
				doodle.x += stage.stageWidth + 25;
			
			if (doodle.hVelocity > 0)
				doodle.setDirection("right")
			else if (doodle.hVelocity < 0)
				doodle.setDirection("left");
		
		}
		
		private function refreashSticks():void
		{
			var stick:Stick;
			
			while (stageStickArr[0].y > stage.stageHeight)
			{
				sceneLayer.removeChild(stageStickArr[0]);
				stick = stageStickArr.shift();
				if (stick is NormalStick)
					normalStickArr.push(stick);
				else if (stick is MovingStick)
					movingStickArr.push(stick);
			}
			
			while (stageStickArr[stageStickArr.length - 1].y > -100)
			{
				stick = getNewStick();
				stick.x = Math.random() * (stage.stageWidth - stick.width) + stick.width / 2;
				stick.y = stageStickArr[stageStickArr.length - 1].y - (Math.random() * (S - 60) + 50);
				stageStickArr.push(stick);
				sceneLayer.addChild(stick);
			}
		}
		
		private function getVDistanceByTime():Number
		{
			var min:Number = score / 30;
			return (Math.random() * (S - 60) + 50);
		}
		
		public function getNewStick():Stick
		{
			if (Math.random() < 0.5)
			{
				if (normalStickArr.length)
					return normalStickArr.pop();
				return new NormalStick();
			}
			else
			{
				if (movingStickArr.length)
					return movingStickArr.pop();
				return new MovingStick();
			}
		}
	}
}

import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;

class Doodle extends Sprite
{
	public var body:Shape;
	public var legs:Shape;
	public var vVelocity:Number;
	public var hVelocity:Number;
	private var direction:String = "left";
	
	public function Doodle():void
	{
		body = new Shape();
		legs = new Shape();
		addChild(body);
		addChild(legs);
		hVelocity = 0;
		hVelocity = 0;
		
		with (body)
		{
			graphics.lineStyle(1);
			graphics.moveTo(-25, -4);
			graphics.lineTo(-15, -4);
			graphics.cubicCurveTo(-10, -24, 10, -24, 15, -4);
			graphics.lineTo(15, 18);
			graphics.lineTo(-15, 18);
			graphics.lineTo(-15, 2);
			graphics.lineTo(-25, 2);
			graphics.drawEllipse(-30, -5, 5, 8);
			graphics.drawCircle(-10, -6, 1);
			graphics.drawCircle(-4, -6, 1);
			drawLine(-15, 5, 15, 5);
			drawLine(-15, 10, 15, 10);
			drawLine(-15, 15, 15, 15);
			drawLine(-15, 5, 15, 5);
			
		}
		
		with (legs)
		{
			drawLine(-10, 18, -10, 20);
			drawLine(-2, 18, -2, 20);
			drawLine(4, 18, 4, 20);
			drawLine(12, 18, 12, 20);
			drawLine(-10, 20, -15, 20);
			drawLine(-2, 20, -7, 20);
			drawLine(4, 20, -1, 20);
			drawLine(12, 20, 7, 20);
			graphics.drawRect(-15, 18, 30, 2);
		}
	}
	
	public function setDirection(direction:String):void
	{
		if (direction == "right")
			this.scaleX = -1;
		else
			this.scaleX = 1;
	}
	
	private function drawLine(x1:Number, y1:Number, x2:Number, y2:Number):void
	{
		graphics.lineStyle(1);
		graphics.moveTo(x1, y1);
		graphics.lineTo(x2, y2);
	}
}

class Stick extends Shape
{
	public function Stick():void
	{
		graphics.lineStyle(1);
		graphics.drawRoundRect(-25, -25, 50, 10, 10);
	}
}

class NormalStick extends Stick
{
	public function NormalStick():void
	{
		graphics.beginFill(0x6BB600);
		graphics.drawRoundRect(-25, -25, 50, 10, 10);
		graphics.endFill();
	}
}

class MovingStick extends Stick
{
	public const RIGHT:Boolean = true;
	public const LEFT:Boolean = false;
	public var hVelocity:Number
	
	private var _x1:Number;
	private var _x2:Number;
	
	public function MovingStick():void
	{
		graphics.beginFill(0x000066);
		graphics.drawRoundRect(-25, -25, 50, 10, 10);
		graphics.endFill();
		_x1 = Math.random() * (Main.stageWidth - width) + width / 2;
		_x2 = Math.min(Math.random() * (Main.stageWidth - width)+ width + _x1, Main.stageWidth - width / 2)
		hVelocity = Math.random() > 0.5 ? 4 : -4;
	}
	
	public function get x1():Number
	{
		return _x1;
	}
	
	public function get x2():Number
	{
		return _x2;
	}

}

class BrokenStick extends Stick
{

}

class GlassStick extends Stick
{

}
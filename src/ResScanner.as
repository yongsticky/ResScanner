package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	import starling.core.Starling;
	
	import client.Scanner;
	
	
	
	public class ResScanner extends Sprite
	{
		private var _starling:Starling = null;
		
		public function ResScanner()
		{
			stage ? initialize():addEventListener(Event.ADDED_TO_STAGE, function (event:Event) : void {
				event.target.removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
				initialize();
			});
		}
		
		private function initialize() : void
		{
			_starling = new Starling(Scanner, stage);
			_starling.start();
			
			//_starling.showStats = true;
			//_starling.antiAliasing = 2;
		}
	}
}
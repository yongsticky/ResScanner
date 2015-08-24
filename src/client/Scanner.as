package client
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	

	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	

	public class Scanner extends Sprite
	{
		/** Tells this class to use a <code>Loader</code> object to load the item.*/
		public static const TYPE_IMAGE : String = "image";
		/** Tells this class to use a <code>Loader</code> object to load the item.*/
		public static const TYPE_MOVIECLIP : String = "movieclip";
		
		/** Tells this class to use a <code>Sound</code> object to load the item.*/
		public static const TYPE_SOUND : String = "sound";
		/** Tells this class to use a <code>URLRequest</code> object to load the item.*/
		public static const TYPE_TEXT : String = "text";
		/** Tells this class to use a <code>XML</code> object to load the item.*/
		public static const TYPE_XML : String = "xml";
		/** Tells this class to use a <code>NetStream</code> object to load the item.*/
		public static const TYPE_VIDEO : String = "video";
		
		
		public static var IMAGE_EXTENSIONS : Array = [ "jpg", "jpeg", "gif", "png"];
		
		public static var MOVIECLIP_EXTENSIONS : Array = ['swf'];
		/** List of file extensions that will be automagically treated as text for loading.
		 *   Availabe types: txt, js, xml, php, asp .
		 */
		public static var TEXT_EXTENSIONS : Array = ["txt", "js", "php", "asp", "py" ];
		/** List of file extensions that will be automagically treated as video for loading.
		 *  Availabe types: flv, f4v, f4p.
		 */
		public static var VIDEO_EXTENSIONS : Array = ["flv", "f4v", "f4p", "mp4"];
		/** List of file extensions that will be automagically treated as sound for loading.
		 *  Availabe types: mp3, f4a, f4b.
		 */
		public static var SOUND_EXTENSIONS : Array = ["mp3", "f4a", "f4b"];
		
		public static var XML_EXTENSIONS : Array = ["xml"];
		
		
		
		[Embed(source="../../resource/btn.jpg")]
		private static const ButtonBkgTexture:Class;
		
		private var _btn:Button;
		
		private var _text:String = null;
		
		public function Scanner()
		{
			stage ? initialize():addEventListener(starling.events.Event.ADDED_TO_STAGE, function (event:starling.events.Event) : void {
				event.target.removeEventListener(starling.events.Event.ADDED_TO_STAGE, arguments.callee);
				initialize();
			});			
		}
		
		private function initialize() : void
		{			
			var texture:Texture = Texture.fromBitmap(new ButtonBkgTexture());			
			_btn = new Button(texture, "选择资源目录");	
			
			_btn.width = 322;
			_btn.height = 116;
			
			_btn.x = (stage.stageWidth - _btn.width) >> 1;
			_btn.y = (stage.stageHeight - _btn.height) >> 1;
			
			addChild(_btn);
			
			_btn.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function scanDir2Object(f:File, o:Object) : void
		{
			if (!f || !o)
			{
				return;
			}			
			
			var arr:Array = f.getDirectoryListing();
			
			for each(var item:File in arr)
			{
				if (item.isDirectory)
				{
					var scene:Object = {};
					scene["server"] = "http://s1.download.camu.com";
					scene["preload"] = 0;
					
					o[item.name] = scene;
					
					scanDir2Object(item, scene);
				}
				else
				{
					if (!o.hasOwnProperty("reslist"))
					{
						o["reslist"] = new Array();
					}
					
					var swf:Object = {};
					
					swf["id"] = item.name;
					swf["weight"] = item.size;
					swf["type"] = guessType(item.extension);
					swf["path"] = "/" + item.name;
					
					o["reslist"].push(swf);					
				}
			}
		}
		
		protected function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_btn);
			if (touch)
			{
				if (touch.phase == TouchPhase.ENDED)
				{
					var f:File = new File();
					f.browseForDirectory("请选择资源目录：");
					f.addEventListener(flash.events.Event.SELECT, onSelect);
				}
			}
		}
		
		protected function onSelect(event:flash.events.Event):void
		{
			var f:File = event.target as File;
			if (f)
			{
				if (_text == null)
				{
					var o:Object = {};
					scanDir2Object(f, o);
						
					_text = JSON.stringify(o);
					//trace(_text);
					
					f.browseForSave("请选择JSON文件保存到：");
				}
				else
				{
					var fs:FileStream = new FileStream();
					fs.open(f, FileMode.WRITE);
					fs.writeUTFBytes(_text);					
					fs.close();
					
					_text = null;
				}				
			}		
			
		}
		
		protected function guessType(extension:String) : String
		{
			var type:String = null;
			if(IMAGE_EXTENSIONS.indexOf(extension) > -1)
			{
				type = TYPE_IMAGE;
			}
			else if (SOUND_EXTENSIONS.indexOf(extension) > -1)
			{
				type = TYPE_SOUND;
			}
			else if (VIDEO_EXTENSIONS.indexOf(extension) > -1)
			{
				type = TYPE_VIDEO;
			}
			else if (XML_EXTENSIONS.indexOf(extension) > -1)
			{
				type = TYPE_XML;
			}
			else if (MOVIECLIP_EXTENSIONS.indexOf(extension) > -1)
			{
				type = TYPE_MOVIECLIP;
			}
			else
			{
				type = TYPE_TEXT;
			}
			
			return type;
		}
	}
}
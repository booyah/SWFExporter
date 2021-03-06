package
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.data.SWFRectangle;
	import com.codeazur.as3swf.exporters.JSONShapeExporter;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineShape;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class SWFConverter extends EventDispatcher
	{
		protected var _inputPath:File;
		protected var _outputPath:File;
		
		private var _currentFile:File;
		private var _currentIndex:uint;
		private var _queue:Array;
				
		public function SWFConverter(inputPath:File, outputPath:File)
		{
			_inputPath = inputPath;
			_outputPath = outputPath;
			_currentIndex = 0;
			enqueueFilesAtPath(_inputPath);
		}
				
		public function currentFile():String
		{
			return basename(_currentFile);
		}
		
		public function export():void
		{
			process();
		}
		
		public function setFiles(files:Array):void
		{
			_queue = new Array();
			enqueueFiles(files);
		}
		
		private function enqueueFiles(files:Array):void
		{
			// queue already exists
			if ( _queue && (_queue.length > 0) ) return;
			
			// clear queue
			_queue = new Array();
			
			for ( var i:uint = 0; i < files.length; i++ )
			{
				var currentFile:File = files[i];
				if ( extension(currentFile).toLowerCase() != "swf" )
				{
					// filter out non-SWF files
					continue;
				}
				
				_queue.push(currentFile)
			}
		}
		
		private function enqueueFilesAtPath(path:File):void
		{
			if ( !path ) return;
			
			var files:Array = path.getDirectoryListing();
			enqueueFiles(files);
		}
		
		private function process():void
		{
			var didFinish:Boolean = false;
			var progress:Event;
			
			if ( _currentIndex < _queue.length )
			{
				exportSWF(_queue[_currentIndex]);
				progress = new ProgressEvent(ProgressEvent.PROGRESS, false, false, Number(_currentIndex), Number(_queue.length));
			} else {
				progress = new ProgressEvent(ProgressEvent.PROGRESS, false, false, Number(_queue.length), Number(_queue.length));
				didFinish = true;
			}
			
			dispatchEvent(progress);
			
			if ( didFinish )
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function exportSWF(swfFile:File):void
		{
			_currentFile = swfFile;

			var request:URLRequest = new URLRequest(_currentFile.url);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, completeHandlerJSON);
			loader.load(request);
		}
				
		private function completeHandlerJSON(e:Event):void {
			var swf:SWF = new SWF(URLLoader(e.target).data as ByteArray);
			
			var shapes:Array = new Array();
			for (var i:uint = 0; i < swf.tags.length; i++) {
				var tag:ITag = swf.tags[i];
				if ( tag && tag is TagDefineShape ) {
					if ( tag == null ) continue;
					var defineShape:TagDefineShape = tag as TagDefineShape;
					var docHandler:JSONShapeExporter = new JSONShapeExporter(swf, defineShape);
					
					// Normally, we want the program to barf on corrupt shapes
					// To handle this case, and reflect it in the output
					// uncomment this line:
					// if ( !defineShape || !defineShape.shapes ) continue;
					
					defineShape.export(docHandler);
					var shapeJSON:String = docHandler.js;
					if ( shapeJSON.length > 0 ) {
						shapes.push(docHandler.js);
					}
				}
			}
			
			
			var name:String = basename(_currentFile);
			var graphicInfo:Array = ['"name": ' + '"' + name + '"'];
			
			var r:SWFRectangle = swf.frameSize;
			var w:Number = (Number(r.xmax) / 20 - Number(r.xmin) / 20);
			var h:Number = (Number(r.ymax) / 20 - Number(r.ymin) / 20);
			
			graphicInfo.push('"size": [' + w + ', ' + h + ']');
			
			if ( shapes.length > 0 )
			{
				graphicInfo.push('"shapes": [' + shapes.join("," + "\n") + ']');
			} else {
				graphicInfo.push('"shapes": []');
			}
			
			var js:String = '{ "graphic": {' + graphicInfo.join("," + "\n") + '} }';
			
			writeFile(js, "json");
			_currentIndex += 1;
			process();
		}
		
		private function basename(path:File):String
		{
			var lastSlash:int = path.nativePath.lastIndexOf(File.separator);				
			
			var filename:String = path.nativePath.substring(lastSlash + 1);
			var basename:String = filename.substring(0, filename.lastIndexOf("\."));
			return basename;
		}
		
		private function extension(path:File):String
		{
			var lastSlash:int = path.nativePath.lastIndexOf("\.");				
			
			var ext:String = path.nativePath.substring(lastSlash + 1);
			return ext;
		}
		
		private function writeFile(s:String, ext:String):void {			
			var lastSlash:int = _currentFile.nativePath.lastIndexOf(File.separator);				
			
			var filename:String = _currentFile.nativePath.substring(lastSlash + 1);
			var basename:String = filename.substring(0, filename.lastIndexOf("\."));
			
			var outputPath:File = new File(_outputPath.nativePath + File.separator + basename + "." + ext);
						
			var stream:FileStream = new FileStream();
			stream.open(outputPath, FileMode.WRITE);
			stream.writeUTFBytes(s);
			stream.close();
		}	
	}
}
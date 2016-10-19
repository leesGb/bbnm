package deltax.appframe 
{
    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DRenderMode;
    import flash.events.DataEvent;
    import flash.events.Event;
    import flash.net.URLLoaderDataFormat;
    import flash.system.Capabilities;
    import flash.system.System;
    import flash.utils.ByteArray;
    import flash.utils.getTimer;
    
    import mx.core.UIComponent;
    
    import deltax.delta;
    import deltax.common.Tick;
    import deltax.common.TickManager;
    import deltax.common.Util;
    import deltax.common.StartUpParams.StartUpParams;
    import deltax.common.error.Exception;
    import deltax.common.error.SingletonMultiCreateError;
    import deltax.common.localize.LocalizedFileMap;
    import deltax.common.log.LogLevel;
    import deltax.common.log.LogManager;
    import deltax.common.log.dtrace;
    import deltax.common.resource.Enviroment;
    import deltax.common.resource.FileRevisionManager;
    import deltax.common.respackage.ResSettingItem;
    import deltax.common.respackage.common.LoaderCommon;
    import deltax.common.respackage.loader.LoaderManager;
    import deltax.graphic.camera.Camera3D;
    import deltax.graphic.camera.DeltaXCamera3D;
    import deltax.graphic.camera.lenses.Orthographic2DLens;
    import deltax.graphic.event.Context3DEvent;
    import deltax.graphic.manager.DeltaXTextureManager;
    import deltax.graphic.manager.ResourceManager;
    import deltax.graphic.manager.ShaderManager;
    import deltax.graphic.manager.StepTimeManager;
    import deltax.graphic.manager.TextureMemoryManager;
    import deltax.graphic.manager.View3D;
    import deltax.graphic.render.DeltaXRenderer;
    import deltax.graphic.render2D.font.DeltaXFontRenderer;
    import deltax.graphic.render2D.rect.DeltaXRectRenderer;
    import deltax.gui.component.event.DXWndEvent;
    import deltax.gui.component.event.DXWndKeyEvent;
    import deltax.gui.component.event.DXWndMouseEvent;
    import deltax.gui.manager.GUIManager;
    import deltax.gui.manager.GUIRoot;

    public class BaseApplication extends GUIRoot
	{
        private static const DIRECTORY_FILE:String = "directory.xml";
        private static const SCENELISTXML:String = "scene_list.xml";
        private static const DEFAULT_STAGE_WIDTH:Number = 800;
        private static const DEFAULT_STAGE_HEIGHT:Number = 600;
        private static const DEFAULT_ANTIALIAS:Number = 1;
        private static const APPCONFIGXML:String = "app_config.xml";
        private static const DEFAULT_CAMERA_MOV_SPEED:Number = 10;
        public static const DATA_EVENT_COPY:String = "deltax_StringCopy";

        private static var ms_appInstance:BaseApplication;

        private var m_directoryConfigPath:String;
        private var m_cameraControllerClass:Class;
        private var m_loaderUrlPath:String;
        public var totalText:String = "";
        private var m_tickManager:TickManager;
        private var m_lastUpdateTime:uint;
        private var m_curFrameCount:uint;
        private var m_config:AppConfig;
        private var m_view3D:View3D;
        private var m_debugMode:Boolean;
        private var m_debugUI:Boolean;
        protected var m_started:Boolean;
        private var m_dependencies:int;
        private var m_enableStepLoad:Boolean = true;

        public function BaseApplication(_arg1:String="etc/", _arg2:Class=null)
		{
            if (ms_appInstance)
			{
                throw (new SingletonMultiCreateError(BaseApplication));
            }
            addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
            ms_appInstance = this;
            this.m_cameraControllerClass = _arg2;
            this.addEventListener(DATA_EVENT_COPY, this.onCopyRequest, false, 0, true);
			this.m_loaderUrlPath = "";
            this.m_directoryConfigPath = (this.m_loaderUrlPath + _arg1);
        }
		
        public static function get instance():BaseApplication
		{
            return (ms_appInstance);
        }
        public function get contextInfo():String
		{
            return ((this.context3D) ? this.context3D.driverInfo : "unknown");
        }
		
        protected function onCopyRequest(_arg1:DataEvent):void
		{
            Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _arg1.data, false);
        }
		
        protected function onAddedToStage(_arg1:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false);
            var versionPostfix:* = null;
            var onDirectoryFileLoaded:* = null;
            var event:* = _arg1;
            onDirectoryFileLoaded = function (_arg1:Object):void
			{
                var param:* = _arg1;
                var checkPathAndAppendLoaderPath:* = function (_arg1:String):String
				{
                    if ((((_arg1.indexOf(":") >= 0)) || ((_arg1.charAt(0) == "/"))))
					{
                        return (_arg1);
                    }
                    return ((m_loaderUrlPath + _arg1));
                }
                var directoryXml:* = XML(param.data);
				
				Enviroment.ResourceRootPath = Util.makeGammaString(Global.rootURL + "assets\\data\\");
				Enviroment.ConfigRootPath = Util.makeGammaString(Global.rootURL+"assets\\config\\");
                Enviroment.CurLanguage = directoryXml.@Language;
                Enviroment.LanguageRelativeDir = (((directoryXml.@LanguageDir + "/") + Enviroment.CurLanguage) + "/");
                Enviroment.ResourceRootPath = checkPathAndAppendLoaderPath(Enviroment.ResourceRootPath);
                Enviroment.ConfigRootPath = checkPathAndAppendLoaderPath(Enviroment.ConfigRootPath);
                m_tickManager = new TickManager();
                m_lastUpdateTime = getTimer();
                addEventListener(Event.ENTER_FRAME, onEnterFrame);
                var rootWnd:* = GUIManager.instance.rootWnd;
                rootWnd.addEventListener(DXWndEvent.RESIZED, onStageResize);
                rootWnd.addEventListener(DXWndKeyEvent.KEY_UP, onKeyUp);
                rootWnd.addEventListener(DXWndKeyEvent.KEY_DOWN, onKeyDown);
                rootWnd.addEventListener(DXWndMouseEvent.MOUSE_DOWN, onMouseDown);
                rootWnd.addEventListener(DXWndMouseEvent.MOUSE_UP, onMouseUp);
                rootWnd.addEventListener(DXWndMouseEvent.MOUSE_MOVE, onMouseMove);
                rootWnd.addEventListener(DXWndMouseEvent.MOUSE_WHEEL, onMouseWheel);
                rootWnd.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
                rootWnd.addEventListener(DXWndMouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
                onPackedResLoadedOrNoPack();
            };
				
            var onPackedResLoadedOrNoPack:* = function ():void
			{
                var onAppConfigLoaded:* = null;
                var languageFileUrl:* = null;
                var combindedVersionPostFix:* = null;
                onAppConfigLoaded = function (_arg1:Object):void
				{
                    m_config = new AppConfig();
                    m_config.load(XML(_arg1.data));
                    stage.frameRate = m_config.frameRate;
                    m_view3D.width = rootUIComponent.width;
                    m_view3D.height = rootUIComponent.height;
                    m_view3D.antiAlias = m_config.antialias;
                    LogManager.instance.enable = ((m_config.logEnable) || (Capabilities.isDebugger));
                    LogManager.instance.recordLogLevel = m_config.logLevel;
                    GUIManager.instance.setDefaultTooltipRes("gui/cfg/tip/defaultTips.gui");
                    LoaderManager.getInstance().startSerialLoad();
                    m_started = true;
                    onStarted();
                };
				
                if (!LocalizedFileMap.loaded)
				{
                    var onLanguageMapLoaded:* = function (_arg1:Object):void
					{
                        var _local2:ResSettingItem;
                        var _local3:ByteArray;
                        if (!developVersion)
						{
                            _local2 = new ResSettingItem();
                            _local2.makeEmptyState();
                            _local2.unpackAllFiles((_arg1.data as ByteArray));
                            _local3 = (_local2.getFile("language_files_xml") as ByteArray);
                            LocalizedFileMap.load(XML(_local3));
                        } else 
						{
                            LocalizedFileMap.load(XML(_arg1.data));
                        }
                    }
					
                    languageFileUrl = m_loaderUrlPath;
                    if (developVersion)
					{
                        languageFileUrl = (languageFileUrl + ("language_files.xml" + versionPostfix));
                    } else 
					{
                        combindedVersionPostFix = FileRevisionManager.instance.getRevisionByPathType(FileRevisionManager.REVISION_FILE_CONFIG).toString();
                        combindedVersionPostFix = (combindedVersionPostFix + ("_" + FileRevisionManager.instance.getRevisionByPathType(FileRevisionManager.REVISION_FILE_DATA)));
                        languageFileUrl = (languageFileUrl + (("language_files_" + combindedVersionPostFix) + ".swf"));
                    }
                    LoaderManager.getInstance().load(languageFileUrl, {onComplete:onLanguageMapLoaded}, LoaderCommon.LOADER_URL, false, {dataFormat:(developVersion) ? URLLoaderDataFormat.TEXT : URLLoaderDataFormat.BINARY});
                }
                LoaderManager.getInstance().load(((m_directoryConfigPath + APPCONFIGXML) + versionPostfix), {onComplete:onAppConfigLoaded}, LoaderCommon.LOADER_URL, false, {dataFormat:URLLoaderDataFormat.TEXT});
            }
			
            super.init(stage);
            this.registerResourceTypes();
//            this.registerSyncDataPools();
//            this.registerPools();
            this.initView3D(this.m_cameraControllerClass);
            XML.ignoreComments = true;
            versionPostfix = "";//(this.developVersion) ? FileRevisionManager.randomUrlPostFix : ("?v=" + FileRevisionManager.instance.projectVersion.toString());
            LoaderManager.getInstance().load(((this.m_directoryConfigPath + DIRECTORY_FILE) + versionPostfix), {onComplete:onDirectoryFileLoaded}, LoaderCommon.LOADER_URL, false, {dataFormat:URLLoaderDataFormat.TEXT});
        }
		
        protected function registerResourceTypes():void
		{
            ResourceManager.instance.registerGraphicResources();
        }
		
        protected function onSceneManagerCreated():void
		{
			
        }
        public function get developVersion():Boolean
		{
            return (StartUpParams.developVersion);
        }
		
		
        protected function onStarted():void
		{
			
        }
        public function get designerConfigPath():String
		{
            return (Enviroment.ConfigRootPath);
        }
        public function get rootResourcePath():String
		{
            return (Enviroment.ResourceRootPath);
        }
        public function dispose():void
		{
            removeEventListener(Event.ENTER_FRAME, this.updateFrame);
            this.m_tickManager.dispose();
            this.m_tickManager = null;
            this.m_view3D.dispose();
        }
        public function get context3D():Context3D
		{
            return (this.m_view3D.renderer.delta::stage3DProxy.context3D);
        }
        private function onEnterFrame(_arg1:Event):void
		{
            var event:* = _arg1;
            if (Exception.throwError)
			{
                this.updateFrame();
            } else 
			{
                try 
				{
                    this.updateFrame();
                } catch(e:Error) 
				{
                    dtrace(LogLevel.FATAL, e.message, e.getStackTrace());
                    m_view3D.renderer.resetContextManually(Context3DRenderMode.AUTO);
                }
            }
        }
		
        protected function updateFrame():void
		{
            var _local1:uint = getTimer();
            var _local2:uint = (_local1 - this.m_lastUpdateTime);
            if (!this.m_started)
			{
                return;
            }
			
            this.m_tickManager.delta::update(_local2);
            var _local3:Context3D = this.context3D;
            if (!_local3)
			{
                return;
            }
			
            if (!this.m_view3D.renderer.clear())
			{
                return;
            }
            this.m_curFrameCount++;
            DeltaXFontRenderer.Instance.setViewPort(this.view.width, this.view.height);
            DeltaXRectRenderer.Instance.setViewPort(this.view.width, this.view.height);
            StepTimeManager.instance.onFrameUpdated();
            DeltaXTextureManager.instance.onFrameUpdated(this.context3D);
//            MaterialManager.Instance.checkUsage();
//            this.m_fpsCounter.onFrameUpdate(_local1);
            TextureMemoryManager.Instance.check();
            ResourceManager.instance.parseDataInCommon();
//            if (this.curLogicScene)
//			{
//                this.curLogicScene.updateLogicObject(_local1);
//            }
//            if (this.m_camController)
//			{
//                this.m_camController.updateCamera();
//            }
//            this.m_view3D.render();
            var _local4:Camera3D = this.m_view3D.camera2D;
            var _local5:Orthographic2DLens = Orthographic2DLens(_local4.lens);
            if (int(_local5.width) != int(this.m_view3D.width))
			{
                _local5.width = this.m_view3D.width;
            }
            if (int(_local5.height) != int(this.m_view3D.height))
			{
                _local5.height = this.m_view3D.height;
            }
            ShaderManager.instance.resetCameraState(_local4);
            GUIManager.instance.render(_local3, this.m_debugUI);
            this.m_view3D.renderer.present();
//            this.onPostRender(_local3, (this.view.camera as DeltaXCamera3D));
//            DownloadStatistic.instance.updateStatistic(_local1);
//            if (this.m_debugHUD)
//			{
//                this.m_debugHUD.updateFrame();
//            };
//            EffectManager.instance.clearCurRenderingEffect();
//            this.onFrameUpdated(_local2);
            this.m_lastUpdateTime = _local1;
//            if (stage.frameRate > 60){
//                if ((stage.frameRate & 1)){
//                    stage.frameRate = (stage.frameRate + 1);
//                } else {
//                    stage.frameRate = (stage.frameRate - 1);
//                };
//            };
        }
        protected function onFrameUpdated(_arg1:uint):void
		{
        }
		
        private function initView3D(_arg1:Class):void
		{
            var _local2:DeltaXRenderer = new DeltaXRenderer(DEFAULT_ANTIALIAS);
            _local2.swapBackBuffer = false;
            this.m_view3D = new View3D(new DeltaXCamera3D(),_local2);
            _local2.addEventListener(Context3DEvent.CONTEXT_LOST, this.onContextLost, false, 0, true);
            _local2.addEventListener(Context3DEvent.CREATED_HARDWARE, this.onContextCreatedHardware, false, 0, true);
            _local2.addEventListener(Context3DEvent.CREATED_SOFTWARE, this.onContextCreatedSoftware, false, 0, true);
            _local2.view3D = this.m_view3D;
            this.m_view3D.width = rootUIComponent.width;
            this.m_view3D.height = rootUIComponent.height;
            this.m_view3D.antiAlias = DEFAULT_ANTIALIAS;
			m_view3D.x = m_rootUIComponent.x;
			m_view3D.y = m_rootUIComponent.y;
			addChild(this.m_view3D);
        }
        protected function onContextLost(_arg1:Context3DEvent):void
		{
        }
        protected function onContextCreatedSoftware(_arg1:Context3DEvent):void
		{
        }
        protected function onContextCreatedHardware(_arg1:Context3DEvent):void
		{
        }
        public function get view():View3D
		{
            return (this.m_view3D);
        }
//        public function createRenderScene(_arg1:uint, _arg2:SceneGrid, _arg3:Function=null):RenderScene{
//            return (this.m_sceneManager.createRenderScene(_arg1, _arg2, _arg3));
//        }
//        public function get curLogicScene():LogicScene{
//            return (this.m_sceneManager.curLogicScene);
//        }
        protected function onKeyDown(_arg1:DXWndKeyEvent):void
		{
        }
        protected function onKeyUp(_arg1:DXWndKeyEvent):void
		{
        }
        protected function onStageResize(_arg1:DXWndEvent):void
		{
            this.m_view3D.width = rootUIComponent.width;
            this.m_view3D.height = rootUIComponent.height;
        }
        protected function onMouseDown(_arg1:DXWndMouseEvent):void
		{
        }
        protected function onMouseUp(_arg1:DXWndMouseEvent):void
		{
        }
        protected function onMouseMove(_arg1:DXWndMouseEvent):void
		{
        }
        protected function onMouseWheel(_arg1:DXWndMouseEvent):void
		{
        }
        protected function onRightMouseDown(_arg1:DXWndMouseEvent):void
		{
        }
        protected function onRightMouseUp(_arg1:DXWndMouseEvent):void
		{
        }
//        protected function registerClass(_arg1:Class, _arg2:uint, _arg3:uint, _arg4:uint):void
//		{
//            ObjectClassID.init();
//            if (_arg3 == ObjectClassID.DIRECTOR_CLASS_ID){
//                ObjectClassID.ShellDirectorClassID = _arg2;
//            };
//            ObjectClassID.registerShellClass(_arg1, _arg2, _arg3);
//        }
//        protected function set shellSceneClass(_arg1:Class):void{
//            this.m_sceneManager.shellLogicSceneType = _arg1;
//        }
        public function get config():AppConfig{
            return (this.m_config);
        }
        public function forceGC():void{
            System.gc();
        }
        public function addTick(_arg1:Tick, _arg2:uint):void{
            if (_arg1.isRegistered){
                this.m_tickManager.delTick(_arg1);
            };
            this.m_tickManager.addTick(_arg1, _arg2);
        }
        public function removeTick(_arg1:Tick):void{
            this.m_tickManager.delTick(_arg1);
        }
        public function get enableStepLoad():Boolean{
            return (this.m_enableStepLoad);
        }
        public function set enableStepLoad(_arg1:Boolean):void{
            this.m_enableStepLoad = _arg1;
        }
//        public function get fpsCounter():FPSCounter{
//            return (this.m_fpsCounter);
//        }
//        public function playSound(_arg1:String):void{
//            var onSoundLoaded:* = null;
//            var url:* = _arg1;
//            onSoundLoaded = function (_arg1:IResource, _arg2:Boolean):void{
//                var _local3:SoundTransform;
//                if (_arg2){
//                    _local3 = new SoundTransform(EffectManager.instance.soundEffectVolume);
//                    SoundResource(_arg1).play(0, 0, _local3);
//                };
//                _arg1.release();
//            };
//            if (!EffectManager.instance.soundEffectEnable){
//                return;
//            };
//            url = FileRevisionManager.instance.getVersionedURL(url);
//            ResourceManager.instance.getResource(url, ResourceType.SOUND, onSoundLoaded);
//        }
//        public function isRenderObjectAllowCameraShakeEffect(_arg1:RenderObject):Boolean{
//            if (!DirectorObject.delta::m_onlyOneDirector){
//                return (false);
//            };
//            return ((_arg1 == DirectorObject.delta::m_onlyOneDirector.renderObject));
//        }
//        public function reloadWebPage():void{
//            try {
//                if (ExternalInterface.available){
//                    ExternalInterface.call("window.location.reload()");
//                };
//            } catch(e:Error) {
//                dtrace(LogLevel.INFORMATIVE, e.message);
//            };
//        }
		
		private var m_rootUIComponent:UIComponent;
		public function set rootUIComponent(value:UIComponent):void{
			m_rootUIComponent = value;
		}
		public function get rootUIComponent():UIComponent{
			return this.m_rootUIComponent;
		}
    }
}

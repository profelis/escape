package deep.h3d;
import h3d.Engine;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class SharedEngine extends Engine
{

	public function new( width = 0, height = 0, hardware = true, aa = 0, stageIndex = 0 ) {
		super(width, height, hardware, aa, stageIndex);
		autoResize = false;
	}
	
	override public function init() 
	{
		throw "use initContext() for shared context";
		//super.init();
	}
	
	public function initContext() {
		onCreate(null);
	}
	
	override public function begin() {
		if( ctx == null || ctx.driverInfo == "Disposed" )
			return false;
		//ctx.clear( ((backgroundColor>>16)&0xFF)/255 , ((backgroundColor>>8)&0xFF)/255, (backgroundColor&0xFF)/255, ((backgroundColor>>>24)&0xFF)/255);
		// init
		frameCount++;
		drawTriangles = 0;
		shaderSwitches = 0;
		drawCalls = 0;
		curMatBits = -1;
		curShader = null;
		curBuffer = null;
		curMultiBuffer = null;
		curProjMatrix = null;
		curTextures = [];
		curSamplerBits = [];
		return true;
	}
	
	override public function end() {
		//ctx.present();
		reset();
		curProjMatrix = null;
	}
	
}
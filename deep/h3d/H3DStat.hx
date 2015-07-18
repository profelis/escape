package deep.h3d;

import h2d.css.Fill;
import h2d.Font;
import h2d.Scene;
import h2d.Sprite;
import h2d.Text;
import h3d.Engine;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class H3DStat extends Sprite
{
	var bg:Fill;
	var stat:Text;
	
	public function new(?parent:Sprite) 
	{
		super(parent);
		bg = new Fill(this);
		
		stat = new Text(new Font("Tahoma", 10), this);
		stat.textColor = 0xFF000000;
		stat.x = 2;
		stat.y = 2;
	}
	
	public var w(default, null):Int = 0;
	public var h(default, null):Int = 0;
	
	@:access(h2d.Text)
	public function update() {
		var c = Engine.getCurrent();
		var memStat = c.mem.stats();
		
		var ntext = "drw: " + c.drawCalls + "\n" +
			"tri: " + c.drawTriangles + "\n" +
			"tex: " + memStat.textureCount + "\n" +
			"buf: " + memStat.bufferCount;
			
			
		if (stat.text != ntext) stat.text = ntext;
		
		var size = stat.initGlyphs(stat.text, false);
		size.width += 4;
		size.height += 4;
		if (size.width != w || size.height != h) {
			w = size.width;
			h = size.height;
			bg.reset();
			bg.fillRectColor(0, 0, w, h, 0xFFFFFFFF);
		}
		
	}
	
}
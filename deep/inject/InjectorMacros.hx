package deep.inject;
#if macro
import haxe.macro.Context;
import haxe.macro.Printer;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
#end
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

class InjectorMacros 
{
	public macro static function build()
	{
		//trace("build " + updated);
		if (updated) return macro null;
		updated = true;
		
		Context.onGenerate(onGenerate);
		Context.registerModuleReuseCall("deep.inject.Injector", "deep.inject.InjectorMacros.build()");
		
		return macro null;
	}
	
	#if macro
	static var updated = false;
	
	static function onGenerate(types:Array<Type>)
	{
		//trace("generate");
		for (t in types)
		{
			switch (t)
			{
				case TInst(type, _):
					var rt = type.get();
					if (rt.isInterface || rt.isExtern) continue;
					var items = rt.fields.get();
					if (rt.constructor != null) items.push(rt.constructor.get());
					for (f in items) executeTypeRef(f);
				case _ :
			}
		}
		updated = false;
	}
	
	inline static function executeTypeRef(ref:ClassField)
	{
		if (ref.meta.has(Injector.INJECT))
		{	
			switch (ref.kind)
			{
				case FVar(_, write):
					var types = new Array<Expr>();
					parseType(ref.type, types, ref.pos);
					switch (write)
					{
						case AccNever:
							Context.error('can\'t inject, write accessor = never', ref.pos);
						case AccCall(_):
							ref.meta.add(Injector.INJECT_PROPERTY, types, ref.pos);
						default :
							ref.meta.add(Injector.INJECT_TYPE, types, ref.pos);
					}
					
				case FMethod(_):
					var resTypes = new Array<Expr>();
					var types = switch (ref.type) 
					{
						case TFun(res, _): res;
						default: throw "unsupported type " + ref.type;
					}
					
					if (types.length == 0)
						Context.error("method haven't arguments", ref.pos);
					
					for (p in types) parseType(p.t, resTypes, ref.pos, p.opt);
					
					ref.meta.add(Injector.INJECT_METHOD, resTypes, ref.pos);
			}
		}
	}
	
	static function parseType(t:Type, res:Array<Expr>, pos:Position, opt = false)
	{
		switch (t)
		{
			case TInst(type, _):
				var ct = type.get();
				ct.pack.push(ct.name);
				res.push(Context.parse("\"" + ct.pack.join(".") + "\"", pos));
				res.push(Context.parse(opt ? "1" : "0", pos));
				
			case TType(type, params) if (type.toString() == "Null"):
				parseType(params[0], res, pos, true);
			
			case TType(type, _):
				parseType(type.get().type, res, pos, opt);
				
			case _: Context.error("unsupported type " + Std.string(t), pos);
		}
	}
	#end
}
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Input;
import phoenix.BitmapFont;
import luxe.Text;
import luxe.Color;
import luxe.Debug;
import hxmath.math.Vector2;
import luxe.Vector;
import phoenix.Batcher;
import luxe.Log;
import luxe.debug.ProfilerDebugView;

class Main extends luxe.Game {

    var flow = false;
    var initiated = false;
    var textSize: Float;
    public static var solver = new Solver();

    //GUI Stuff
    var bFont:BitmapFont;
    var lbDelta:Text;
    var lbParticleCount:Text;
    var lbSpringCount:Text;
    var lbDC:Text;

    override function ready() {
        var json_asset = Luxe.loadJSON('assets/parcel.json');

        var preload = new Parcel();
            preload.from_json(json_asset.json);

        new ParcelProgress({
            parcel : preload,
            background: new Color(1,1,1,0.85),
            oncomplete: assets_loaded
        });
        textSize = Luxe.screen.h/20;
        preload.load();
    }

    function assets_loaded(_) {
        initGUI();
        Luxe.core.renderer.blend_mode(BlendMode.src_alpha,BlendMode.one);
        initiated = true;
    } //assets_loaded

    override function onkeyup( e:KeyEvent ) {
        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }
    }
    
    override function onmousemove( event:MouseEvent ) {
        solver.flowSrc = new Vector2(event.pos.x,event.pos.y);
    } //onmousemove

    override function update(dt:Float) {
        if (initiated) 
        {
            updateGUI(dt);
            solver.update(solver.fixedTimestep);
        }
    }

    function initGUI()
    {
        bFont = Luxe.resources.find_font('font');
        lbDelta = new Text({
            pos : new Vector(0,Luxe.screen.h-textSize),
            size : textSize, //pt
            align : TextAlign.left,
            font: bFont,
            text : 'deltatime: '
        });
        lbParticleCount = new Text({
            pos : new Vector(0,Luxe.screen.h-textSize*2),
            size : textSize, //pt
            align : TextAlign.left,
            font: bFont,
            text : 'particles: '
        });
        lbSpringCount = new Text({
            pos : new Vector(0,Luxe.screen.h-textSize*3),
            size : textSize, //pt
            align : TextAlign.left,
            font: bFont,
            text : 'springs: '
        });
        lbDC = new Text({
            pos : new Vector(0,textSize),
            size : textSize, //pt
            align : TextAlign.left,
            font: bFont,
            text : 'DC: '
        });
    }

    function updateGUI(dt:Float)
    {
        lbDelta.text = 'deltatime: '+dt;
        lbParticleCount.text = 'particles: '+solver.particles.length;
        lbSpringCount.text = 'springs: '+Lambda.count(solver.springsMap);
        lbDC.text = 'DC: '+Luxe.renderer.batcher.draw_calls+'\n';
    }

}
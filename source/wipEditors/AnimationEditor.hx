package wipEditors;

class AnimationEditor extends MusicBeatState{
    var boyfriend:Boyfriend;
    var dad:Character;
    var gf:Character;

    public function new(){
        super();
    }

    inline function getCharX(char:Character):Null<Float> {
        return (char != null) ? char.x : null;
    }

    inline function getCharY(char:Character):Null<Float> {
        return (char != null) ? char.y : null;
    }
}
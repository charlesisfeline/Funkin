package funkin.group;

import funkin.graphics.FunkinSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSort;
import funkin.util.SortUtil;
import flixel.math.FlxPoint;

/**
 * A FunkinGroup of FunkinSprites.
 */
typedef FunkinSpriteGroup = FunkinGroup<FunkinSprite>;

/**
 * FlxSpriteGroup but better. Kinda like if `FlxNestedSprite` and `FlxSpriteGroup` fucked and it was the best possible outcome.
 */
class FunkinGroup<T:FunkinSprite> extends FunkinSprite
{
  /**
   * The children of this FunkinGroup.
   */
  public var children:Null<Array<T>>;

  /**
   * The size of this FunkinGroup. Read only.
   */
  public var size(get, never):Int;

  function get_size():Int
  {
    return children.length;
  }

  /**
   * The max size of this FunkinGroup. 0 and below is infinite.
   */
  public var maxSize(default, set):Int = 0;

  function set_maxSize(value:Int):Int
  {
    if (value < 0) value = 0;

    maxSize = value;

    if (size > maxSize && maxSize > 0)
    {
      for (child in 0...size)
      {
        if (child > maxSize) abort(children[child]);
      }
    }

    return maxSize;
  }

  /**
   * The width of all the FunkinGroup's children's displays put together.
   *
   * Meant as a replacement of frameWidth.
   */
  public var trueWidth(get, null):Float = 0; // true...

  /**
   * The height of all the FunkinGroup's children's displays put together.
   *
   * Meant as a replacement of frameHeight.
   */
  public var trueHeight(get, null):Float = 0; // maybe false...?

  /**
   * If this is false, the FunkinGroup will update children normally. Otherwise,
   * it will not (obviously).
   *
   * Useful for outside objects to modify this group's children. (Extending
   * classes can just override updateChildren)
   *
   * `false` by default.
   */
  public var customChildUpdate:Bool = false;

  /**
   * Should this FunkinGroup treat itself more like one image (in scale terms).
   *
   * `true` by default.
   */
  public var preciseScale:Bool = true;

  /**
   * Should this FunkinGroup treat itself more like one image (in angle terms).
   *
   * `true` by default.
   */
  public var preciseAngle:Bool = true;

  override function get_width():Float
  {
    var leftMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (x + a.relativeX) - a.width, (x + b.relativeX) - b.width);
    }, false)[0];

    var rightMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (x + a.relativeX) + a.width, (x + b.relativeX) + b.width);
    }, false, FlxSort.DESCENDING)[0];

    return Math.abs(((x + rightMostSpr.relativeX) + rightMostSpr.width) - ((x + leftMostSpr.relativeX) - leftMostSpr.width));
  }

  override function get_height():Float
  {
    var downwardsMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (y + a.relativeY) + a.height, (y + b.relativeY) + b.height);
    }, false, FlxSort.DESCENDING)[0];

    var upwardsMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (y + a.relativeY) - a.height, (y + b.relativeY) - b.height);
    }, false)[0];

    return Math.abs(((y + downwardsMostSpr.relativeY) + downwardsMostSpr.height) - ((y + upwardsMostSpr.relativeY) - upwardsMostSpr.height));
  }

  // include scale with frame sizes for better accuracy

  function get_trueWidth():Float
  {
    var leftMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (x + a.relativeX) - (a.frameWidth * a.scale.x), (x + b.relativeX) - (b.frameWidth * a.scale.x));
    }, false)[0];

    var rightMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (x + a.relativeX) + (a.frameWidth * a.scale.x), (x + b.relativeX) + (b.frameWidth * a.scale.x));
    }, false, FlxSort.DESCENDING)[0];

    return Math.abs(((x + rightMostSpr.relativeX) + (rightMostSpr.frameWidth * rightMostSpr.scale.x))
      - ((x + leftMostSpr.relativeX) - (leftMostSpr.frameWidth * leftMostSpr.scale.x)));
  }

  function get_trueHeight():Float
  {
    var downwardsMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (y + a.relativeY) + (a.frameHeight * a.scale.y), (y + b.relativeY) + (b.frameHeight * a.scale.y));
    }, false, FlxSort.DESCENDING)[0];

    var upwardsMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (y + a.relativeY) - (a.frameHeight * a.scale.y), (y + b.relativeY) - (b.frameHeight * a.scale.y));
    }, false)[0];

    return Math.abs(((y + downwardsMostSpr.relativeY) + (downwardsMostSpr.frameHeight * downwardsMostSpr.scale.y))
      - ((y + upwardsMostSpr.relativeY) - (upwardsMostSpr.frameHeight * upwardsMostSpr.scale.y)));
  }

  public var center(get, null):FlxPoint;

  function get_center():FlxPoint
  {
    var upwardsMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (y + a.relativeY) - a.height, (y + b.relativeY) - b.height);
    }, false)[0];

    var leftMostSpr:T = sort(function(order:Int, a:T, b:T):Int {
      if (a == null || b == null) return 0;
      return FlxSort.byValues(order, (x + a.relativeX) - a.width, (x + b.relativeX) - b.width);
    }, false)[0];

    return new FlxPoint(((x + leftMostSpr.relativeX) - leftMostSpr.width) + width / 2, ((y + upwardsMostSpr.relativeY) - upwardsMostSpr.height) + height / 2);
  }

  /**
   * Constructor for FunkinGroup.
   *
   * @param X Starting X.
   * @param Y Starting Y.
   * @param maxSize Starting max size.
   * @param preciseScale Whether to treat the FunkinGroup like one image (with scale).
   * @param preciseAngle Whether to treat the FunkinGroup like one image (with angle).
   */
  public function new(?X:Float, ?Y:Float, ?maxSize:Int = 0, ?preciseScale:Bool, ?preciseAngle:Bool)
  {
    super(X, Y);

    children = [];

    this.maxSize = maxSize ?? 0;

    if (preciseScale != null) this.preciseScale = preciseScale;
    if (preciseAngle != null) this.preciseAngle = preciseAngle;
  }

  /**
   * Gets the child at an index.
   *
   * @param index The position.
   * @return The child or null.
   */
  @:arrayAccess
  public inline function getChildAt(index:Int):Null<T>
  {
    if (index < 0 || index >= size) return null;

    return children[index];
  }

  /**
   * Sets the child at an index.
   *
   * @param index The position.
   * @param replacement A new child to replace the old one.
   */
  @:arrayAccess
  public inline function setChildAt(index:Int, replacement:T):Void
  {
    if (index < 0 || index >= size) return;

    children[index] = replacement;
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    updateChildren();

    for (child in children)
    {
      if (child != null && child.exists && child.active) child.update(elapsed);
    }
  }

  override public function draw():Void
  {
    for (child in children)
    {
      if (child != null && child.exists && child.visible) child.draw();
    }
  }

  /**
   * Updates the children here. Uses the child's relative variables like `relativeX` and `relativeY` to update the child's position. Like `FlxNestedSprite`!
   * Can be overriden by outside classes with `customChildUpdate`.
   */
  public function updateChildren():Void
  {
    if (customChildUpdate) return;

    for (child in children)
    {
      if (child != null && child.exists && child.active)
      {
        // TODO: Maybe make variables that determines if we should use special math? i.e. change the child's angle AND position based on the parent's angle? Same for scale?
        child.angle = angle + child.relativeAngle;
        child.scale.x = scale.x * child.relativeScale.x;
        child.scale.y = scale.y * child.relativeScale.y;

        if (!preciseScale && !preciseAngle)
        {
          child.x = x + child.relativeX;
          child.y = y + child.relativeY;
        }
        else if (preciseScale && !preciseAngle)
        {
          child.x = center.x - (Math.abs(center.x - (x + child.relativeX)) * scale.x);
          child.y = center.y - (Math.abs(center.y - (y + child.relativeY)) * scale.y);
        }
        else if (!preciseScale && preciseAngle)
        {
          child.x = Math.cos((angle
            + (Math.atan((center.y - (y + child.relativeY)) / (center.x - (x + child.relativeX))) * (Math.PI / 180)))) * Math.sqrt((Std.int(center.x
              - (x + child.relativeX)) ^ 2)
              + (Std.int(center.y - (y + child.relativeY)) ^ 2)) * (180 / Math.PI);
          child.y = Math.sin((angle
            + (Math.atan((center.y - (y + child.relativeY)) / (center.x - (x + child.relativeX))) * (Math.PI / 180)))) * Math.sqrt((Std.int(center.x
              - (x + child.relativeX)) ^ 2)
              + (Std.int(center.y - (y + child.relativeY)) ^ 2)) * (180 / Math.PI);
        }
        else
        {
          child.x = center.x - (Math.abs(center.x - (x + child.relativeX)) * scale.x);
          child.y = center.y - (Math.abs(center.y - (y + child.relativeY)) * scale.y);
        }

        child.alpha = alpha * child.relativeAlpha;
        child.visible = visible && child.relativeVisible;
        // force child cameras to the group's cameras.
        if (child.cameras != cameras) child.cameras = cameras;
      }
    }
  }

  /**
   * Adopts a child into this FunkinGroup. Will also return said child for convenience.
   * Can't adopt if `size` is at `maxSize`, instead returning null.
   *
   * @param adoptedChild The child that the caller wants this FunkinGroup to adopt.
   * @return The same child or null.
   */
  public function adopt(adoptedChild:T):Null<T>
  {
    if (maxSize > 0 && size >= maxSize) return null;

    children.push(adoptedChild);
    return adoptedChild;
  }

  /**
   * Makes a child right in this FunkinGroup. Will also return said child for convenience.
   * Can't give birth if `size` is at `maxSize`, instead returning null.
   *
   * @return The same child or null.
   */
  public function birth():Null<T>
  {
    if (maxSize > 0 && size >= maxSize) return null;

    var baby:T = cast new FunkinSprite();
    children.push(baby);
    return baby;
  }

  /**
   * Adopts a child into this FunkinGroup at a given index. Will also return said child for convenience.
   *
   * @param adoptedChild The child that the caller wants this FunkinGroup to adopt.
   * @param index The position the caller wants the child to go in.
   * @return The same child or null.
   */
  public function insert(adoptedChild:T, index:Int):Null<T>
  {
    if (size < index) return null;
    children.insert(index, adoptedChild);
    return adoptedChild;
  }

  /**
   * Kidnaps select children from another FunkinGroup. Only works if both FunkinGroups contain the same type.
   *
   * @param grp The other group to take from.
   * @param children The children to take.
   */
  public function takeCustody(grp:FunkinGroup<T>, children:Array<T>):Void
  {
    for (child in children)
    {
      if (grp.children.contains(child))
      {
        grp.abandon(child);
        adopt(child);
        // update child's relative position so the child stays where it was
        child.relativeX = x - child.x;
        child.relativeY = y - child.y;
      }
    }
  }

  override public function destroy():Void
  {
    for (child in children)
    {
      child.destroy();
    }

    children = null;

    super.destroy();
  }

  /**
   * Abortion in Funkin' is beautiful. We can get rid of a child when needed.
   *
   * @param child The child that the caller wants to subject to their fate.
   */
  public function abort(child:T):Void
  {
    if (child == null) return;

    var index = children.indexOf(child);

    murder(child);

    if (index != -1) children.splice(index, 1);
  }

  /**
   * Abandoning a child is like abortion but instead of destroying the child
   * we remove it from this FunkinGroup's family and gives it to the caller.
   * The caller can then choose to migrate it somewhere else or dispose of it themself.
   *
   * @param child The child to abandon.
   * @return The abandoned child.
   */
  public function abandon(child:T):Null<T>
  {
    var index = children.indexOf(child);
    if (index != -1) children.splice(index, 1);

    return child;
  }

  /**
   * Murders a specified child, but doesn't remove it from the family.
   * Useful for reusing children.
   *
   * @param child The child to murder.
   */
  public function murder(child:T):Void
  {
    child.kill();
    child.destroy();
    child = null;
  }

  /**
   * Knocks a specified child out (aka calls kill on them).
   *
   * @param child The child to knock out.
   */
  public function knockOut(child:T):Void
  {
    child.kill();
  }

  /**
   * Applies a function to all children.
   *
   * @param func A function that modifies one child at a time.
   */
  public function forEach(func:T->Void):Void
  {
    for (child in children)
    {
      if (child != null)
      {
        func(child);
      }
    }
  }

  /**
   * Sorts the children of this FunkinGroup. Returns the sorted children
   *
   * @param func     The sorting function to use - you can use one of the premade ones in
   *                 `FlxSort` or write your own using `FlxSort.byValues()` as a "backend".
   * @param setGroup Whether to actually sort the children of this group,
   *                 so the caller can grab a sorted list without this group
   *                 actually sorting the children.
   * @param order    A constant that defines the sort order.
   *                 Possible values are `FlxSort.ASCENDING` (default) and `FlxSort.DESCENDING`.
   * @return         The sorted children list.
   */
  public inline function sort(func:(Int, T, T) -> Int, setGroup:Bool = true, order = FlxSort.ASCENDING):Null<Array<T>>
  {
    if (setGroup)
    {
      children.sort(func.bind(order));
      return children;
    }
    else
    {
      var fakeKids = children.copy();
      fakeKids.sort(func.bind(order));
      return fakeKids;
    }
  }

  /**
   * Refreshes the group, by redoing the render order of all children.
   * It does this based on the `zIndex` of each child.
   */
  public function refresh():Void
  {
    sort(SortUtil.byZIndex);
  }

  /**
   * Get's the first alive child under this FunkinGroup. Returns null if it can't
   * find squat.
   *
   * @return The alive child or null.
   */
  public inline function getFirstAlive():Null<T>
  {
    for (child in children)
    {
      if (child.exists && child.alive) return child;
    }

    return null;
  }

  /**
   * Get's the first dead child under this FunkinGroup. Returns null if it can't
   * find squat.
   * getFirstAlive's evil twin.
   *
   * @return The dead child or null.
   */
  public inline function getFirstDead():Null<T>
  {
    for (child in children)
    {
      if (!child.alive) return child;
    }

    return null;
  }

  /**
   * Counts the amount of alive children in this FunkinGroup.
   *
   * @return The alive child number or null.
   */
  public inline function countLiving():Int
  {
    var i = 0;

    for (child in children)
    {
      if (child.alive) i++;
    }

    return i;
  }

  /**
   * Counts the amount of dead children in this FunkinGroup.
   *
   * @return The dead child number or null.
   */
  public inline function countDead():Int
  {
    var i = 0;

    for (child in children)
    {
      if (!child.alive) i++;
    }

    return i;
  }

  /**
   * Gets the first nonexistent child in the family and returns it.
   * Good for recycling.
   *
   * @return The child or null.
   */
  public inline function getFirstAvailable():Null<T>
  {
    for (child in children)
    {
      if (!child.exists) return child;
    }

    return null;
  }

  /**
   * Get's the index of tje first null child under this FunkinGroup.
   * -1 means it failed
   *
   * @return The index.
   */
  public inline function getFirstNull():Int
  {
    for (child in 0...size)
    {
      if (children[child] == null) return child;
    }

    return -1;
  }

  /**
   * Gets the first existing child in the family and returns it.
   * Good for recycling.
   *
   * @return The child or null.
   */
  public inline function getFirstExisting():Null<T>
  {
    for (child in children)
    {
      if (child.exists) return child;
    }

    return null;
  }

  /**
   * Gets a random child from this FunkinGroup.
   * @param startIndex Optional offset off the front of the array.
   *                   Default value is `0`, or the beginning of the array.
   * @param length Optional restriction on the number of values you want to randomly select from.
   * @return A child or null.
   */
  public inline function getRandom(startIndex:Int = 0, length:Int = 0):Null<T>
  {
    if (size <= 0) return null;

    if (startIndex < 0) startIndex = 0;
    if (length <= 0) length = size;

    return FlxG.random.getObject(children, startIndex, length);
  }

  /**
   * Brings a child back from the graveyard.
   *
   * @param child The child to revive.
   */
  public function reviveChild(child:T):Void
  {
    if (child != null) child.revive();
  }

  /**
   * Kills all the children and then itself.
   * Revive this group via `revive()`.
   */
  override public function kill():Void
  {
    for (child in children)
    {
      if (child != null) child.kill();
    }

    super.kill();
  }

  /**
   * Revives all the children and then itself.
   */
  override public function revive():Void
  {
    for (child in children)
    {
      if (child != null) child.revive();
    }

    super.revive();
  }

  override public function clone():FunkinGroup<T>
  {
    var group = new FunkinGroup<T>(x, y, maxSize);

    for (child in children)
    {
      group.adopt(cast child.clone());
    }

    return group;
  }

  // =============================================================
  //   Unavailable funcitons that won't work with `FunkinGroup`.
  // =============================================================

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this group
   */
  override public function makeGraphic(Width:Int, Height:Int, Color:Int = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite
  {
    #if FLX_DEBUG
    throw "This function is not supported in FunkinGroup";
    #end
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this group
   */
  override public function loadGraphicFromSprite(Sprite:FlxSprite):FlxSprite
  {
    #if FLX_DEBUG
    throw "This function is not supported in FunkinGroup";
    #end
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this group
   */
  override public function loadGraphic(Graphic:flixel.system.FlxAssets.FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0,
      Unique:Bool = false, ?Key:String):FlxSprite
  {
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this group
   */
  override public function loadRotatedGraphic(Graphic:flixel.system.FlxAssets.FlxGraphicAsset, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false,
      AutoBuffer:Bool = false, ?Key:String):FlxSprite
  {
    #if FLX_DEBUG
    throw "This function is not supported in FunkinGroup";
    #end
    return this;
  }

  override function set_pixels(Value:openfl.display.BitmapData):openfl.display.BitmapData
  {
    return Value;
  }

  override function set_frame(Value:flixel.graphics.frames.FlxFrame):flixel.graphics.frames.FlxFrame
  {
    return Value;
  }

  override function get_pixels():openfl.display.BitmapData
  {
    return null;
  }

  /**
   * Internal function to update the current animation frame.
   *
   * @param	RunOnCpp	Whether the frame should also be recalculated if we're on a non-flash target
   */
  override inline function calcFrame(RunOnCpp:Bool = false):Void
  {
    // Nothing to do here
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   */
  override inline function resetHelpers():Void {}

  /**
   * This functionality isn't supported in `FunkinGroup`.
   */
  override public inline function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void {}

  override function set_frames(Frames:flixel.graphics.frames.FlxFramesCollection):flixel.graphics.frames.FlxFramesCollection
  {
    return Frames;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   */
  override inline function updateColorTransform():Void {}

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return null
   */
  public static function create(x:Float = 0.0, y:Float = 0.0, key:String):FunkinSprite
  {
    return null;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return null
   */
  public static function createSparrow(x:Float = 0.0, y:Float = 0.0, key:String):FunkinSprite
  {
    return null;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return null
   */
  public static function createPacker(x:Float = 0.0, y:Float = 0.0, key:String):FunkinSprite
  {
    return null;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return null
   */
  public static function createTextureAtlas(x:Float = 0.0, y:Float = 0.0, key:String, ?assetLibrary:Null<String>,
      ?settings:funkin.graphics.FunkinSprite.AtlasSpriteSettings):FunkinSprite
  {
    return null;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this
   */
  override public function loadTexture(key:String):FunkinSprite
  {
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this
   */
  override public function loadTextureAsync(key:String, fade:Bool = false):Void {}

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this
   */
  override public function loadBitmapData(input:openfl.display.BitmapData, cache:Bool = true):FunkinSprite
  {
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this
   */
  override public function loadTextureBase(input:openfl.display3D.textures.TextureBase):Null<FunkinSprite>
  {
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this
   */
  override public function loadTextureAtlas(key:Null<String>, ?assetLibrary:Null<String>, ?settings:AtlasSpriteSettings):FunkinSprite
  {
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this
   */
  override public function loadSparrow(key:String):FunkinSprite
  {
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this
   */
  override public function loadPacker(key:String):FunkinSprite
  {
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return false
   */
  override public function isAnimationDynamic(id:String):Bool
  {
    return false;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return false
   */
  override public function hasAnimation(id:String):Bool
  {
    return false;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return []
   */
  override public function getFramesWithKeyword(keyword:String):Array<animate.internal.Frame>
  {
    return [];
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return null
   */
  override public function getCurrentAnimation():String
  {
    return null;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return false
   */
  override public function isAnimationFinished():Bool
  {
    return false;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return this
   */
  override public function makeSolidColor(width:Int, height:Int, color:FlxColor = FlxColor.WHITE):FunkinSprite
  {
    return this;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return []
   */
  override public function listAnimations():Array<String>
  {
    return [];
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return []
   */
  override public function getFrameLabelList():Array<String>
  {
    return [];
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return null
   */
  override public function getFrameLabel(name:String):Null<animate.internal.Frame>
  {
    return null;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return null
   */
  override public function getDefaultSymbol():String
  {
    return null;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   */
  override public function replaceSymbolGraphic(symbol:String, ?graphic:Null<flixel.system.FlxAssets.FlxGraphicAsset>, ?adjustScale:Bool = true):Void {}

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return null
   */
  override public function getFirstElement(symbol:String):Null<animate.internal.elements.Element>
  {
    return null;
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   * @return []
   */
  override public function getSymbolElements(symbol:String):Array<animate.internal.elements.Element>
  {
    return [];
  }

  /**
   * This functionality isn't supported in `FunkinGroup`.
   */
  override public function scaleElement(element:animate.internal.elements.Element, scale:Float, positionOffset:Float = 0, scaleEverything:Bool = false):Void {}
}

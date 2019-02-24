package echo;

import hxmath.math.Vector2;
import glib.Disposable;
import glib.Proxy;
import echo.Shape;
import echo.Echo;
import echo.shape.Rect;
import echo.data.Options;
import echo.data.Types;
/**
 * A `Body` is an Object representing a Physical Body in a `World`.
 *
 * Bodies have position, velocity, mass, an optional collider shape, and many other properties that are used in a `World` simulation.
 */
class Body implements IEcho implements IDisposable implements IProxy {
  /**
   * Default Body Options
   */
  public static var defaults(get, null):BodyOptions;
  static var ids:Int = 0;
  /**
   * Unique id of the Body.
   */
  public var id(default, null):Int;
  /**
   * The Body's position on the X axis.
   *
   * Alias for `position.x`.
   */
  @:alias(position.x)
  public var x:Float;
  /**
   * The Body's position on the Y axis.
   *
   * Alias for `position.y`.
   */
  @:alias(position.y)
  public var y:Float;
  /**
   * The Body's optional `Shape`. If it **isn't** null, this `Shape` acts as the Body's Collider, allowing it to be checked for Collisions.
   */
  public var shape(get, set):Null<Shape>;
  /**
   * Flag to set whether the Body collides with other Bodies.
   *
   * If false, this Body will not have its position or velocity affected by other Bodies, but it will still call collision callbacks
   */
  public var solid(get, set):Bool;
  /**
   * Body's mass. Affects how the Body reacts to Collisions and Velocity.
   *
   * The higher a Body's mass, the more resistant it is to those forces.
   * If a Body's mass is set to `0`, it becomes static - unmovable by forces and collisions.
   */
  public var mass(get, set):Float;
  /**
   * Body's position on the X and Y axis.
   */
  public var position(get, set):Vector2;
  /**
   * Body's current rotational angle. Currently is not implemented.
   */
  public var rotation(get, set):Float;
  /**
   * Value to determine how much of a Body's `velocity` should be retained during collisions (or how much should the `Body` "bounce" in other words).
   */
  public var elasticity(get, set):Float;
  /**
   * The units/second that a `Body` moves.
   */
  public var velocity(get, set):Vector2;
  /**
   * A measure of how fast a `Body` will change it's velocity. Can be thought of the sum of all external forces on an object (such as a World's gravity) during a step.
   */
  public var acceleration(get, set):Vector2;
  /**
   * The units/second that a `Body` will rotate. Currently is not Implemented.
   */
  public var rotational_velocity(get, set):Float;
  /**
   * The maximum velocity range that a `Body` can have.
   *
   * If set to 0, the Body has no restrictions on how fast it can move.
   */
  public var max_velocity(get, set):Vector2;
  /**
   * The maximum rotational velocity range that a `Body` can have. Currently not Implemented.
   *
   * If set to 0, the Body has no restrictions on how fast it can rotate.
   */
  public var max_rotational_velocity(get, set):Float;
  /**
   * A measure of how fast a Body will move its velocity towards 0 when there is no acceleration.
   */
  public var drag(get, set):Vector2;
  /**
   * Percentage value that represents how much a World's gravity affects the Body.
   */
  public var gravity_scale(get, set):Float;
  /**
   * Cached value of 1 divided by the Body's mass. Used in Internal calculations.
   */
  public var inverse_mass(default, null):Float;
  /**
   * Flag to set if the Body is active and will participate in a World's Physics calculations or Collision querys.
   */
  public var active:Bool;
  /**
   * Enum to determine the whether this Object is a `Body` or a `Group`. This is used in place of Type Casting internally.
   */
  public var type(default, null):EchoType;
  /**
   * Flag to check if the Body collided with something during the step.
   * Used for debug drawing.
   */
  public var collided:Bool;
  /**
   * Creates a new Body.
   * @param options Optional values to configure the new Body
   */
  public function new(?options:BodyOptions) {
    this.id = ++ids;
    active = true;
    type = BODY;
    position = new Vector2(0, 0);
    velocity = new Vector2(0, 0);
    acceleration = new Vector2(0, 0);
    max_velocity = new Vector2(0, 0);
    drag = new Vector2(0, 0);
    load(options);
  }
  /**
   * Sets a Body's values from a `BodyOptions` object.
   * @param options
   */
  public function load(?options:BodyOptions) {
    options = glib.Data.copy_fields(options, defaults);
    if (options.shape != null) shape = Shape.get(options.shape);
    solid = options.solid;
    mass = options.mass;
    position.set(options.x, options.y);
    elasticity = options.elasticity;
    velocity.set(options.velocity_x, options.velocity_y);
    rotational_velocity = options.rotational_velocity;
    max_velocity.set(options.max_velocity_x, options.max_velocity_y);
    max_rotational_velocity = options.max_rotational_velocity;
    drag.set(options.drag_x, options.drag_y);
  }
  /**
   * Adds forces to a Body's acceleration.
   * @param x
   * @param y
   */
  public function push(x:Float = 0, y:Float = 0) {
    acceleration.x += x;
    acceleration.y += y;
  }
  /**
   * If a Body has a shape, it will return an AABB `Rect` representing the bounds of that shape relative to the Body's Position. If the Body does not have a shape, this will return `nu``l.
   * @return Null<Rect>
   */
  public function bounds():Null<Rect> {
    if (shape == null) return null;
    var b = shape.bounds();
    b.position.addWith(position);
    return b;
  }
  /**
   * Disposes the Body. DO NOT use the Body after disposing it, as it could lead to null reference errors.
   */
  public function dispose() {
    shape.put();
    velocity = null;
    max_velocity = null;
    drag = null;
  }

  function set_mass(value:Float):Float {
    if (value < 0.0001) {
      value = 0;
      inverse_mass = 0;
    }
    else inverse_mass = 1 / value;
    return mass = value;
  }

  static function get_defaults():BodyOptions return {
    solid: true,
    mass: 1,
    x: 0,
    y: 0,
    elasticity: 0,
    velocity_x: 0,
    velocity_y: 0,
    rotational_velocity: 0,
    max_velocity_x: 0,
    max_velocity_y: 0,
    max_rotational_velocity: 10000,
    drag_x: 0,
    drag_y: 0
  }
}

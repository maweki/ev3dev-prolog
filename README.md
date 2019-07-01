# ev3dev-prolog - LEGO Mindstorms ev3 API for Prolog

This is a ev3dev-based API for Prolog using the readily available swi-Prolog.

## Installation

* write [ev3dev](https://ev3dev.org) to an SD card and launch ev3dev on your brick
* ssh into the brick
* install swi-Prolog using `sudo apt-get install swi-prolog`. This takes some time.
* clone this repository onto your brick and you're good to go.

## Examples

Interactive mode can be started using `swipl ev3_base.pl` for the low level API with sensor and actor controls similar to the base EV3 software or other ev3dev APIs, and `swipl ev3.pl` for the high level abstraction which is on a similar level as OpenRoberta or others (in that it includes an internal robot model).

Complex examples (including breadth-first search planning on a grid) can be found in the `examples` directory.

### Sensor and Actor Control

* `tacho_motor(X).` binds the port of the discovered tacho motors to `X`. Fails if no tacho motor is connected.
* `us_dist_cm(_, X).` binds the measured ultrasonic distance to `X`. Fails if no ultrasonic sensor is connected.
* `forall(tacho_motor(M), motor_run(M, 50)), repeat, us_dist_cm(_, X), X < 5, forall(tacho_motor(M), motor_stop(M)).` runs all motors until the distance sensor shows less than 5.

The available predicates are a wrapper pretty close to what's done with other ev3dev APIs and if you're familiar with ev3dev you should feel right at home.

### High Level Abstraction

The high level abstraction uses an internal robot model. The predicate `set_robot(WheelDiameter, AxleLength, LeftMotorPort, RightMotorPort)` is used to initialize the internal model. Then we provide the following high level commands:

* `stop`
* `go(Speed)`
* `go(Speed, Angle)`
* `go_cm(Speed, Distance)`
* `turn(Speed, Angle)` - This has multiple implementations depending on whether the gyro sensor is attached or not.
* `turn(Speed)`

### Programming Hints

If you want to write robot programs that run forever, you have two ways to do that using the Prolog evaluation Scheme (SLD-Resolution): Using the predicate [repeat](https://www.swi-prolog.org/pldoc/man?predicate=repeat/0) (which always succeeds and creates an infinite amount of choice points) you get as resolution tree that is infinitely wide. Or using recursion (`a :- a.` is an infinite derivation) that doesn't end. Using the latter method be careful to use a cut before the recursion stap as to not leave choice points on recursing. Leftover choice points can fill up your limited program memory very fast. In our experience a mix of those two methods with the recursion into the subgoals as program states and `repeat` as interactivity control leads to the most readable code.

## Publications

The Prolog API was presented or will be presented at the following workshops:

* [WLP 2017](http://declare17.de/wflp/) - [Slides](http://www.imn.htwk-leipzig.de/~roberta/files/wlp17_roberta_prolog.pdf)
* [LaSh 2019](http://www.logicandsearch.org/LaSh2019/)
* [MOC 2019](http://wi.hwtk.de/MOC2019/)

The higher level abstraction is inspired by [Nalepa](https://link.springer.com/chapter/10.1007%2F978-3-540-85845-4_50)

## Authors

* [Mario Wenzel](https://dbs.informatik.uni-halle.de/wenzel/)
* [Sibylle Schwarz](https://www.imn.htwk-leipzig.de/~schwarz/)

## Related Work

* There is a [brickman](https://github.com/dYalib/brickman) fork that supports running pl-files from the graphical user interface. This fork needs some work as the development is no longer funded.

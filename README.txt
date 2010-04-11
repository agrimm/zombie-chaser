== DESCRIPTION:

Zombie chaser is a graphic(al) interface to mutation testing. Kill off the mutants, or they will eat your brains!

The human running across the screen represents the normal running of your unit tests. If one of them fails, then the human dies.

Then the zombies chase after you. Each zombie represents a mutation to your code (your code doing something it shouldn't be doing). If your unit tests detect that something's wrong with your code, then the mutation gets killed. Otherwise, the zombie gets to meat you.

There are two alternatives for the interface. One is a GUI, while the other is a nethack-style interface that runs within the console itself. Zombie-chaser aims to be compatible with any flavor of ruby on any platform.

== REQUIREMENTS:

* Gosu (optional)
* Test-unit (for ruby 1.9)

== INSTALL:

* [sudo] gem install zombie-chaser
* [sudo] gem install gosu #Optional
* [sudo] gem install test-unit #Optional

* Don't use sudo if it's not applicable (can't or don't want to use root, or you're using Windows)
* Gosu is not listed as a dependency, as otherwise jruby complains about gosu's absence before the program starts. Therefore you have to install it manually if you want a GUI interface.
* If you're using ruby 1.9, you'll need to install the gem version of test-unit.

== CURRENT BUGS:

* Resource-intensive tests are especially slow in GUI mode for some reason. Run them in console mode (using --console) to make the program run faster.
* Very occasionally, the program can crash, possibly because of threading issues. Please notify me if it becomes a consistent problem.

== LICENSE:

(The MIT License)

Copyright (c) 2006-2009 Ryan Davis and Kevin Clark and Andrew Grimm,
Chris Lloyd, Dave Newman, Carl Woodward & Daniel Bogan.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

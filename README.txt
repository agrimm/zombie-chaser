== DESCRIPTION:

Zombie chaser is a graphic(al) interface to mutation testing. Kill off the mutants, or they will eat your brains!

The human running across the screen represents the normal running of your unit tests. If one of them fails, then the human dies.

Then the zombies chase after you. Each zombie represents a mutation to your code. If your unit tests detect that something's wrong with your code, then the mutation gets killed. Otherwise, the zombie gets to meet you.

== FEATURES/PROBLEMS:

* Code is slightly different to chaser.
* Not quite finished.

== REQUIREMENTS:

* Gosu
* Test-unit (for ruby 1.9)

== INSTALL:

* sudo gem install zombie-chaser

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

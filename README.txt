== DESCRIPTION:

Chaser is unit test sadism(tm), like Seattlerb's Heckle. It's more or less mutation testing, except that rather than mutating every line of code it can get its claws into, it merely modifies the return value of targeted methods. If the unit tests don't notice the modified return values, or the program going haywire as a result of using those modified return values, then they aren't doing their jobs properly.

Unit test sadism is a trademark of Ryan Davis and Kevin Clark, and is used without permission.

== FEATURES/PROBLEMS:

* It only mutates the return values of methods.
* It works in ruby 1.9, Windows, and JRuby.

== REQUIREMENTS:

* Test/Unit. Ruby 1.9 needs the test-unit gem, while ruby 1.8 doesn't require anything!

== INSTALL:

* Add gemcutter as a gem source.
* sudo gem install chaser

== LICENSE:

(The MIT License)

Copyright (c) 2006-2009 Ryan Davis and Kevin Clark and Andrew Grimm

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

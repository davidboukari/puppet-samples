class example{

file{'hello':
  path => '/tmp/hello',
  content => 'Hello World',
}

notify{ 'This is from site directory': }

}

include 'example::goodbye'
include 'example::file'
include 'example::template'



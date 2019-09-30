class example::file{

file { 'source-file':
path => '/tmp/example-file',
source => 'puppet:///modules/example/example-file',
}


}

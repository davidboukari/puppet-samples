class example::template{

file{'example-template':
path => '/tmp/example-template',
content => template('example/example-template.erb'),
}

}

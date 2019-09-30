class example::goodbye{
file{ 'goodbye':
  path => '/tmp/goodbye',
  content => 'Goodbye...',
}

}

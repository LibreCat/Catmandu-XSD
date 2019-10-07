requires 'perl', 'v5.10.1';

on 'test', sub {
  requires 'Test::Simple', '1.001003';
  requires 'Test::More', '1.001003';
  requires 'Test::Exception', '0';
  requires 'XML::XPath', '1.13';
};

requires 'Moo', '0';
requires 'namespace::clean', '0';
requires 'Catmandu', '>= 1.0';
requires 'Catmandu::Template' , '0';
requires 'XML::Compile', '0';
requires 'XML::Compile::Cache', '0';
requires 'XML::LibXML', '0';

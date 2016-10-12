#!perl

use strict;
use warnings;
use Test::More;

use Catmandu;
use Catmandu::Util qw(:io);
use XML::LibXML::XPathContext;

BEGIN {
    use_ok 'Catmandu::Exporter::XSD';
}

require_ok 'Catmandu::Exporter::XSD';

done_testing 2;

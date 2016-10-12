#!perl

use strict;
use warnings;
use Test::More;

use Catmandu;
use Catmandu::Util qw(:io);
use XML::LibXML;
use XML::LibXML::XPathContext;

BEGIN {
    use_ok 'Catmandu::Exporter::XSD';
}

require_ok 'Catmandu::Exporter::XSD';

{
    my $xml = '';
    my $exporter = Catmandu->exporter('XSD' ,
            file    => \$xml ,
            root    => '{}shiporder' ,
            schemas => 't/demo/order/*.xsd' ,
    );

    ok $exporter , 'got an exporter' ;

    ok $exporter->add({
            orderid     => 889924 ,
            orderperson => 'Olga Brown' ,
            shipto      => {
                name    => 'Kalevia Aho' ,
                address => 'Monstreet 3' ,
                city    => '9000 Emarald' ,
                country => 'Canada' ,
                date    => '2014-11-03'
            } ,
            item => {
                title    => 'Empire Burlesque' ,
                note     => 'Special Edition' ,
                quantity => 1 ,
                price    => 10.90
            }
    });

    ok $exporter->commit;

    like $xml , qr/<\?xml version="1.0" encoding="UTF-8"\?>/ , 'looks like XML';

    my $doc = XML::LibXML->load_xml(string => $xml);

    ok $doc , 'is XML';

    my $xc = XML::LibXML::XPathContext->new($doc);

    is $xc->findvalue('/shiporder/item/title') , 'Empire Burlesque' , '/shiporder/item/title';

}

done_testing 8;

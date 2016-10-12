package Catmandu::XSD;

use Moo;
use Catmandu::Util;
use XML::Compile;
use XML::Compile::Cache;
use XML::Compile::Util 'pack_type';

our $VERSION = '0.01';

has 'root'      => (is => 'ro' , required => 1);
has 'schemas'   => (is => 'ro' , required => 1 , coerce => sub {
    my ($value) = @_;
    if (Catmandu::Util::is_array_ref($value)) {
        return $value;
    }
    elsif ($value =~ /\*/) {
        my @files = glob($value);
        \@files;
    }
    else {
        my @files = split(/,/,$value);
        \@files;
    }
});

has 'mixed'     => (is => 'ro' , default => sub { 'ATTRIBUTES' });

has 'prefixes'  => (is => 'ro' , coerce  => sub {
   my ($value) = @_;
   if (Catmandu::Util::is_array_ref($value)) {
       return $value;
   }
   elsif (defined($value)) {
       my $ret = [];
       for (split(/,/,$value)) {
           my ($ns,$url) = split(/:/,$_,2);
           push @$ret , { $ns => $url };
       }
       return $ret;
   }
   else {
       undef;
   }
});

has '_reader'    => (is => 'ro');
has '_writer'    => (is => 'ro');

sub BUILD {
    my ($self) = @_;

    my $schema = XML::Compile::Cache->new($self->schemas);

    $schema->addHook(
        action => 'READER' ,
        after => sub {
             my ($xml, $data, $path) = @_;
             delete $data->{_MIXED_ELEMENT_MODE} if Catmandu::Util::is_hash_ref($data);
             $data;
        }
    );

    $self->{_reader} = $schema->compile(
            READER          => $self->root,
            mixed_elements  => $self->mixed ,
            sloppy_floats   => 'true',
            sloppy_integers => 'true' ,
    );

    $self->{_writer} = $schema->compile(
            WRITER          => $self->root,
            prefixes        => $self->prefixes,
            sloppy_floats   => 'true',
            sloppy_integers => 'true' ,
    );

    $schema = undef;
}

sub parse {
    my ($self,$input) = @_;
    $self->_reader->($input);
}

sub to_xml {
    my ($self,$data) = @_;
    my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
    my $xml    = $self->_writer->($doc, $data);
    $doc->setDocumentElement($xml);
    $doc->toString(1);
}

1;

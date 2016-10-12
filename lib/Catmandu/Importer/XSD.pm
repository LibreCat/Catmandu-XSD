package Catmandu::Importer::XSD;

use Catmandu::Sane;
use Catmandu::Util qw(:is);
use XML::LibXML::Reader;
use Catmandu::XSD;
use feature 'state';

our $VERSION = '0.01';

use Moo;
use namespace::clean;

with 'Catmandu::Importer';

has 'root'     => (is => 'ro' , required => 1);
has 'schemas'  => (is => 'ro' , required => 1);
has 'mixed'    => (is => 'ro' , default => sub { 'ATTRIBUTES' });
has 'prefixes' => (is => 'ro' , default => sub { [] });
has 'files'    => (is => 'ro');
has 'xpath'    => (is => 'ro' , default => sub { '*' });


has 'xsd'      => (is => 'lazy');

sub _build_xsd {
    my $self = $_[0];
    return Catmandu::XSD->new(
        root     => $self->root ,
        schemas  => $self->schemas ,
        mixed    => $self->mixed ,
        prefixes => $self->prefixes ,
    );
}

sub generator {
    my $self = $_[0];

    $self->files ? $self->multi_file_generator : $self->single_file_generator;
}

sub multi_file_generator {
    my $self = $_[0];

    my @files = glob($self->files);

    sub {
        my $file = shift @files;

        return undef unless $file;
        my $xml = XML::LibXML->load_xml(location => $file);
        $self->xsd->parse($xml);
    };
}

sub single_file_generator {
    my $self = $_[0];

    my $prefixes = {};

    if ($self->prefixes) {
        if (is_array_ref $self->prefixes) {
            for (@{$self->prefixes}) {
                my ($key,$val) = each %$_;
                $prefixes->{$key} = $val;
            }
        }
        else {
            for (split(/,/,$self->prefixes)) {
                my ($key,$val) = split(/:/,$_,2);
                $prefixes->{$key} = $val;
            }
        }
    }

    sub {
        state $reader = XML::LibXML::Reader->new(IO => $self->fh);

        my $match = $reader->nextPatternMatch(
            XML::LibXML::Pattern->new($self->xpath , $prefixes)
        );

        return undef unless $match == 1;

        my $xml = $reader->readOuterXml();

        $xml =~ s{xmlns="[^"]+"}{};

        return undef unless length $xml;

        $reader->nextSibling();

        my $data = $self->xsd->parse($xml);

        return $data;
    };
}

1;

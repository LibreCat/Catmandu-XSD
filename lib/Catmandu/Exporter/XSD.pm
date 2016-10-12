package Catmandu::Exporter::XSD;

use Catmandu::Sane;

our $VERSION = '0.01';

use Moo;
use Catmandu;
use Catmandu::XSD;

with 'Catmandu::Exporter';

has 'root'     => (is => 'ro' , required => 1);
has 'schemas'  => (is => 'ro' , required => 1);
has 'mixed'    => (is => 'ro' , default => sub { 'ATTRIBUTES' });
has 'prefixes' => (is => 'ro');

has 'split'           => (is => 'ro');
has 'split_pattern'   => (is => 'ro' , default => sub { '%s.xml' } );
has 'split_directory' => (is => 'ro' , default => sub { '.' });

has 'template_before' => (is => 'ro');
has 'template'        => (is => 'ro');
has 'template_after'  => (is => 'ro');

has 'tt'       => (is => 'lazy');
has 'xsd'      => (is => 'lazy');

sub BUILD {
    my ($self,$args) = @_;

    die "split and template can't be set at the same time"
        if (exists $args->{split} && exists $args->{template});
}

sub _build_xsd {
    my $self = $_[0];
    return Catmandu::XSD->new(
        root     => $self->root ,
        schemas  => $self->schemas ,
        mixed    => $self->mixed ,
        prefixes => $self->prefixes ,
    );
}

sub _build_tt {
    my $self = $_[0];

    if ($self->template) {
        Catmandu->exporter(
            'Template',
            template_before => $self->template_before ,
            template        => $self->template ,
            template_after  => $self->template_after ,
        );
    }
}

sub add {
    my ($self, $data) = @_;

    my $xml = $self->xsd->to_xml($data);

    if ($self->template) {
        $xml =~ s{<\?xml version="1.0" encoding="UTF-8"\?>}{};
        $data->{xml} = $xml;
        $self->tt->add($data);
    }
    elsif ($self->split) {
        my $id = $data->{_id} // $self->count;
        my $directory = $self->split_directory;
        my $filename  = sprintf $self->split_pattern , $id;
        local(*F);
        open(F,'>:encoding(utf-8)',"$directory/$filename")
            || die "failed to open $directory/$filename for writing : $!";
        print F $xml;
        close(F);
    }
    else {
        $self->fh->print($xml);
    }
}

sub commit {
    my $self = $_[0];

    if ($self->template && $self->count) {
        $self->tt->commit;
    }
}

1;

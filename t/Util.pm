use strict;
use warnings;
use utf8;

package t::Util;
use parent qw/Exporter/;

our @EXPORT = qw/slurp link_ compile write_file tmpdir touch/;

sub touch {
    my $diff = shift;
    my $fname = shift;
    my $time = time() + $diff;
    utime($time, $time, $fname);
}


sub tmpdir() {
    t::Util::TmpDir->new();
}

sub slurp {
    my $fname = shift;
    open my $fh, '<', $fname or die "Cannot open file: $fname: $!";
    do { local $/; <$fh> };
}

sub link_ {
    my ($srcs, $dst) = @_;
    write_file( $dst, join( "\n", map { slurp($_) } @$srcs ) );
}

sub compile {
    my ($src, $dst) = @_;
    my $content = "OBJ:" . slurp($src);
    write_file($dst, $content);
}

sub write_file {
    my ($fname, $content) = @_;
    open my $fh, '>:encoding(utf-8)', $fname or die "Cannot open file: $fname: $!";
    print({$fh} $content) or die "Cannot write file: $fname";
    close $fh or die "Cannot close file: $fname";
}

package t::Util::TmpDir;
use File::Temp qw/tempdir/;
use Cwd;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->{cwd} = Cwd::getcwd();
    $self->{dir} = tempdir(CLENAUP => 1);
    chdir($self->{dir}) or die "Cannot chdir";
    return $self;
}

sub DESTROY {
    my ($self) = @_;
    chdir($self->{cwd});
    delete $self->{$_} for keys %$self;
}

1;


package lexically;
use strict;
use warnings;

use Exporter ();
use Exporter::Lexical 0.02 ();
use Module::Runtime 'require_module';

our $INDEX = 0;

sub import {
    shift;
    my ($package, @args) = @_;

    my $index = $INDEX++;
    my $scratchpad = "lexically::scratchpad_$index";
    my $stash = do {
        no strict 'refs';
        \%{ $scratchpad . '::' }
    };

    require_module($package);

    eval qq[package $scratchpad; '$package'->import(\@args)];
    die if $@;

    my @exports = grep {
        ref(\$stash->{$_}) ne 'GLOB' || defined(*{ $stash->{$_} }{CODE})
    } keys %$stash;

    my $import = Exporter::Lexical::build_exporter({
        -exports => \@exports,
    }, $scratchpad);

    $import->($package, @args);

    delete $lexically::{"scratchpad_${index}::"};
}

1;

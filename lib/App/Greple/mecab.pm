=head1 NAME

mecab - Greple module to produce result by mecab

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

greple -Mmecab

=head1 DESCRIPTION

=head1 SEE ALSO

L<App::cdif::Command::mecab>

=head1 LICENSE

Copyright (C) Kazumasa Utashiro.

These commands and libraries are free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Kazumasa Utashiro

=cut

package App::Greple::mecab;

use v5.14;
use strict;
use warnings;

our $VERSION = "0.01"; 

use App::cdif::Command::Mecab;

my $mecab = new App::cdif::Command::Mecab;

sub split {
    my $s = 0;
    map {
	[ $s + 0, $s += length ]
    }
    $mecab->wordlist($_);
}

1;

__DATA__

#option default --mecab

option --mecab --le &__PACKAGE__::split

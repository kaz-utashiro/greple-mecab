=head1 NAME

mecab - Greple module to produce result by mecab

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

greple -Mmecab

=head1 DESCRIPTION

=head1 SEE ALSO

L<App::cdif::Command::mecab>

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright 2019 Kazumasa Utashiro.

These commands and libraries are free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

package App::Greple::mecab;

use v5.14;
use strict;
use warnings;

our $VERSION = "0.01"; 
our $debug = 0;

use parent 'App::cdif::Command';
use App::Greple::Util;

use Data::Dumper;
#{
#    no warnings 'redefine';
#    *Data::Dumper::qquote = sub { qq["${\(shift)}"] };
#    $Data::Dumper::Useperl = 1;
#}

sub wordlist {
    my $obj = shift;
    my $opt = ref $_[0] eq 'HASH' ? shift : {};
    my $text = shift;

    ##
    ## mecab ignores trailing spaces.
    ##
    my $removeme = sub {
	local *_ = shift;
	return sub { 0 } unless /[ \t]+$/m;
	my $magic = "15570"."67583";
	$magic++ while /$magic/;
	s/[ \t]+\K$/$magic/mg;
	sub { $_[0] eq $magic };
    }->(\$text);

    my $eos = "EOS" . "000";
    $eos++ while $text =~ /$eos/;
    my $is_newline = sub { $_ eq $eos };

    my $mecab = [ 'mecab', '--node-format', '%H %M\\n', '--eos-format', "$eos\\n" ];
    my $result = $obj->command($mecab)->setstdin($text)->update->data;
    warn $result =~ s/^/MECAB: /mgr if $debug;
    my $uniq_index = new UniqIndex;
    my @mecab = do {
	grep { not $removeme->($_->[1]) }
#	grep { length $_->[1] }
	map  {
	    $is_newline->() ? [ undef, "\n" ] : do {
#		/^(\d+) (\s*)(\S+)$/a or die "Data error: \"$_\"\n";
		/^(.*?,.*?),\S+ (\s*)(\S+)$/a or die "Data error: \"$_\"\n";
		(
		 defined $2 ? [ undef, $2 ] : (),
		 [ $uniq_index->index($1), $3 ]
		)
	    }
	}
	$result =~ /^(.+)\n/amg;
    };
    @mecab;
}

my $mecab = __PACKAGE__->new();

sub split {
    my $s = 0;
    map {
	[ $s + 0, $s += length($_->[1]), $_->[0] // 0 ]
    }
    $mecab->wordlist($_);
}

1;

__DATA__

#option default --mecab

option --mecab --le &__PACKAGE__::split

package App::Greple::mecab;

use v5.14;
use strict;
use warnings;
use utf8;

our $VERSION = "0.01"; 

=encoding utf-8

=head1 NAME

mecab - Greple module to produce result by mecab

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

greple -Mmecab

=head1 DESCRIPTION

Work in progress.

現時点では、--mecab オプションで品詞毎に色分けした結果を出力する。

=head1 SEE ALSO

L<App::cdif::Command::mecab>

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright 2019-2023 Kazumasa Utashiro.

These commands and libraries are free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

our $mecab_debug = 0;

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

    my $mecab = [ 'mecab', '--node-format', '%M\\t%H\\n', '--eos-format', "$eos\\n" ];
    my $result = $obj->command($mecab)->setstdin($text)->update->data;
    warn $result =~ s/^/MECAB: /mgr if $mecab_debug;
    my $uniq_index = new UniqIndex;
    my $sp_index = $uniq_index->index('記号,空白');
    my @mecab = do {
	grep { not $removeme->($_->[1]) }
	map  {
	    $is_newline->() ? [ $sp_index, "\n" ] : do {
		m{  ^
		    (?<空白> [ \t]* )
		    (?<単語> \S+ )
		    \t
		    (?<品詞> [^,\n]*,[^,\n]* )
		}xa
		    or die "Mecab format error: \"$_\"\n";
		#
		# 英単語の場合、直前の空白と連結して認識される
		#
		my($空白, $単語, $品詞) = @+{qw(空白 単語 品詞)};
		(
		    $空白 ne '' ? [ $sp_index, $空白 ] : (),
		    [ $uniq_index->index($品詞), $単語 ]
		);
	    }
	}
	$result =~ /^(.+)\n/amg;
    };
    @mecab;
}

my $mecab = __PACKAGE__->new();

sub split {
    my $pos = 0;
    map {
	[ $pos + 0, $pos += length($_->[1]), $_->[0] // 0 ]
    }
    $mecab->wordlist($_);
}

1;

__DATA__

option default -Mcolors --light --dark --solarized-bg

builtin mecab-debug! $mecab_debug

#option default --mecab

option --mecab --le &__PACKAGE__::split

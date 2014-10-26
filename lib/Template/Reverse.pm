package Template::Reverse;

# ABSTRACT: A template generator getting different parts between pair of text

use Moo;
use Carp;
use Template::Reverse::Part;
use Algorithm::Diff qw(sdiff);
use Scalar::Util qw(blessed);
our $VERSION = '0.120'; # VERSION


has 'sidelen' => (
    is=>'rw',
    default => 10
);

my $_WILDCARD = bless [], 'WILDCARD';
sub WILDCARD{return $_WILDCARD};
sub _isWILDCARD{
  return ref $_[0] eq 'WILDCARD';
}


sub detect{
    my $self = shift;
    my @strs = @_;
    my $diff = _diff($strs[0],$strs[1]);
    my $pattern = _detect($diff,$self->sidelen());
    return $pattern;
}


### internal functions
sub _detect{
    my $diff = shift;
    my $sidelen = shift;
    $sidelen = 0 unless $sidelen;
    my @d = @{$diff};
    my $lastStar = 0;
    my @res;
    for(my $i=0; $i<@d; $i++)
    {
        if( _isWILDCARD($d[$i] ) )
        {
            my $from = $lastStar;
            my $to = $i-1;
            if( $sidelen ){
                $from = $to-$sidelen+1 if $to-$from+1 > $sidelen;
            }
            my @pre = @d[$from..$to];
            
            my $j = @d;
            if( $i+1 < @d ){
                for( $j=$i+1; $j<@d; $j++)
                {
                    if( _isWILDCARD( $d[$j] ) ){
                        last;
                    }
                }
            }
            $from = $i+1;
            $to = $j-1;
            if( $sidelen ){
                $to = $from + $sidelen-1 if $to-$from+1 > $sidelen;
            }
            my @post = @d[$from..$to];
            my $part = Template::Reverse::Part->new(pre=>\@pre, post=>\@post);
            push(@res,$part);
            $lastStar = $i+1;
        }
    }
    return \@res;
}


sub _diff{
    my ($a,$b) = @_;
    my ($org_a,$org_b) = @_;

    $a = [map{blessed($_)?$_->as_string:$_}@{$a}];
    $b = [map{blessed($_)?$_->as_string:$_}@{$b}];
    
    my @d = sdiff($a,$b);
    my @rr;
    my $before='';
    my $idx = 0;
    for my $r (@d){
        if( $r->[0] eq 'u' ){
            push(@rr,$org_a->[$idx]);
            $before = '';
        }
        else{
            push(@rr,WILDCARD) unless _isWILDCARD($before);
            $before = WILDCARD;
        }
        $idx++ if $r->[0] ne '+';
        
    }
    return \@rr;
}



1;

__END__

=pod

=head1 NAME

Template::Reverse - A template generator getting different parts between pair of text

=head1 VERSION

version 0.120

=head1 SYNOPSIS

    use Template::Reverse;
    my $rev = Template::Reverse->new();

    my $parts = $rev->detect($arr_ref1, $arr_ref2); # returns [ Template::Reverser::Part, ... ]

    use Template::Reverse::Converter::TT2;
    my @templates = Template::Reverse::TT2Converter::Convert($parts); # named 'value1','value2',...

more

    # try this!!
    use Template::Reverse;
    use Template::Reverse::Converter::TT2;
    use Data::Dumper;

    my $rev = Template::Reverse->new;

    # generating patterns automatically!!
    my $str1 = [qw(I am perl and smart)];
    my $str2 = [qw(I am khs and a perlmania)];
    my $parts = $rev->detect($str1, $str2);

    my $tt2 = Template::Reverse::Converter::TT2->new;
    my $temps = $tt2->Convert($parts); # equals ['I am [% value %] and','and [% value %]']


    my $str3 = "I am king of the world and a richest man";

    # extract!!
    use Template::Extract;
    my $ext = Template::Extract->new;
    my $value = $ext->extract($temps->[0], $str3);
    print Dumper($value); # output : {'value'=>'king of the world'}

    my $value = $ext->extract($temps->[1], $str3);
    print Dumper($value); # output : {'value'=>'a richest man'}

=head1 DESCRIPTION

Template::Reverse detects different parts between pair of similar text as merged texts from same template.
And it can makes an output marked differences, encodes to TT2 format for being use by Template::Extract module.

=head1 FUNCTIONS

=head3 new(OPTION_HASH_REF)

=head4 sidelen=>$max_length_of_each_side

sidelen is a short of "side character's each max length".
the default value is 10. Setting 0 means full-length.

If you set it as 3, you get max 3 length pre-text and post-text array each part.

This is needed for more faster performance.

=head3 detect($arr_of_text1, $arr_of_text2)

=head3 detect($tokens1, $tokens2)

Get an array-ref of L<Template::Reverse::Part> from two array-refs.
A L<Template::Reverse::Part> class means an one changable token.

The token is L<Parse::Token::Lite::Token>.

It returns like below.

    $rev->detect([qw(A b C)], [qw(A d C)]);
    # 
    # [ { ['A'],['C'] } ] <- Please focus at data, not expression.
    #   : :...: :...: :     
    #   :  pre  post  :
    #   :.............:  
    #       Part #1
    #

    $rev->detect([qw(A b C d E)],[qw(A f C g E)]);
    #
    # [ { ['A'], ['C'] }, { ['C'], ['E'] } ]
    #   : :...:  :...: :  : :...:  :...: :
    #   :  pre   post  :  :  pre   post  :
    #   :..............:  :..............:
    #        Part #1          Part #2
    #

    $rev->detect([qw(A1 A2 B C1 C2 D E1 E2)],[qw(A1 A2 D C1 C2 F E1 E2)]);
    #
    # [ { ['A1','A2'],['C2','C2'] }, { ['C1','C2'], ['E2','E2'] } ]
    #

    my $str1 = [qw"I am perl and smart"];
    my $str2 = [qw"I am KHS and a perlmania"];
    my $parts = $rev->detect($str1, $str2);
    #
    # [ { ['I','am'], ['and'] } , { ['and'],[] } ]
    #   : :........:  :.....: :   :            :
    #   :    pre       post   :   :            :
    #   :.....................:   :............:
    #           Part #1               Part #2
    #

Returned arrayRef is list of changable parts.

    1. At first, $text1 and $text2 is normalized by Spacers.
    2. 'pre texts' and 'post texts' are splited by Splitter. In this case, by Whitespace.
    3. You can get a changing value, just finding 'pre' and 'post' in a normalized text.

=head1 SEE ALSO

=item *

L<Template::Extract>

=head1 SOURCE

L<https://github.com/sng2c/Template-Reverse>

=head1 THANKS TO

=item https://metacpan.org/author/AMORETTE

This module is dedicated to AMORETTE.
He was interested in this module and was cheering me up.

=head1 AUTHOR

HyeonSeung Kim <sng2nara@hanmail.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by HyeonSeung Kim.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Template::Reverse;

# ABSTRACT: A template generator getting different parts between pair of text

use Any::Moose;
use namespace::autoclean;
use Module::Load;
use Carp;

use Algorithm::Diff qw(sdiff);

our $VERSION = '0.01'; # VERSION


has 'splitter' => (
    is=>'rw', 
    isa => 'Str',
    default => 'Template::Reverse::Splitter::Whitespace'
);

has 'spacers' => (
    is=>'rw',
    isa=>'ArrayRef',
    default => sub{[]}
);

has 'sidelen' => (
    is=>'rw',
    isa=>'Int',
    default => 10
);


sub detect{
    my $self = shift;
    my @strs = @_;


    # apply Spacers
    for(my $i=0; $i<@strs; $i++){
        $strs[$i] = $self->space($strs[$i]);
    }
    
    my @res;
    my $splitter_class = $self->splitter;
    load $splitter_class;
    my $splitter = $splitter_class->new;
    foreach my $str (@strs){
        push(@res, [$splitter->Split($str)]);
    }
    undef $splitter;

    my $diff = _diff($res[0],$res[1]);

    my $pattern = _detect($diff,$self->sidelen());
    return $pattern;
}

sub space{
    my $self = shift;
    my $str = shift;
    foreach my $spacer_class (@{$self->spacers()}){
        load $spacer_class;
        my $spacer = $spacer_class->new;
        $str = $spacer->Space($str);
        undef($spacer);
    }
    return $str;
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
        if( $d[$i] eq '*' )
        {
            my $from = $lastStar;
            my $to = $i-1;
            if( $sidelen ){
                $from = $to-$sidelen+1 if $to-$from+1 > $sidelen;
            }
            my @pre = map{substr($_,1);}@d[$from..$to];
            
            my $j = @d;
            if( $i+1 < @d ){
                for( $j=$i+1; $j<@d; $j++)
                {
                    if( $d[$j] eq '*' ){
                        last;
                    }
                }
            }
            $from = $i+1;
            $to = $j-1;
            if( $sidelen ){
                $to = $from + $sidelen-1 if $to-$from+1 > $sidelen;
            }
            my @post =  map{substr($_,1);}@d[$from..$to];

            push(@res,[\@pre,\@post]);
            $lastStar = $i+1;
        }
    }
    return \@res;
}

sub _diff{
    my ($a,$b) = @_;

    my @d = sdiff($a,$b);
    my @rr;
    my $before='';
    for my $r (@d){
        if( $r->[0] eq 'u' ){
            push(@rr,'-'.$r->[1]);
            $before = '';
        }
        else{
            push(@rr,'*') if( $before ne '*' );
            $before = '*';
        }
    }
    return \@rr;
}

sub _make_map{
    my @asc = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 );
    my $str = shift;
    my $spaced = _space($str);
    my @chunk = split(/\s+/,$spaced);

    my $out='';
    foreach my $c (@chunk)
    {
        my $sum=_checksum($c);
        $out.= $asc[$sum % @asc];
    }
    return $out;
}

sub _checksum{
    my $str = shift;
    my $sum = 0;
    map{$sum+=ord($_)}split(//,$str);
    return $sum;
}





__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

Template::Reverse - A template generator getting different parts between pair of text

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    use Template::Reverse;
    my $rev = Template::Reverse->new({
            spacers=>['Template::Reverse::Spacer::Number'],         # put spaces around Numbers. [OPTIONAL]
            splitter=>'Template::Reverse::Splitter::Whitespace',    # and splitting text by white spaces. [DEFAULT]
    });

    my $parts = $rev->detect($output1, $output2); # returns [ [[PRE],[POST]], ... ]

    use Template::Reverse::Converter::TT2;
    my @templates = Template::Reverse::TT2Converter::Convert($parts); # named 'value1','value2',...

more

    # try this!!
    use Template::Reverse;
    use Template::Reverse::Converter::TT2;
    use Data::Dumper;

    my $rev = Template::Reverse->new;

    # generating patterns automatically!!
    my $str1 = "I am perl and smart";
    my $str2 = "I am khs and a perlmania";
    my $parts = $rev->detect($str1, $str2);

    my $tt2 = Template::Reverse::Converter::TT2->new;
    my $temps = $tt2->Convert($parts); # equals ['I am [% value %] and','and [% value %]']


    # spacing text for normalization.
    my $str3 = "I am king of the world and a richest man";
    my $str3spaced = $rev->space($str3);

    # extract!!
    use Template::Extract;
    my $ext = Template::Extract->new;
    my $value = $ext->extract($temps->[0], $str3spaced);
    print Dumper($value); # output : {'value'=>'king of the world'}

    my $value = $ext->extract($temps->[1], $str3spaced);
    print Dumper($value); # output : {'value'=>'a richest man'}

=head1 DESCRIPTION

Template::Reverse detects different parts between pair of similar text as merged texts from same template.
And it can makes an output marked differences, encodes to TT2 format for being use by Template::Extract module.

=head1 FUNCTIONS

=head3 new(OPTION_HASH_REF)

=head4 splitter=>$splitter_pkgname

A splitter splits text into Array by its own rule.
You can set only one splitter at a time.

L<Template::Reverse::Splitter::Whitespace> is a default splitter and splits text by whitespaces.

=head4 spacers=>[$spacer_pkgname, ...]

A spacer inserts spaces by its own rule.
You can set several spacers in order.
A spacer works sequencially before a splitter working.

Not only inserting, removing uninterest things, changing some charaters and etc.

Spacers is reused in $self->space($str) for more exact results.

=head4 sidelen=>$max_length_of_each_side

sidelen is a short of "side character's each max length".
the default value is 10. Setting 0 means full-length.

If you set it as 3, you get max 3 length pre-text and post-text array each part.

This is needed for more faster performance.

=head3 detect($text1, $text2)

Get changable part list from two texts.
It returns like below

    $rev->detect('A b C','A d C');
    #
    # [ [ ['A'],['C'] ] ]
    #   : :...: :...: :     
    #   :  pre  post  :
    #   :.............:  
    #       part 1
    #

    $rev->detect('A b C d E','A f C g E');
    #
    # [ [ ['A'], ['C'] ], [ ['C'], ['E'] ] ]
    #   : :...:  :...: :  : :...:  :...: :
    #   :  pre   post  :  :  pre   post  :
    #   :..............:  :..............:
    #        part 1            part 2
    #

    $rev->detect('A1 A2 B C1 C2 D E1 E2','A1 A2 D C1 C2 F E1 E2');
    #
    # [ [ ['A1','A2'],['C2','C2'] ], [ ['C1','C2'], ['E2','E2'] ] ]
    #

    my $str1 = "I am perl and smart";
    my $str2 = "I am KHS and a perlmania";
    my $parts = $rev->detect($str1, $str2);
    #
    # [ [ ['I','am'], ['and'] ] , [ ['and'],[] ] ]
    #   : :........:  :.....: :   :            :
    #   :    pre       post   :   :            :
    #   :.....................:   :............:
    #           part 1                part 2
    #

Returned arrayRef is list of changable parts.

    1. At first, $text1 and $text2 is normalized by Spacers.
    2. 'pre texts' and 'post texts' are splited by Splitter. In this case, by Whitespace.
    3. You can get a changing value, just finding 'pre' and 'post' in a normalized text.

=head3 space($text)

It returns a processed text by same rule as in detect().
Text are processed by Spacers sequencially.

=head1 SEE ALSO

=item *

L<Template::Extract>

=head1 SOURCE

L<https://github.com/sng2c/Template-Reverse>

=head1 AUTHOR

HyeonSeung Kim <sng2nara@hanmail.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by HyeonSeung Kim.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

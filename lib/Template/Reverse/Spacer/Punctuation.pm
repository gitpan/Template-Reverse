package Template::Reverse::Spacer::Punctuation;

# ABSTRACT: Insert spaces around punctuations.

use Any::Moose;
use namespace::autoclean;

our $VERSION = '0.006'; # VERSION

sub Space{
    my $self = shift;
    my $str = shift;
    return _space($str);
}

sub _space{
    my $str = shift;
    $str =~ s/([~`!\@#\$\%^&*()_+\-=\[\]{};:'",<\.>\/\?\|\\]+)/_punc($`,$1,$')/ge;

    $str =~ s/\s+/ /g;
    $str =~ s/^\s//g;
    $str =~ s/\s$//g;
    return $str;
}
sub _punc{
    my ($p,$m,$n) = @_;

    if( $m =~/[\.,]/ && $p =~ /\d$/ && $n =~ /^\d/  ){
        return $m;
    }
    else{
        return " $m ";
    }
}


__PACKAGE__->meta->make_immutable;
1;

__END__
=pod

=head1 NAME

Template::Reverse::Spacer::Punctuation - Insert spaces around punctuations.

=head1 VERSION

version 0.006

=head1 SYNOPSIS

    package Template::Reverse::Spacer::Punctuation;
    my $num = Template::Reverse::Spacer::Punctuation->new;
    $num->Space('hello,world!!'); # 'hello , world !!'

=head1 AUTHOR

HyeonSeung Kim <sng2nara@hanmail.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by HyeonSeung Kim.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


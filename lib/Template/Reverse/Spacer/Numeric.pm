package Template::Reverse::Spacer::Numeric;

# ABSTRACT: Insert spaces around Numeric word.

use Any::Moose;
use namespace::autoclean;

our $VERSION = '0.02'; # VERSION

sub Space{
    my $self = shift;
    my $str = shift;
    return _space($str);
}

sub _space{
    my $str = shift;
    $str =~ s/([\d\.,]*\d)/_num($`,$1,$')/gme;
    $str =~ s/\s+/ /g;
    $str =~ s/^\s//g;
    $str =~ s/\s$//g;
    return $str;
}

sub _num{
    my ($p,$m,$n) = @_;
    $m =~ s/^[\.,]/$& /;
    $m =~ s/[\.,]$/ $&/;      
    return " $m ";
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

Template::Reverse::Spacer::Numeric - Insert spaces around Numeric word.

=head1 VERSION

version 0.02

=head1 SYNOPSIS

    package Template::Reverse::Spacer::Numeric;
    my $num = Template::Reverse::Spacer::Numeric->new;
    $num->Space('1,000dollers'); # '1,000 dollers'

=head1 AUTHOR

HyeonSeung Kim <sng2nara@hanmail.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by HyeonSeung Kim.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

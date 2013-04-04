package Template::Reverse::Splitter::Whitespace;

# ABSTRACT: Split text by whitespace

use Any::Moose;
use namespace::autoclean;

our $VERSION = '0.01'; # VERSION

sub Split{
    my $self = shift;
    my $str = shift;
    return split(/\s+/,$str);
}


__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

Template::Reverse::Splitter::Whitespace - Split text by whitespace

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    package Template::Reverse::Splitter::Whitespace;
    my $num = Template::Reverse::Splitter::Whitespace->new;
    $num->Split('1,000 dollers'); # ('1,000', 'dollers')

=head1 AUTHOR

HyeonSeung Kim <sng2nara@hanmail.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by HyeonSeung Kim.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

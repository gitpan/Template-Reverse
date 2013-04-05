package Template::Reverse::Spacer::HTML;

# ABSTRACT: Insert spaces around html tags and attrs

use Any::Moose;
use namespace::autoclean;

our $VERSION = '0.02'; # VERSION

sub Space{
    my $self = shift;
    my $str = shift;
    my $spaced = _space($str);
	return $spaced;
}


sub _space{
    my $str = shift;
	
	# around html 
	$str =~ s/<.+?>/ $& /g;
	# around attr
	$str =~ s/=\s*(["']?)([^>\1]+)\1/=$1 $2 $1/g;

    $str =~ s/\s+/ /g;
    $str =~ s/^\s//g;
    $str =~ s/\s$//g;
    return $str;
}


__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

Template::Reverse::Spacer::HTML - Insert spaces around html tags and attrs

=head1 VERSION

version 0.02

=head1 SYNOPSIS

    package Template::Reverse::Spacer::HTML;
    my $num = Template::Reverse::Spacer::HTML->new;
    $num->Space('<a href="http://test.com">TEST</a>'); # '<a href=" http://test.com "> TEST </a>'

=head1 AUTHOR

HyeonSeung Kim <sng2nara@hanmail.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by HyeonSeung Kim.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

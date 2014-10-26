package Template::Reverse::Spacer::HTML;

# ABSTRACT: Insert spaces around html tags and attrs

use Any::Moose;
use namespace::autoclean;

our $VERSION = '0.04'; # VERSION

sub Space{
    my $self = shift;
    my $str = shift;
	$str = _recover_url($str);
    my $spaced = _space($str);
	return $spaced;
}

sub _recover_url{
	my $str = shift;
	$str=~s/(href=['"])([^'"]+)(['"])/$1._removeSpace($2).$3/ge;
	$str=~s/(src=['"])([^'"]+)(['"])/$1._removeSpace($2).$3/ge;
	$str=~s/^(https?:\/\/[^'"]+)$/_removeSpace($1)/ge;
	return $str;
}
sub _removeSpace{
	my $str = shift;
	$str =~ s/\s+//g;
	return $str;
}

sub _space{
    my $str = shift;
	
	# around html 
	$str =~ s/<.+?>/ _tag_space($&) /ge;
	# around attr

    $str =~ s/\s+/ /g;
    $str =~ s/^\s+//g;
    $str =~ s/\s+$//g;
    return $str;
}

sub _tag_space{
	my $str = shift;

	$str =~ s/=\s*(["']?)([^\1>]+)\1/=$1 $2 $1/g;
	return " $str ";
}


__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

Template::Reverse::Spacer::HTML - Insert spaces around html tags and attrs

=head1 VERSION

version 0.04

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

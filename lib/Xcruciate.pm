#! /usr/bin/perl -w

package Xcruciate;
use Exporter;
@ISA = ('Exporter');
@EXPORT = qw();
our $VERSION = 0.04;

use Xcruciate::XcruciateConfig;
use Xcruciate::UnitConfig;

=head1 NAME

Xcruciate - libraries for perl scripts in and around the server project. If
you are looking for help with the Xcruciate project in general, try
'man xcruciate' (with a small x) or the Xcruciate website
(F<http://www.xcruciate.co.uk>).

=head1 SYNOPSIS

There's not a lot to synopse in here. It's a convenient place to hang the
Xcruciate CPAN documentation, and it will cause all the sub-modules to be
loaded too.

=head1 DESCRIPTION

Provides perl functions for interacting with Xcruciate.

=head1 AUTHOR

Mark Howe, E<lt>melonman@cpan.orgE<gt>

=head2 EXPORT

None

=head1 BUGS

The best way to report bugs is via the Xcruciate bugzilla site (F<http://www.xcruciate.co.uk/bugzilla>).

=head1 COMING SOON

More thorough config file error checking.

=head1 PREVIOUS VERSIONS

=over

B<0.01> First upload

B<0.02> First upload containing the module

B<0.03> Fixed formatting, corrected links and generally read the text

B<0.04> Changed minimum perl version to 5.8.8

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 - 2009 by SARL Cyberporte/Menteith Consulting

This library is distributed under BSD licence (F<http://www.xcruciate.co.uk/licence-code>).

=cut

1;

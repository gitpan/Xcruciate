#! /usr/bin/perl -w

package Xcruciate::Utils;
use Exporter;
@ISA = ('Exporter');
@EXPORT = qw();
our $VERSION = 0.09;

use Time::gmtime;
use Carp;

=head1 NAME

Xcruciate::Utils - Utilities for Xcruciate

=head1 SYNOPSIS

check_path('A very nice path',$path,'rw');

=head1 DESCRIPTION

Provides utility functions Xcruciate ( F<http://www.xcruciate.co.uk>). You shouldn't need
to use these directly.

=head1 AUTHOR

Mark Howe, E<lt>melonman@cpan.orgE<gt>

=head2 EXPORT

None

=head1 FUNCTIONS

=head2 check_path(option,path,permissions[,non_fatal])

Checks that the path exists, and that it has the appropriate
permissions, where permissions contains some combination of r, w and x. If not, and if non_fatal is perlishly false,
it dies, using the value of option to produce a semi-intelligable error message. If non_fatal is perlishly true it returns the error or an empty string.

=cut

sub check_path {
    my $option = shift;
    my $path = shift;
    my $permissions = shift;
    my $non_fatal = 0;
    $non_fatal = 1 if $_[0];
    my $error = "";
    if (not(-e $path)) {
	$error = "No file corresponding to path for '$option'";
    } elsif ($permissions =~/r/ and (not -r $path)) {
	$error = "File '$path' for '$option' option is not readable";
    } elsif ($permissions =~/w/ and (not -w $path)) {
	$error = "File '$path' for '$option' option is not writable";
    } elsif ($permissions =~/x/ and (not -x $path)) {
	$error = "File '$path' for '$option' option is not executable";
    };
    if ($non_fatal) {
	return $error;
    } else {
	croak $error;
    }
}

=head2 check_absolute_path(option,path,permissions[,non_fatal])

A lot like &check_path (which it calls), but also checks that the path is
absolute (ie is starts with a /).

=cut

sub check_absolute_path {
    my $option = shift;
    my $path = shift;
    my $permissions = shift;
    my $non_fatal = 0;
    $non_fatal = 1 if defined $_[0];
    if ($path !~ m!^/! and $non_fatal) {
	return "Path for '$option' must be absolute";
    } elsif ($path !~ m!^/!) {
	croak "Path for '$option' must be absolute";	
    } else {
	check_path($option,$path,$permissions,$non_fatal);
    }
}

=head2 type_check(selfhash,name,value,record)

Returns errors on typechecking value against record. Name is provided for error messages. Selfhash might be useful one day. Note that selfhash is not yet blessed.

=cut

sub type_check {
    my $self = shift;
    my $name = shift;
    my $value = shift;
    my $record = shift;
    $value =~s/^\s*(.*?)\s*$/$1/s;
    my @errors = ();
    my $list_name = '';
    $list_name = "Item $_[0] of" if defined $_[0];
    my $datatype = $record->[2];
    if ($datatype eq 'integer') {
	push @errors,sprintf("$list_name Entry called %s should be an integer",$name) unless $value=~/^\d+$/;
	push @errors,sprintf("$list_name Entry called %s is less than minimum permitted value of $record->[3]",$name) if ($value=~/^\d+$/ and (defined $record->[3]) and ($record->[3] > $value));
	push @errors,sprintf("$list_name Entry called %s exceeds permitted value of $record->[4]",$name) if ($value=~/^\d+$/ and (defined $record->[4]) and ($record->[4] < $value));
    } elsif ($datatype eq 'float') {
	push @errors,sprintf("$list_name Entry called %s should be a number",$name) unless $value=~/^-?\d+(\.\d+)$/;
	push @errors,sprintf("$list_name Entry called %s is less than minimum permitted value of $record->[3]",$name) if ($value=~/^-?\d+(\.\d+)$/ and (defined $record->[3]) and ($record->[3] > $value));
	push @errors,sprintf("$list_name Entry called %s exceeds permitted value of $record->[4]",$name) if ($value=~/^-?\d+(\.\d+)$/ and (defined $record->[4]) and ($record->[4] < $value));
    } elsif ($datatype eq 'ip') {
	push @errors,sprintf("$list_name Entry called %s should be an ip address",$name) unless $value=~/^\d\d?\d?\.\d\d?\d?\.\d\d?\d?\.\d\d?\d?$/;
    } elsif ($datatype eq 'cidr') {
	push @errors,sprintf("$list_name Entry called %s should be a CIDR ip range",$name) unless $value=~m!^\d\d?\d?\.\d\d?\d?\.\d\d?\d?\.\d\d?\d?/\d\d?$!;
    } elsif ($datatype eq 'xml_leaf') {
	push @errors,sprintf("$list_name Entry called %s should be an xml filename",$name) unless $value=~/^[A-Za-z0-9_-]+\.xml$/;
    } elsif ($datatype eq 'xsl_leaf') {
	push @errors,sprintf("$list_name Entry called %s should be an xsl filename",$name) unless $value=~/^[A-Za-z0-9_-]+\.xsl$/;
    } elsif ($datatype eq 'yes_no') {
	push @errors,sprintf("$list_name Entry called %s should be 'yes' or 'no'",$name) unless $value=~/^(yes)|(no)$/;
    } elsif ($datatype eq 'word') {
	push @errors,sprintf("$list_name Entry called %s should be a word (ie no whitespace)",$name) unless $value=~/^\S+$/;
    } elsif ($datatype eq 'function_name') {
	push @errors,sprintf("$list_name Entry called %s should be an xpath function name",$name) unless $value=~/^[^\s:]+(:\S+)?$/;
    } elsif ($datatype eq 'path') {
	push @errors,sprintf("$list_name Entry called %s should be a path",$name) unless $value=~/^\S+$/;
    } elsif ($datatype eq 'email') {
	push @errors,sprintf("$list_name Entry called %s should be an email address",$name) unless $value=~/^[^\s@]+\@[^\s@]+$/;
    } elsif (($datatype eq 'abs_file') or ($datatype eq 'abs_dir')) {
	push @errors,sprintf("$list_name Entry called %s should be absolute (ie it should start with /)",$name) unless $value=~/^\//;
	push @errors,sprintf("No file or directory corresponds to $list_name entry called %s",$name) unless -e $value;
	if (-e $value) {
	    push @errors,sprintf("$list_name Entry called %s should be a file, not a directory",$name) if ((-d $value) and ($datatype eq 'abs_file'));
	    push @errors,sprintf("$list_name Entry called %s should be a directory, not a file",$name) if ((-f $value) and ($datatype eq 'abs_dir'));
	    push @errors,sprintf("$list_name Entry called %s must be readable",$name) if ($record->[3]=~/r/ and not -r $value);
	    push @errors,sprintf("$list_name Entry called %s must be writable",$name) if ($record->[3]=~/w/ and not -w $value);
	    push @errors,sprintf("$list_name Entry called %s must be executable",$name) if ($record->[3]=~/x/ and not -x $value);
	}
    } elsif ($datatype eq 'abs_create'){
	$value=~m!^(.*/)?([^/]+$)!;
	my $dir = $1;
	push @errors,sprintf("$list_name Entry called %s should be absolute (ie it should start with /)",$name) unless $value=~/^\//;
	push @errors,sprintf("$list_name No file or directory corresponds to entry called %s, and insufficient rights to create one",$name) if ((not -e $value) and ((not $dir) or (-d $dir) and ((not -r $dir) or (not -w $dir) or (not -x $dir))));
	push @errors,sprintf("$list_name Entry called %s must be readable",$name) if ($record->[3]=~/r/ and -e $value and not -r $value);
	push @errors,sprintf("$list_name Entry called %s must be writable",$name) if ($record->[3]=~/w/ and -e $value and  not -w $value);
	push @errors,sprintf("$list_name Entry called %s must be executable",$name) if ($record->[3]=~/x/ and -e $value and not -x $value);
    } elsif ($datatype eq 'debug_list') {
	if ($value!~/,/) {
	    push @errors,sprintf("$list_name Entry called %s cannot include '%s'",$name,$value) unless $value=~/^((none)|(all)|(timer-io)|(non-timer-io)|(io)|(show-wrappers)|(connections)|(doc-cache)|(channels)|(stack)|(update))$/;
	} else {
	    foreach my $v (split /\s*,\s*/,$value) {
	    push @errors,sprintf("$list_name Entry called %s cannot include 'all' or 'none' in a comma-separated list",$name) if $v=~/^((none)|(all))$/;
	    push @errors,sprintf("$list_name Entry called %s cannot include '%s'",$name,$v) unless $v=~/^((none)|(all)|(timer-io)|(non-timer-io)|(io)|(show-wrappers)|(connections)|(doc-cache)|(channels)|(stack)|(update))$/;
	    }
	}
    } else {
	croak sprintf("Unknown unit config datatype %s",$datatype);
    }
    return @errors;
}

=head2 apache_time(epoch_time)

Produces an apache-style timestamp from an epoch time.

=cut

sub apache_time {
    my $epoch_time = shift;
    my $time = gmtime($epoch_time);
    my @days = qw(Sun Mon Tue Wed Thu Fri Sat);
    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    return sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT",
		   $days[$time->wday],
		   $time->mday,
		   $months[$time->mon],
		   $time->year+1900,
		   $time->hour,
		   $time->min,
		   $time->sec);
}

=head2 datetime(epoch_time)

Converts GMT epoch time to the format expected by XSLT date functions.

=cut

sub datetime {#Converts GMT epoch time to the format expected by XSLT date functions
    my $epoch_time = shift;
    my $time = gmtime($epoch_time);
    return sprintf("%04d-%02d-%02dT%02d:%02d:%02d+00:00",
		   $time->year+1900,
		   $time->mon+1,
		   $time->mday,
		   $time->hour,
		   $time->min,
		   $time->sec)
}

=head2 index_docroot($docroot_path,$mimetypes_hash)

Returns XML describing the contents of $docroot_path.

=cut

sub index_docroot {
    my $docroot = shift;
    my $mimetypes = shift;
    my $ndirs = 0;
    my $nfiles = 0;

    my $dir_xml;
    my $dir_writer = XML::Writer->new(OUTPUT => \$dir_xml);
    $dir_writer->startTag("directories");
    
    opendir(DIR,$docroot) or croak "Cannot opendir '$docroot': $!";
    while (defined(my $file = readdir(DIR))) {
	next unless $file=~/^[^.\s]+$/;
	next unless -d "$docroot/$file";
	$ndirs++;
	$dir_writer->startTag("directory","url_path"=>$file,"local_path"=>$file);
	opendir(DIR2,"$docroot/$file") or croak "Cannot opendir '$docroot/$file': $!";
	while (defined(my $file2 = readdir(DIR2))) {
	    next unless $file2=~/^[^.\s]+\.([^.\s~%]+)$/;
	    my $suffix = $1;
	    next unless -f "$docroot/$file/$file2";
	    $nfiles++;
	    $dir_writer->emptyTag("file","url_name"=>$file2,"local_name"=>$file2,"size"=>(-s "$docroot/$file/$file2"),"utime"=>Xcruciate::Utils::datetime((stat("$docroot/$file/$file2"))[9]),"document_type"=>($mimetypes->{$suffix} || 'text/plain'));
	}
	closedir(DIR2);
	$dir_writer->endTag;
    }
    closedir(DIR);
    
    $dir_writer->endTag;
    $dir_writer->end;
    
    return $dir_xml;
}

=head1 BUGS

The best way to report bugs is via the Xcruciate bugzilla site (F<http://www.xcruciate.co.uk/bugzilla>).

=head1 COMING SOON

A lot more code that is currently spread across assorted scripts, probably split into several modules.

=head1 PREVIOUS VERSIONS

B<0.01>: First upload

B<0.03>: First upload containing module

B<0.04>: Changed minimum perl version to 5.8.8

B<0.05>: Added debug_list data type, fixed uninitialised variable error when numbers aren't.

B<0.07>: Attempt to put all Xcruciate modules in one PAUSE tarball.

B<0.08>: Added index_docroot (previously inline code in xcruciate script)

B<0.09>: Fixed typo in error message. Use Carp for errors. Non-fatal option for check_path()

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 - 2009 by SARL Cyberporte/Menteith Consulting

This library is distributed under BSD licence (F<http://www.xcruciate.co.uk/licence-code>).

=cut

1;

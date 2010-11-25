#######################################################################
# $Id: Directory.pm,v 1.11 2010-11-25 20:13:56 dpchrist Exp $
#######################################################################
# package:
#----------------------------------------------------------------------

package Dpchrist::Directory;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	dirdiff	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = sprintf("%d.%03d", q$Revision: 1.11 $ =~ /(\d+)/g);

#######################################################################
# uses:
#----------------------------------------------------------------------

use constant			DEBUG => 0;

use Carp;
use Dpchrist::Debug		qw( :all );
use File::Spec::Functions	qw( :ALL );

#######################################################################
# globals:
#----------------------------------------------------------------------

our %opt = (
    -fatdt	=> 3,
);

#######################################################################

=head1 NAME

Dpchrist::Directory - utility subroutines for directories


=head1 DESCRIPTION

This documentation describes module revision $Revision: 1.11 $.


This is alpha test level software
and may change or disappear at any time.


=head2 SUBROUTINES

=cut

#######################################################################

=head3 dirdiff

    dirdiff DIR1,DIR2

Recursively compares two directories DIR1 and DIR2,
printing messages as differences are found,
and returns a hash reference with statistics:

    {
	-ndifferences	=> 0,	# number of differences
	-ndirs		=> 0,	# number of directories
	-nerrors	=> 0,	# number of errors
	-nexcluded	=> 0,	# number of items excluded
	-nfiles		=> 0,	# number of files
    }

Options may be set via %Dpchrist::Directory::opt:

=over

=item -exclude => GLOBSPEC

    Skip files and/or directories matching GLOBSPEC.

=item -fat => BOOL

    Use a delta time of 3 seconds when comparing file mtime's
    (for FAT filesystems).

=item -ignoremtime => BOOL

    Ignore mtime when comparing files.

=item -ignoresize => BOOL

    Ignore size when comparing files.

=item -verbose => BOOL

    Print extra information during operation.

=back

Calls Carp::confess() on fatal errors.

=cut

#----------------------------------------------------------------------

sub dirdiff
{
    ddump 'entry', [\@_], [qw(*_)] if DEBUG;

    my %retval = (
	-ndifferences	=> 0,
	-ndirs		=> 0,
	-nerrors	=> 0,
	-nexcluded	=> 0,
	-nfiles		=> 0,
    );


    ##### process arguments:

    my ($dir1, $dir2) = @_;

    unless (defined $dir1 && -d $dir1
	    && defined $dir2 && -d $dir2) {
	warn join(' ', 'Argument(s) are not directory(s)',
	    Data::Dumper->Dump([\@_], [qw(*_)]),
	);
	$retval{-nerrors}++;
	goto DONE;
    }

    ### read directories:

    unless (opendir(D1, $dir1)) {
	warn "Failed to open directory '$dir1': $!";
	$retval{-nerrors}++;
	goto DONE;
    }
    my @dir1 = readdir(D1);
    closedir(D1);
    ddump [\@dir1], [qw(*dir1)] if DEBUG;

    unless (opendir(D2, $dir2)) {
	warn "Failed to open directory '$dir2': $!";
	$retval{-nerrors}++;
	goto DONE;
    }
    my @dir2 = readdir(D2);
    closedir(D2);
    ddump [\@dir2], [qw(*dir2)] if DEBUG;

    if ($opt{-exclude}) {
	my %ex1 = map {((splitpath($_))[2], 1)}
		      glob(catfile($dir1, $opt{-exclude}));
	ddump [\%ex1], [qw(*ex1)] if DEBUG;

	if (%ex1) {
	    foreach(sort keys %ex1) {
		print "EXCLUDING $dir1/$_\n" if $opt{-verbose};
		$retval{-nexcluded}++;
	    }
	}

	@dir1 = grep { ! $ex1{$_} } @dir1;
	ddump [\@dir1], [qw(*dir1)] if DEBUG;

	my %ex2 = map {((splitpath($_))[2], 1)}
		      glob(catfile($dir2, $opt{-exclude}));
	ddump [\%ex2], [qw(*ex2)] if DEBUG;

	if (%ex2) {
	    foreach(sort keys %ex2) {
		print "EXCLUDING $dir2/$_\n" if $opt{-verbose};
		$retval{-nexcluded}++;
	    }
	}

	@dir2 = grep { ! $ex2{$_} } @dir2;
	ddump [\@dir2], [qw(*dir2)] if DEBUG;
    }

    ##### Find common entries:
    
    my @list = (@dir1, @dir2);
    my %seen = ();
    my @common = grep { ! $seen{$_} ++ } @list;
    ddump [\@common], [qw(*common)] if DEBUG;
    
    ##### Examine set of common entries:
    
    foreach my $direntry (sort @common) {

	ddump [$direntry], [qw(direntry)] if DEBUG;

	##### Skip current directory and parent:
	
	next if $direntry =~ /^\.$/ || $direntry =~ /^\.\.$/;

	##### Formulate paths to entry in both directories:
	
	my $path1 = catfile($dir1, $direntry);
	my $path2 = catfile($dir2, $direntry);

	##### Examine items:

	unless (-e $path1) {
	    print "SRC_MISSING $path1\n";
	    $retval{-ndifferences}++;
	    next;
	}
	my @stat1 = stat(_);
	unless (@stat1) {
	    warn "Failed stat() on path '$path1': $!";
	    $retval{-nerrors}++;
	    next;
	}
	my $size1  = $stat1[7];
    	my $mtime1 = $stat1[9];
	my $isdir1 = (-d $path1);

	unless (-e $path2) {
	    print "DEST_MISSING $path2\n";
	    $retval{-ndifferences}++;
	    next;
	}
	my @stat2 = stat(_);
	unless (@stat1) {
	    warn "Failed stat() on path '$path2': $!";
	    $retval{-nerrors}++;
	    next;
	}
	my $size2  = $stat2[7];
    	my $mtime2 = $stat2[9];
	my $isdir2 = (-d $path2);

	if ( !$isdir1 && !$isdir2 ) {
	    
	    ### both items are files:
	
	    $retval{-nfiles}++;

	    unless ($opt{-ignoremtime}) {
		my $dt = abs($mtime1 - $mtime2);

		my $samemtime = $opt{-fat}
			      ? $dt <= $opt{-fatdt}
			      : $dt == 0;

		unless ($samemtime) {
		    if ($mtime1 < $mtime2) {
			print "DEST_IS_NEWER $path2\n";
			$retval{-ndifferences}++;
		    }
		    elsif ($mtime1 > $mtime2) {
			print "DEST_IS_OLDER $path2\n";
			$retval{-ndifferences}++;
		    }
		}
	    }

	    unless ($opt{-ignoresize}) {
		my $samesize = ($size1 == $size2);

		if ($size1 < $size2) {
		    print "DEST_IS_LARGER $path2\n";
		    $retval{-ndifferences}++;
		}
		elsif ($size1 > $size2) {
		    print "DEST_IS_SMALLER $path2\n";
		    $retval{-ndifferences}++;
		}
	    }
	}
	elsif ( $isdir1 && $isdir2 ) {

	    ##### Items are directories:

	    $retval{-ndirs}++;

	    my $r = dirdiff($path1, $path2);

	    ddump [\%retval, $r], [qw(*retval r)] if DEBUG;

	    foreach my $key (keys %retval) {
		$retval{$key} += $r->{$key};
	    }

	    ddump [\%retval], [qw(*retval)] if DEBUG;
	}
	elsif ( $isdir1 ) {

	    print "DEST_NOT_DIRECTORY $path2\n";
	    $retval{-ndifferences}++;
	}
	elsif ( $isdir2 ) {

	    print "DEST_IS_DIRECTORY $path2\n";
	    $retval{-ndifferences}++;
	}
	else {

	    confess "Unhandled case for '$path1' and '$path2'";
	}
    }
  DONE:
    
    ddump 'returning', [\%retval], [qw(retval)] if DEBUG;
    return \%retval;
}

#######################################################################
# end of code:
#----------------------------------------------------------------------

1;

__END__

#######################################################################

=head2 EXPORT

None by default.

All of the subroutines may be imported by using the ':all' tag:

    use Dpchrist::Debug		qw( :all );

See 'perldoc Export' for everything in between.


=head1 INSTALLATION

    perl Makefile.PL
    make
    make test
    make install


=head1 DEPENDENCIES

    Dpchirst::Debug
    Dpchrist::Module
 

=head1 AUTHOR

David Paul Christensen  dpchrist@holgerdanske.com


=head1 COPYRIGHT AND LICENSE

Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
USA.

=cut

#######################################################################

#######################################################################
# $Id: Makefile.PL,v 1.12 2010-12-01 19:00:21 dpchrist Exp $
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
# USA.
#######################################################################

package Dpchrist::ExtUtils::MakeMaker;	# for symbols

use ExtUtils::MakeMaker;

eval "use Test::Manifest";
warn $@ if $@;

eval {
    require Dpchrist::ExtUtils::MakeMaker;
    import  Dpchrist::ExtUtils::MakeMaker (
	postamble => sub {
	    my ($o, $prev) = @_;
	    return join('',
		$prev,
		mcpani  ($o, $ENV{CPAN_AUTHORID}),
		pod2html($o, qw( lib/Dpchrist/Directory.pm
				 perl-bin/dirdiff )),
		readme  ($o, 'lib/Dpchrist/Directory.pm'),
		release ($o, $ENV{RELEASE_ROOT}),
	    );
	},
    );
};
warn $@ if $@;

WriteMakefile(
    NAME		=> 'Dpchrist::Directory',
    VERSION_FROM	=> 'lib/Dpchrist/Directory.pm',
    PREREQ_PM		=> {
	Dpchrist::Debug		=> 1.046,
    },
    ABSTRACT_FROM	=> 'lib/Dpchrist/Directory.pm',
    AUTHOR		=>
	'David Paul Christensen <dpchrist@holgerdanske.com>',
    EXE_FILES		=> ['./perl-bin/dirdiff'],
    clean		=> {
	FILES => q( *~tmp */*~tmp *.tar debug.log )
    },
);

#######################################################################

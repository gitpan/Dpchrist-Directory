#######################################################################
# $Id: Makefile.PL,v 1.6 2010-11-25 02:19:25 dpchrist Exp $
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

use ExtUtils::MakeMaker;

use Dpchrist::Module::MakefilePL (
    -mcpani		=> $ENV{CPAN_AUTHORID},
    -pod2html	 	=> [ qw(
	lib/Dpchrist/Directory.pm
	bin/dirdiff
    ) ],
    -release		=> $ENV{RELEASE_ROOT},
);

WriteMakefile(
    NAME		=> 'Dpchrist::Directory',
    VERSION_FROM	=> 'lib/Dpchrist/Directory.pm',
    PREREQ_PM		=> {
	'Dpchrist::Debug'	=> 1.036,
	'Dpchrist::Module'	=> 1.016,
	'feature'		=> 0,
    },
    ABSTRACT_FROM	=> 'lib/Dpchrist/Directory.pm',
    AUTHOR		=>
	'David Paul Christensen <dpchrist@holgerdanske.com>',
    EXE_FILES		=> ['./bin/dirdiff'],
    clean		=> { FILES =>
	q( *~tmp */*~tmp Dpchrist* dirdiff* )
    },
);

#######################################################################

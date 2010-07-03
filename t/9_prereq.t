# $Id: 9_prereq.t,v 1.1 2009-10-29 20:53:00 dpchrist Exp $
use Test::More;
eval "use Test::Prereq";
plan skip_all => "Test::Prereq required to test dependencies" if $@;
prereq_ok();

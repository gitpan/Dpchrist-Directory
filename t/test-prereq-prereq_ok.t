# $Id: test-prereq-prereq_ok.t,v 1.1 2010-11-28 06:42:48 dpchrist Exp $
use Test::More;
eval "use Test::Prereq";
plan skip_all => "Test::Prereq required to test dependencies" if $@;
prereq_ok();

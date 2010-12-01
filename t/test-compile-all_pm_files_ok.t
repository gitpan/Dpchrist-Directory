# $Id: test-compile-all_pm_files_ok.t,v 1.1 2010-11-28 06:42:48 dpchrist Exp $
use Test::More;
eval "use Test::Compile 0.09";
plan skip_all => "Test::Compile 0.09 required for testing compilation"
if $@;
all_pm_files_ok();

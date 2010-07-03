# $Id: 0_compile_modules.t,v 1.2 2009-10-30 05:30:03 dpchrist Exp $
use Test::More;
eval "use Test::Compile 0.09";
plan skip_all => "Test::Compile 0.09 required for testing compilation"
if $@;
all_pm_files_ok();

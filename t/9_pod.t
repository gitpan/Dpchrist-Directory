# $Id: 9_pod.t,v 1.2 2009-10-30 05:30:03 dpchrist Exp $
use Test::More;
eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok();

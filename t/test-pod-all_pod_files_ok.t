# $Id: test-pod-all_pod_files_ok.t,v 1.1 2010-11-28 06:42:48 dpchrist Exp $
use Test::More;
eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok();

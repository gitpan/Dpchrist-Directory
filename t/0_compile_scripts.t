use Test::More;
eval "use Test::Compile 0.09";
plan skip_all => "Test::Compile 0.09 required for testing compilation"
if $@;
my @pl_dirs = qw( bin cgi-bin example research );
all_pl_files_ok( all_pl_files(@pl_dirs) );

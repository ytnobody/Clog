use strict;
use warnings;
use Test::More;
use t::Util;
use Plack::Test;
use Clog;
use HTTP::Request::Common;

my $app = Clog->run(test_config());

test_psgi $app => sub {
    my $cb = shift;
    my $res = $cb->(GET '/');
    is $res->code, 200;
};

done_testing;

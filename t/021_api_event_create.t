use strict;
use warnings;
use utf8;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use JSON;
use t::Util;
use Clog;

my $json = JSON->new;

my $app = Clog->run(test_config());

subtest 'success' => sub {
    test_psgi $app => sub {
        my $cb = shift;
        my $res = $cb->(POST '/api/event/new', [
            title      => 'ytnobody birthday party',
            begin_time => '2013-11-13 00:00:00',
            end_time   => '2013-11-14 12:00:00',
            created_by => 'ytnobody@ytnobody.net',
            note       => 'this is a 33th birth day!',
            tags       => [qw/party friends/],
        ]);
        is $res->code, 200, sprintf('content is %s', $res->content);
        diag explain($json->decode($res->content));
    };
};

done_testing;

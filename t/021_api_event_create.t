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
        my $expect = {
            'row' => {
              'begin_time' => '2013-11-13 00:00:00',
              'created_by' => 'ytnobody@ytnobody.net',
              'end_time'   => '2013-11-14 12:00:00',
              'id'         => 1,
              'note'       => 'this is a 33th birth day!',
              'tags'       => 'friends',
              'title'      => 'ytnobody birthday party',
            },
            'status' => 1
        };
        my $content = $json->decode($res->content);
        is(delete $content->{row}{created_at}, delete $content->{row}{updated_at});
        is_deeply($content, $expect);
    };
};

subtest 'void request' => sub {
    test_psgi $app => sub {
        my $cb = shift;
        my $res = $cb->(POST '/api/event/new', []);
        my $expect = {
            'errors' => [
              'please input begin_time',
              'please input created_by',
              'please input end_time',
              'please input title',
            ],
            'status' => 0
        };

        is_deeply($json->decode($res->content), $expect);
    };
};

subtest 'missing title' => sub {
    test_psgi $app => sub {
        my $cb = shift;
        my $res = $cb->(POST '/api/event/new', [
            title      => undef,
            begin_time => '2013-11-13 00:00:00',
            end_time   => '2013-11-14 12:00:00',
            created_by => 'ytnobody@ytnobody.net',
            note       => 'this is a 33th birth day!',
            tags       => [qw/party friends/],
        ]);
        my $expect = {
            'errors' => [
              'please input title',
            ],
            'status' => 0
        };
        is_deeply($json->decode($res->content), $expect);
    };
};

# subtest 'missing datetime' => sub {
#     test_psgi $app => sub {
#         my $cb = shift;
#         my $res = $cb->(POST '/api/event/new', [
#             title      => 'foolish night',
#             begin_time => '2013-11hjfdsaghjklasjgfklsa;jfkla',
#             end_time   => '2013-11-14 12:00:00',
#             created_by => 'ytnobody@ytnobody.net',
#             note       => 'this is a 33th birth day!',
#             tags       => [qw/party friends/],
#         ]);
#         my $expect = {
#             'errors' => [
#               'please input title',
#             ],
#             'status' => 0
#         };
#         is_deeply($json->decode($res->content), $expect);
#     };
# };

done_testing;

use strict;
use warnings;
use Plack::Builder;
use Plack::Session::Store::Cache;
use Cache::SharedMemoryCache;
use File::Spec;
use File::Basename 'dirname';
use lib (
    File::Spec->catdir(dirname(__FILE__), 'lib'), 
);
use Clog;

my $config_file = File::Spec->rel2abs(File::Spec->catfile(dirname(__FILE__), 'config.pl'));
my $config = require($config_file);

my $app           = Clog->run(%$config);
my $root          = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__)));
my $session_cache = Cache::SharedMemoryCache->new({
    namespace          => 'Clog',
    default_expires_in => 600,
});

builder {
    enable_if { $ENV{PLACK_ENV} =~ /^dev/ } 'StackTrace', force => 1;
    enable 'Static', (
        root => $root,
        path => qr{^/static/},
    );
    enable 'Session', (
        store => Plack::Session::Store::Cache->new(
            cache => $session_cache,
        ),
    );
    enable 'CSRFBlock';
    $app;
};


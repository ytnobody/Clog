on 'test' => sub {
    requires 'Test::More' => 0;
};
requires 'Nephia'                              => 0.80;
requires 'Nephia::Plugin::Otogiri'             => 0;
requires 'Nephia::Plugin::FormValidator::Lite' => 0;
requires 'Cache::Cache'                        => 0;
requires 'Plack::Middleware::CSRFBlock'        => 0;

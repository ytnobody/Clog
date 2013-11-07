on 'test' => sub {
    requires 'Test::More' => 0;
    requires 'File::Spec';
    requires 'File::Temp';
};
requires 'Nephia'                              => 0.84;
requires 'Nephia::Plugin::View::Xslate'        => 0;
requires 'Nephia::Plugin::Otogiri'             => 0;
requires 'Nephia::Plugin::FormValidator::Lite' => 0;
requires 'Cache::Cache'                        => 0;
requires 'Plack::Middleware::CSRFBlock'        => 0;
requires 'File::Spec';
requires 'File::Temp';

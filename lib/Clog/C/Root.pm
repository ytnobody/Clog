package Clog::C::Root;

sub index {
    my $c = shift;
    my @rows = $c->db->select(event => {}, {order_by => 'id DESC'});
    {template => 'index.tx', appname => 'Clog', rows => \@rows};
};

1;

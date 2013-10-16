package Clog::Validator::Constraint;
use strict;
use warnings;
use FormValidator::Lite::Constraint;
use Time::Piece;

rule 'DATETIME' => sub {
    Time::Piece->strptime($_, '%Y-%m-%d %H:%M:%S');
};

1;

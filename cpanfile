requires 'perl', 'v5.14';

requires 'App::Greple', '8.58';
requires 'App::sdif', '4.22.3';

on 'test' => sub {
    requires 'Test::More', '0.98';
};


#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

# Disable epoll, kqueue and IPv6
BEGIN { $ENV{MOJO_POLL} = $ENV{MOJO_NO_IPV6} = 1 }

use Test::More;
use Test::Mojo;
use Mojolicious::Lite;
use Cwd qw(cwd);
plugin 'DevexpressHelpers';
push @{ app->static->paths }, cwd . '/t/fixtures/js';
plugin 'AssetPack';
app->asset( 'test.js' => 'test-framework.js' );
app->asset( 'other.js' => 'other-framework.js' );
app->log->level('error'); #silence

# routes
get '/' => 'index';
get '/two' => 'two';

# Test
my $t = Test::Mojo->new;

# GET / default
$t->get_ok('/')
    ->status_is(200)
    ->element_exists('head > script[src^="/packed/test-framework-"]')
    ->or(sub { diag $t->tx->res->to_string });

# GET / default
$t->get_ok('/two')
    ->status_is(200)
    ->element_exists('head > script[src^="/packed/test-framework-"]')
    ->element_exists('head > script[src^="/packed/other-framework-"]')
    ->or(sub { diag $t->tx->res->to_string });

done_testing;

__DATA__
@@ index.html.ep
% layout 'main';
% require_asset 'test.js';

@@ two.html.ep
% layout 'main';
% require_asset 'test.js';
% require_asset 'other.js';

@@ layouts/main.html.ep
<!doctype html>
<html>
    <head>
       <title>Test</title>
       %# %= asset "test.js"
       %= required_assets
    </head>
    <body>
</body>
</html>
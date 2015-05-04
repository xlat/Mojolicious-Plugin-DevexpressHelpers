#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

# Disable epoll, kqueue and IPv6
BEGIN { $ENV{MOJO_POLL} = $ENV{MOJO_NO_IPV6} = 1 }

use Mojo::IOLoop;
use Test::More;
use Test::Mojo;
use Mojolicious::Lite;
plugin 'DevexpressHelpers';
app->log->level('error'); #silence

# routes
get '/' => 'index';
get '/with_type' => 'with_type';

# Test
my $t = Test::Mojo->new;

# GET / default
$t->get_ok('/')->status_is(200)->content_is(<<'EOF');
<!doctype html>
<html>
    <head>
       <title>Test</title>
    </head>
    <body><div id="dxctl1"></div>

<script language="javascript">$(function(){$("#dxctl1").dxButton({onClick: "/action/button1",
text: "Test button"});});</script>
</body>
</html>
EOF

$t->get_ok('/with_type')->status_is(200)->content_is(<<'EOF');
<!doctype html>
<html>
    <head>
       <title>Test</title>
    </head>
    <body><div id="dxctl1"></div>

<script language="javascript">$(function(){$("#dxctl1").dxButton({onClick: "/action/button1",
text: "Test danger button",
type: "danger"});});</script>
</body>
</html>
EOF

done_testing;

__DATA__
@@ index.html.ep
% layout 'main';
%= dxbutton 'Test button' => '/action/button1'

@@ with_type.html.ep
% layout 'main';
%= dxbutton 'Test danger button' => '/action/button1', { type => 'danger' }

@@ layouts/main.html.ep
<!doctype html>
<html>
    <head>
       <title>Test</title>
    </head>
    <body><%== content %>
%= dxbuild
</body>
</html>
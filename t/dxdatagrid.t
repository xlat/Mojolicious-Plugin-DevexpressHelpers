#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

# Disable epoll, kqueue and IPv6
BEGIN { $ENV{MOJO_POLL} = $ENV{MOJO_NO_IPV6} = 1 }

use Test::More;
use Test::Mojo;
use Mojolicious::Lite;
plugin 'DevexpressHelpers';
app->log->level('error'); #silence

# routes
get '/' => 'index';
get '/customstore' => 'customstore';

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

<script language="javascript">$(function(){$("#dxctl1").dxDataGrid({columns: ["id","name",{"cellTemplate":function(c,o){ return 42 }},{"allowFiltering":false}],
dataSource: {store:{type:'odata',url:'/web-service.json'}}});});</script>
</body>
</html>
EOF

# GET /customstore
$t->get_ok('/customstore')->status_is(200)->content_is(<<'EOF');
<!doctype html>
<html>
    <head>
       <title>Test</title>
    </head>
    <body><div id="dxctl1"></div>

<script language="javascript">$(function(){$("#dxctl1").dxDataGrid({columns: ["id","name",{"cellTemplate":function(c,o){ return 42 }},{"allowFiltering":false}],
dataSource: SERVICES.myEntity});});</script>
</body>
</html>
EOF

done_testing;

__DATA__
@@ index.html.ep
% layout 'main';
%= dxdatagrid '/web-service.json' => { columns => [ qw(id name), { cellTemplate => \q{function(c,o){ return 42 }}}, {allowFiltering => false} ] }

@@ customstore.html.ep
% layout 'main';
%= dxdatagrid \'SERVICES.myEntity' => { columns => [ qw(id name), { cellTemplate => \q{function(c,o){ return 42 }}}, {allowFiltering => false} ] }

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
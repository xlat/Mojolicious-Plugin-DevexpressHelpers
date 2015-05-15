package Mojolicious::Plugin::DevexpressHelpers;

#ABSTRACT: Add some helpers to add and configure Devexpress controls
use Modern::Perl;
use Mojo::Base 'Mojolicious::Plugin';
use Mojolicious::Plugin::DevexpressHelpers::Helpers;
use MojoX::AlmostJSON;
=head1 NAME

Mojolicious::Plugin::DevexpressHelpers - Add some helpers to add and configure Devexpress controls

=cut



=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    plugin 'DevexpressHelpers' => {
            dx_path => 'c:/Program Files (x86)/DevExpress 14.2/DevExtreme/Sources/Lib',
            dx_theme  => 'light',
        };
        
    ...
    %= dxbutton 'My button' => '/my/action'
    %= dxbutton 'My button' => q{function (){ alert('on_clicked!') }};
    %= dxbutton 'My button' => { 
            onClick => q{function (){ alert('on_clicked!') }},
            class => [qw( my_class1 my_class2 )],
        };

=head1 HELPERS

A list of functions are exported by default.

=head2 register

Plugin entry point, internaly used by Mojolicious Plugin API.

=cut

sub register {
    my ($self, $app, $args) = @_;
    
    #TODO: add assetpack
    #plugin "AssetPack";
    #app->asset( ... );
    
    my $tp = $args->{'tag_prefix'} // 'dx';
    
    $app->helper( 'require_asset' => \&Mojolicious::Plugin::DevexpressHelpers::Helpers::require_asset );
    $app->helper( 'required_assets' => \&Mojolicious::Plugin::DevexpressHelpers::Helpers::required_assets );
    $app->helper( 'dxbuild' => \&Mojolicious::Plugin::DevexpressHelpers::Helpers::dxbuild );
    $app->helper( $tp.'button' => \&Mojolicious::Plugin::DevexpressHelpers::Helpers::dxbutton );
    $app->helper( $tp.'datagrid' => \&Mojolicious::Plugin::DevexpressHelpers::Helpers::dxdatagrid );
    
    #make json boolean easier to write within templates
    $app->helper( 'true' => \&MojoX::AlmostJSON::true );
    $app->helper( 'false' => \&MojoX::AlmostJSON::false );
    
    $app->hook(before_dispatch => sub{
        my $c = shift;
        #create a new object that will help to generate binding for dx controls
        $c->stash('dxHelper' => Mojolicious::Plugin::DevexpressHelpers::Helpers->new );
    });
    
}

=head1 AUTHOR

Nicolas Georges, C<< <xlat at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-Mojolicious-plugin-devexpresshelpers at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojolicious-Plugin-DevexpressHelpers>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojolicious::Plugin::DevexpressHelpers


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-DevexpressHelpers>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-DevexpressHelpers>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-DevexpressHelpers>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-DevexpressHelpers/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Nicolas Georges.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Mojolicious::Plugin::DevexpressHelpers

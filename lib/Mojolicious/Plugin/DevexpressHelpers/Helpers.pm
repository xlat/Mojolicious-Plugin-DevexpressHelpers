use utf8;
package Mojolicious::Plugin::DevexpressHelpers::Helpers;

#ABSTRACT: Helpers for Devexpress controls are defined here
use Modern::Perl;
use Mojo::ByteStream;
use MojoX::AlmostJSON qw(encode_json);
use constant DEBUG => 0;

#Not sure why C<out> function have to decode from utf8,
#but it make my day!
our $OUT_DECODE = 'UTF-8';

=head1 SUBROUTINES/METHODS

=cut

=head2 out

Output string in template

	out '<div id="'.$id.'"></div>';

=cut
sub out{
	my $tag = shift;
	my $bytes = Mojo::ByteStream->new($tag);
	return $bytes->decode($OUT_DECODE) if defined $OUT_DECODE;
	return $bytes;
}

=head2 new

Internal usage.

	my $dxHelper = Mojolicous::Plugin::DevexpressHelpers::Helpers->new;
	$c->stash( dxHelper => $dxHelper );

=cut
sub new{
	my $class = shift;
	my $self = bless { 
			next_id => 1,
			bindings => '',
		}, $class;
	return $self;
}

=head2 add_binding

Internal usage.

	$dxHelper->add_binding($binding, [$binding2,...] );

=cut
sub add_binding{
	my $self = shift;
	$self->{bindings} .= join "\n", @_;
}

=head2 next_id

Internal usage.

	my $next_id_number = $dxHelper->next_id;

=cut
sub next_id{
	my $self = shift;
	return "dxctl".($self->{next_id}++);
}

=head2 new_id

Internal usage.

	my $new_id = $dxHelper->new_id;

=cut
sub new_id{
	my ($c, $attrs) = @_;
	#should compute a new uniq id 
	$c->stash('dxHelper')->next_id;
}

=head2 dxbind

Internal usage.

	dxbind( $c, 'dxButton' => $id => $attrs, \@extensions);

Produce a div tag with an computed id, which will be binded to
a dxButton with C<$attrs> attributs at call to dxbuild

=cut
sub dxbind{
	my ($c, $control, $id, $attrs, $extensions, $befores, $afters) = @_;
	#should return html code to be associated to the control
	$befores //=[];
	$afters  //=[];
	#http://stackoverflow.com/questions/9930577/jquery-dot-in-id-selector
	my $jquery_id = $id;
	$jquery_id =~ s{\.}{\\\\.}g;
	my $binding = '$("#'.$jquery_id.'").'.$control.'(';
    my @options;
	if (ref($attrs) eq 'HASH') {
		$binding .= '{';
		for my $k ( sort keys %$attrs){
			my $v = $attrs->{$k};
			if(ref($v) eq 'SCALAR'){
				#unref protected scalar
				$v = $$v;
			}
			elsif ($v!~/^\s*(?:function\s*\()/) {
				$v =  encode_json $v;
			}
			push @options, "$k: $v";
		}
	}
	else{
		push @options, $attrs;
	}
    $binding .= join ",\n", @options;
	$binding .= '}' if ref($attrs) eq 'HASH';
    $binding .= ');';
	#append some extensions (eg: dxdatagrid)
	$binding .= join ";\n", @$extensions if defined $extensions;
	$c->stash('dxHelper')->add_binding($binding);
	out join('',@$befores).'<div id="'.$id.'"></div>'.join('',@$afters);
}


=head2 parse_attributs

Internal usage

	my $attrs = parse_attributs( $c, \@implicit_arguments, @attributs )

=cut
sub parse_attributs{
	my $c = shift;
	my @implicit_args = @{shift()};
	my %attrs;
	IMPLICIT_ARGUMENT:
	while(@_ and ref($_[0]) =~ /^(?:|SCALAR)$/){
		$attrs{ shift @implicit_args } = shift @_;
	}
	if(my $args = shift){
		if(ref($args) eq 'HASH'){
			NAMED_ARGUMENT:
			while(my($k,$v)=each %$args){
				$attrs{$k} = $v;
			}
		}
	}
	return \%attrs;
}	

=head2 dxbutton C<[ $id, [ $text, [ $onclick ] ] ], [ \%options ]>

	%= dxbutton myButtonId => 'My button' => q{ function (){ alert('onClick!'); } }
	
	%= dxbutton undef, 'My button' => '/some/url'
	
	%= dxbutton {
			id      => myId,
			text    => 'My button',
			onClick => q{ function (){ alert('onClick!'); } },
			type    => 'danger',
			icon    => 'user'
		};

=cut

sub dxbutton {
    my $c = shift;
	my $attrs = parse_attributs( $c, [qw(id text onClick type)], @_ );
	my $id = delete($attrs->{id}) // new_id( $c, $attrs );	
	dxbind( $c, 'dxButton' => $id => $attrs);
}

=head2 dxdatagrid C<[ $id, [ $datasource, ] ] [ \%opts ]>

	%= dxdatagrid 'myID' => '/products.json', { columns => [qw( name description price )] }
	
	%= dxdatagrid undef, '/products.json'
	
	%= dxdatagrid { id => myId, dataSource => '/products.json' }
	
The following syntaxe allow to specify all options from a javascript object.
B<Note: It will ignore all other options specified in the hash reference.>
	
	%= dxdatagrid myId, { options => 'JSFrameWork.gridsOptions.myResource' }

=cut

sub dxdatagrid{
	my $c = shift;
	my $attrs = parse_attributs( $c, [qw(id dataSource)], @_ );
	my $id = delete($attrs->{id}) // new_id( $c, $attrs );
	my @extensions;
	#dxbind( $c, 'dxDataGrid' => $id => $attrs, [ $dataSource ]);
	if ($attrs->{dataSource} && ref($attrs->{dataSource}) eq '') {
		my $dataSource = delete $attrs->{dataSource};
		#push @extensions, '$.getJSON("' . $dataSource . '",function(data){$("#'.$id.'").dxDataGrid({ dataSource: data });});';
		#$attrs->{dataSource} = \'[]';	#protect string to be "stringified" within dxbind

		#\"" is to protect string to be "stringified" within dxbind
		$attrs->{dataSource} = \"{store:{type:'odata',url:'$dataSource'}}";
	}
	if (exists $attrs->{options}) {
		$attrs = $attrs->{options};
	}
	
	dxbind( $c, 'dxDataGrid' => $id => $attrs, \@extensions);
}

=head2 dxpopup C<[ $id, [ $title, [ $contentTemplate, ] ] ], [\%opts]>

	%= dxpopup myPopupID => 'Popup Title', \q{function(contentElement){
			contentElement.append('<p>Hello!</p>');
		}};

=cut

sub dxpopup{
	my $c = shift;
	my $attrs = parse_attributs( $c, [qw(id title contentTemplate)], @_ );
	my $id = delete($attrs->{id}) // new_id( $c, $attrs );
	
	dxbind( $c, 'dxPopup' => $id => $attrs );
}

=head2 dxswitch C<[ $id [, $value [, $label] ] ], [\%opts]>

	%= dxswitch 'mySwitch' => $boolean_value => 'Enabled: '
	
=cut

sub dxswitch{
	my $c = shift;
	my $attrs = parse_attributs( $c, [qw(id value label)], @_ );
	my $id = delete($attrs->{id});
	if (my $name = $id) {
		$attrs->{attr}{name}=$name;
	}
	$id //= new_id( $c, $attrs );
	$attrs->{onText}  //= 'On';
	$attrs->{offText} //= 'Off';
	my (@before, @after);
	if(my $label = delete($attrs->{label})){
		push @before, '<div class="dx-field">';
		push @before, '<div class="dx-field-label">'.$label.'</div>';
		push @before, '<div class="dx-field-value">';
		push @after, '</div>';
		push @after, '</div>';
	}
	
	dxbind( $c, 'dxSwitch' => $id => $attrs, undef, \@before, \@after );	
}


=head2 dxtextbox C<[ $id, [ $value, [ $label, ] ] ], [\%opts]>

	%= dxtextbox 'name' => $value => 'Name: ', { placeHolder => 'Type a name' }

=cut
sub dxtextbox{
	my $c = shift;
	my $attrs = parse_attributs( $c, [qw(id value label)], @_ );
	my $id = delete($attrs->{id});
	if (my $name = $id) {
		$attrs->{attr}{name}=$name;
	}
	
	$id //= new_id( $c, $attrs );

	my (@before, @after);
	if(my $label = delete($attrs->{label})){
		push @before, '<div class="dx-field">';
		push @before, '<div class="dx-field-label">'.$label.'</div>';
		push @before, '<div class="dx-field-value">';
		push @after, '</div>';
		push @after, '</div>';
	}
	
	dxbind( $c, 'dxTextBox' => $id => $attrs, undef, \@before, \@after );	
}


=head2 dxlookup C<[ $id, [ $value, [ $label, ] ] ], [\%opts]>

	%= dxlookup 'name' => $value => 'Name: ', { dataSource => $ds, valueExpr=> $ve, displayExpr => $de }

=cut
sub dxlookup{
	my $c = shift;
	my $attrs = parse_attributs( $c, [qw(id value label)], @_ );
	my $id = delete($attrs->{id});
	if (my $name = $id) {
		$attrs->{attr}{name}=$name;
	}
	
	$id //= new_id( $c, $attrs );

	my (@before, @after);
	if(my $label = delete($attrs->{label})){
		push @before, '<div class="dx-field">';
		push @before, '<div class="dx-field-label">'.$label.'</div>';
		push @before, '<div class="dx-field-value">';
		push @after, '</div>';
		push @after, '</div>';
	}
	
	dxbind( $c, 'dxLookup' => $id => $attrs, undef, \@before, \@after );	
}

=for comment
TextArea
SelectBox
NumberBox
List
DateBox
CheckBox
Calendar
Box
=cut

=head2 dxbuild

Build the binding between jQuery and divs generated by plugin helpers such as dxbutton.
It is should to be called in your template just before you close the body tag.

	<body>
		...
		%= dxbuild
	</body>

=cut

sub dxbuild {
	my $c = shift;
	my $dxhelper = $c->stash('dxHelper') or return;
	if($dxhelper->{bindings}){
		out '<script language="javascript">$(function(){'.$dxhelper->{bindings}.'});</script>';
	}
}

=head2 require_asset @assets

Used to specify one or more assets dependencies, that will be appended on call to required_assets.
This function need 'AssetPack' plugin to be configurated in your application.

in your template:

	<body>
		...
		%= require_asset 'MyScript.js'
		...
	</body>

in your layout:

	<head>
		...
		%= required_assets
		...
	</head>


=cut

sub require_asset{
	my $c = shift;
	my $dxhelper = $c->stash('dxHelper') or return;
	
	push @{ $dxhelper->{required_assets} }, $_ for @_;
	
	return $c;
}

=head2 required_assets

Add assets that was specified by calls to require_asset.
See require_asset for usage.

=cut

sub required_assets{
	my $c = shift;
	my $dxhelper = $c->stash('dxHelper') or return;
	my $required_assets = $dxhelper->{required_assets} // [];
	my $results = Mojo::ByteStream->new();
	ASSET:
	for my $asset (@$required_assets){
		#not sure about how to simulate " %= asset 'resource' " that we can use in template rendering, 
		#nor how to output multiple Mojo::ByteStream objets at a time (is returning required ?)
		$$results .= ${ $c->asset($asset) };
	}
	return $results;
}

#Helper method to export without prepending a prefix
my @without_prefix = qw( dxbuild required_assets require_asset );

#Helper method to export with prepending a prefix
my @with_prefix = qw( Button DataGrid Popup TextBox TextArea Switch
	SelectBox NumberBox List DateBox CheckBox Calendar Box Lookup );
=head2 register

Register our helpers

=cut
sub register {
	my ( $self, $app, $args ) = @_;
	my $tp = $args->{tag_prefix};
	
	SUB_NO_PREFIX:
	for my $subname ( @without_prefix ){
		my $lc_name = lc $subname;
		my $sub = __PACKAGE__->can( $lc_name );
		unless($sub){
			$app->log->debug(__PACKAGE__." helper '$lc_name' does not exists!");
			next SUB_NO_PREFIX;
		}
		$app->helper( $lc_name => $sub );
	}

	SUB_WITH_PREFIX:
	for my $subname ( @with_prefix ){
		my $lc_name = lc $subname;
		my $sub = __PACKAGE__->can( 'dx' . $lc_name );
		unless($sub){
			$app->log->debug(__PACKAGE__." helper 'dx$lc_name' does not exists!");
			next SUB_WITH_PREFIX;
		}
		say STDERR "## adding helper '$tp$lc_name'" if DEBUG;
		$app->helper( $tp . $lc_name => $sub );
		say STDERR "## adding helper '$tp$subname'" if DEBUG and $args->{tag_camelcase};
		$app->helper( $tp . $subname => $sub ) if $args->{tag_camelcase};
	}
	
}

1;
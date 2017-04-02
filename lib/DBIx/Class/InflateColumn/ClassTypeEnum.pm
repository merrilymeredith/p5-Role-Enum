package DBIx::Class::InflateColumn::ClassTypeEnum;
# ABSTRACT: Inflate enum-like columns to your Class::Type::Enum classes

=head1 SYNOPSIS

  package My::Schema::Result::Toast {
    __PACKAGE__->load_components(qw/ InflateColumn::ClassTypeEnum Core /);

    # Assuming Toast::Status is one of your enum classes...

    use Toast::Status;  # Ensure it is loaded.

    __PACKAGE__->add_columns(
      status => {
        data_type => 'varchar',
        extra     => {
          enum_class => 'Toast::Status',
        },
      }
    );
  }

=head1 DESCRIPTION

Inflate DBIC columns into instances of your L<Class::Type::Enum> classes.  The
storage C<data_type> doesn't matter here, only whether or not enums should
inflate/deflate to symbols (strings) or ordinals (integers).

=cut

use warnings;
use strict;

use Function::Parameters 2;
use Carp ();

=method register_column($column, $info)

This method chains with L<DBIx::Class::Row/register_column> and checks for two
subkeys inside the C<extra> key of the column info:

=for :list
= enum_class
Required to enable column inflation.  Specify the complete class name that this
column should be inflated to.  It should already be loaded and must be a
subclass of L<Class::Type::Enum>.
= enum_ordinal_storage
If true, the column is inflated from and deflated to ordinal values.

=cut


method register_column ($column, $info) {
  $self->next::method(@_);

  return unless $info->{extra} and my $class = $info->{extra}{enum_class};

  unless (eval { $class->isa('Class::Type::Enum') }) {
    Carp::croak "enum_class $class is not loaded or doesn't inherit from Class::Type::Enum";
  }

  # I'd love to DTRT based on the column type but I think they're practically
  # freeform in DBIC and just match the DB types, so that's a lot of
  # possibilities...

  if ($info->{extra}{enum_ordinal_storage}) {
    $self->inflate_column(
      $column => {
        inflate => fun ($ord = undef) {
          return unless defined $ord;
          $class->inflate_ordinal($ord);
        },
        deflate => fun ($enum = undef) {
          return unless defined $enum;
          $enum->numify;
        },
      }
    );

  }
  else {
    $self->inflate_column(
      $column => {
        inflate => fun ($val = undef) {
          return unless defined $val;
          $class->inflate_symbol($val);
        },
        deflate => fun ($enum = undef) {
          return unless defined $enum;
          $enum->stringify;
        },
      }
    );
  }
}

=head1 SEE ALSO

=for :list
* L<Class::Type::Enum>
* L<DBIx::Class::InflateColumn::Object::Enum>

=cut

1;

# NAME

Class::Type::Enum - Build Enum-like classes

# VERSION

version 0.015

# SYNOPSIS

    package Toast::Status {
      use Class::Type::Enum values => ['bread', 'toasting', 'toast', 'burnt'];
    }

    package Toast {
      use Moo;

      has status => (
        is      => 'rw',
        isa     => Toast::Status->type_constraint,
        coerce  => 1,
        handles => [ Toast::Status->list_is_methods ],
      );
    }

    my @toast = map { Toast->new(status => $_) } qw( toast burnt bread bread toasting toast );

    my @trashcan = grep { $_->is_burnt } @toast;
    my @plate    = grep { $_->is_toast } @toast;

    my $ready_status   = Toast::Status->new('toast');
    my @eventual_toast = grep { $_->status < $ready_status } @toast;

    # or:

    @eventual_toast = grep { $_->status lt 'toast' } @toast;

    # or:

    @eventual_toast = grep { $_->status->none('toast', 'burnt') } @toast;

# DESCRIPTION

Class::Type::Enum is a class builder for type-like classes to represent your
enumerated values.  In particular, it was built to scratch an itch with
[DBIx::Class](https://metacpan.org/pod/DBIx::Class) value inflation.

I wouldn't consider the interface stable yet; I'd love feedback on this dist.

When `use`ing Class::Type::Enum:

- Required:
    - values => \[@symbols\]

        The list of symbolic values in your enum, in ascending order if relevant.

    - values => {symbol => ordinal, ...}

        The list of symbols and ordinal values in your enum.  There is no check that a
        given ordinal isn't reused.

## Custom Ordinal Values

If you'd like to build an enum that works like a bitfield or some other custom
setup, you need only pass a more explicit hashref to Class::Type::Enum.

    package BitField {
      use Class::Type::Enum values => {
        READ    => 1,
        WRITE   => 2,
        EXECUTE => 4,
      };
    }

# METHODS

## $class->import(values => ...)

Sets up the consuming class as a subclass of Class::Type::Enum and installs
functions that are unique to the class.

## $class->new($value)

Your basic constructor, expects only a value corresponding to a symbol in the
enum type.  Also works as an instance method for enums of the same class.

## $class->inflate\_symbol($symbol)

Does the actual work of `$class->new($value)`, also used when inflating values for
[DBIx::Class::InflateColumn::ClassTypeEnum](https://metacpan.org/pod/DBIx::Class::InflateColumn::ClassTypeEnum).

## $class->inflate\_ordinal($ord)

Used when inflating ordinal values for
[DBIx::Class::InflateColumn::ClassTypeEnum](https://metacpan.org/pod/DBIx::Class::InflateColumn::ClassTypeEnum) or if you need to work with
ordinals directly.

## $class->sym\_to\_ord

Returns a hashref keyed by symbol, with ordinals as values.

## $class->ord\_to\_sym

Returns a hashref keyed by ordinal, with symbols as values.

## $class->values

Returns an arrayref of valid symbolic values, in order.

## $class->list\_is\_methods

Returns a list of `is_` methods defined for each symbolic value for the class.

## $class->type\_constraint

This method requires the optional dependency [Type::Tiny](https://metacpan.org/pod/Type::Tiny).

Returns a type constraint suitable for use with [Moo](https://metacpan.org/pod/Moo) and friends.

## $class->test\_symbol($value)

Test whether or not the given value is a valid symbol in this enum class.

## $class->test\_ordinal($value)

Test whether or not the given value is a valid ordinal in this enum class.

## $class->coerce\_symbol($value)

If the given value is already a $class, return it, otherwise try to inflate it
as a symbol.  Dies on invalid value.

## $class->coerce\_ordinal($value)

If the given value is already a $class, return it, otherwise try to inflate it
as an ordinal.  Dies on invalid value.

## $class->coerce\_any($value)

If the given value is already a $class, return it, otherwise try to inflate it
first as an ordinal, then as a symbol.  Dies on invalid value.

## $o->is($value)

Given a test symbol, test that the enum instance's value is equivalent.

An exception is thrown if an invalid symbol is provided

## $o->is\_$value

Shortcut for `$o->is($value)`

## $o->stringify

Returns the symbolic value.

## $o->numify

Returns the ordinal value.

## $o->cmp($other, $reversed = undef)

The string-compare implementation used by overloading.  Returns the same values
as `cmp`.  The optional third argument is an artifact of [overload](https://metacpan.org/pod/overload), set to
true if the order of `$o` and `$other` have been reversed in order to make
the overloaded method call work.

## $o->any(@cases)

True if `$o->is(..)` for any of the given cases.

## $o->none(@cases)

True if `$o->is(..)` for none of the given cases.

# SEE ALSO

- [Object::Enum](https://metacpan.org/pod/Object::Enum)
- [Class::Enum](https://metacpan.org/pod/Class::Enum)
- [Enumeration](https://metacpan.org/pod/Enumeration)

# AUTHOR

Meredith Howard <mhoward@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Meredith Howard.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

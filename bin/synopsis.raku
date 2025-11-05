#!/usr/bin/env raku
use v6.d;
use Hilite::Simple;

my $source = q:to/END/;
    sub greet(Str $name) {      # Strictly typed
        say "Hello, $name!"
    }
    my $user = "Alice";         # Untyped (dynamic)
    greet($user);               # Works fine

    my Int $age = 30;           # Strict Int
    my $info = "Age: $age";     # Dynamic string interpolation
    say $info;
    END

say hilite($source);

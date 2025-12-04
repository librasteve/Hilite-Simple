# Hilite::Simple

Hilite::Simple is an HTML code highlighter. It is a cut down version of the raku Hilite module (auth:finanalyst).

Unlike Hilite, only raku (and rakudoc) highlighting is supported. Hilite::Simple avoids the use of <style>...</style> tags, external CSS files (eg styles.css), SASS and JavaScript - the output is provided as simple HTML with inline styling for copy pasta purposes. For example into the raw HTML widget offered by wordpress.com.

Hilite::Simple employs the Rainbow raku highlighter module (auth:patrickbr) using RakuAST.

Currently, only the default color map is offered (as featured in raku.org).

## SYNOPSIS

To get an HTML div that highlights raku:

```bash
> hilite myscript.raku > myscript.html

Usage:
  hilite [--output=<Str>] [--rakudoc] <source>
```

You can also use Hilite::Simple in a script like so:

```raku
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
```

## AUTHOR

Steve Roe (aka librasteve)

## COPYRIGHT AND LICENSE

Copyright 2025 Henley Cloud Consulting Ltd.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.


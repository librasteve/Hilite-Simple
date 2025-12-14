# Hilite::Simple

Hilite::Simple is an HTML code highlighter. It is a cut down version of the raku Hilite module (auth:finanalyst).

Unlike Hilite, only raku (and rakudoc) highlighting is supported. Hilite::Simple avoids the use of <style>...</style> tags, external CSS files (eg styles.css), SASS and JavaScript - the output is provided as simple HTML with inline styling for copy pasta purposes. For example into the `Custom HTML` block provided on wordpress.com.

Hilite::Simple employs the Rainbow raku highlighter module (auth:patrickbr) using RakuAST.

Currently, only the default color map is offered (as featured in raku.org).

## SYNOPSIS

To get an HTML div that highlights raku:

```bash
> hilite myscript.raku > myscript.html
```

Here is CLI's usage message:

```shell
hilite --help
```
```
# Usage:
#   hilite.raku <source> [--output=<Str>] [--rakudoc] [--theme=<Str>] [-b|--background|--background-color=<Str>]
#   
#     <source>                                    input filename
#     --output=<Str>                              optional output filename
#     --rakudoc                                   optional flag [default: False]
#     --theme=<Str>                               highlight theme [default: 'dark']
#     -b|--background|--background-color=<Str>    background color
```

You can also use Hilite::Simple in a script like so:

```raku, results=asis
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
<style> .raku-code { font-weight: 500; .nohighlights { background: none; color: inherit; } .rainbow-name_scalar { color: #2458a2; } .rainbow-name_array { color: #B01030; } .rainbow-name_hash { color: #00a693; } .rainbow-name_code { color: #209cee; } .rainbow-keyword { color: #008c7e; } .rainbow-operator { color: #1ca24f; } .rainbow-type { color: #d12c4c; } .rainbow-routine { color: #489fdc; } .rainbow-string { color: #369ec6; } .rainbow-string_delimiter { color: #1d90d2; } .rainbow-escape { color: #2b2b2b; } .rainbow-text { color: #2a2a2a; } .rainbow-comment { color: #4aa36c; } .rainbow-regex_special { color: #00996f; } .rainbow-regex_literal { color: #a52a2a; } .rainbow-regex_delimiter { color: #aa00aa; } .rainbow-rakudoc_text { color: #2b9e71; } .rainbow-rakudoc_markup { color: #d02b4c; } } </style> <div class="raku-code"><div><pre class="nohighlights" style=" font-size: 1em; font-family: monospace; background-color: #0f111a; padding: 0.75em; border-radius: 0.5em; overflow-x: auto; "><span class="rainbow-keyword">sub</span>&nbsp;greet(<span class="rainbow-type">Str</span>&nbsp;<span class="rainbow-name_scalar">$name</span>)&nbsp;{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Strictly typed<br></span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-routine">say</span>&nbsp;<span class="rainbow-string_delimiter">&quot;</span><span class="rainbow-string">Hello, </span><span class="rainbow-name_scalar">$name</span><span class="rainbow-string">!</span><span class="rainbow-string_delimiter">&quot;</span><br>}<br><span class="rainbow-keyword">my</span>&nbsp;<span class="rainbow-name_scalar">$user</span>&nbsp;<span class="rainbow-operator">=</span>&nbsp;<span class="rainbow-string_delimiter">&quot;</span><span class="rainbow-string">Alice</span><span class="rainbow-string_delimiter">&quot;</span>;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Untyped (dynamic)<br></span>greet(<span class="rainbow-name_scalar">$user</span>);&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Works fine<br></span><br><span class="rainbow-keyword">my</span>&nbsp;<span class="rainbow-type">Int</span>&nbsp;<span class="rainbow-name_scalar">$age</span>&nbsp;<span class="rainbow-operator">=</span>&nbsp;30;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Strict Int<br></span><span class="rainbow-keyword">my</span>&nbsp;<span class="rainbow-name_scalar">$info</span>&nbsp;<span class="rainbow-operator">=</span>&nbsp;<span class="rainbow-string_delimiter">&quot;</span><span class="rainbow-string">Age: </span><span class="rainbow-name_scalar">$age</span><span class="rainbow-string_delimiter">&quot;</span>;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Dynamic string interpolation<br></span><span class="rainbow-routine">say</span>&nbsp;<span class="rainbow-name_scalar">$info</span>;</pre></div></div>


Here a synonym of `hilite` is together with theme and background specs:

```raku, results=asis
highlight-code($source, theme => 'solarized-dark') #background => '#1F1F1F');
```
<style> .raku-code { font-weight: 500; .nohighlights { background: none; color: inherit; } .rainbow-name_scalar { color: #268bd2; } .rainbow-name_array { color: #d33682; } .rainbow-name_hash { color: #2aa198; } .rainbow-name_code { color: #b58900; } .rainbow-keyword { color: #859900; } .rainbow-operator { color: #93a1a1; } .rainbow-type { color: #6c71c4; } .rainbow-routine { color: #b58900; } .rainbow-string { color: #2aa198; } .rainbow-string_delimiter { color: #2aa198; } .rainbow-escape { color: #cb4b16; } .rainbow-text { color: #839496; } .rainbow-comment { color: #586e75; } .rainbow-regex_special { color: #dc322f; } .rainbow-regex_literal { color: #2aa198; } .rainbow-regex_delimiter { color: #d33682; } .rainbow-rakudoc_text { color: #586e75; } .rainbow-rakudoc_markup { color: #268bd2; } } </style> <div class="raku-code"><div><pre class="nohighlights" style=" font-size: 1em; font-family: monospace; background-color: #002b36; padding: 0.75em; border-radius: 0.5em; overflow-x: auto; "><span class="rainbow-keyword">sub</span>&nbsp;greet(<span class="rainbow-type">Str</span>&nbsp;<span class="rainbow-name_scalar">$name</span>)&nbsp;{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Strictly typed<br></span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-routine">say</span>&nbsp;<span class="rainbow-string_delimiter">&quot;</span><span class="rainbow-string">Hello, </span><span class="rainbow-name_scalar">$name</span><span class="rainbow-string">!</span><span class="rainbow-string_delimiter">&quot;</span><br>}<br><span class="rainbow-keyword">my</span>&nbsp;<span class="rainbow-name_scalar">$user</span>&nbsp;<span class="rainbow-operator">=</span>&nbsp;<span class="rainbow-string_delimiter">&quot;</span><span class="rainbow-string">Alice</span><span class="rainbow-string_delimiter">&quot;</span>;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Untyped (dynamic)<br></span>greet(<span class="rainbow-name_scalar">$user</span>);&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Works fine<br></span><br><span class="rainbow-keyword">my</span>&nbsp;<span class="rainbow-type">Int</span>&nbsp;<span class="rainbow-name_scalar">$age</span>&nbsp;<span class="rainbow-operator">=</span>&nbsp;30;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Strict Int<br></span><span class="rainbow-keyword">my</span>&nbsp;<span class="rainbow-name_scalar">$info</span>&nbsp;<span class="rainbow-operator">=</span>&nbsp;<span class="rainbow-string_delimiter">&quot;</span><span class="rainbow-string">Age: </span><span class="rainbow-name_scalar">$age</span><span class="rainbow-string_delimiter">&quot;</span>;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="rainbow-comment"># Dynamic string interpolation<br></span><span class="rainbow-routine">say</span>&nbsp;<span class="rainbow-name_scalar">$info</span>;</pre></div></div>


See all available highlight themes with

```raku
hilite-themes
```
```
# (dark light solarized-dark solarized-light vscode-dark vscode-light)
```

(Or use `highlight-code-themes`.)

## AUTHOR

Steve Roe (aka librasteve)

## COPYRIGHT AND LICENSE

Copyright 2025 Henley Cloud Consulting Ltd.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.


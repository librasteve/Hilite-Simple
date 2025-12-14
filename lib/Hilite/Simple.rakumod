#!/usr/bin/env raku
use v6.d;

unit module Hilite::Simple;

use Rainbow;
use HTML::Escape;
use JSON::Fast;

# -----------------------------
# Resources (themes)
# -----------------------------

my $THEMES-CACHE;  # lazily parsed JSON

sub themes-spec() returns Hash:D {
    $THEMES-CACHE //= from-json(slurp(%?RESOURCES<themes.json>));
}

sub default-theme() returns Str:D {
    themes-spec()<default_theme> // 'dark'
}

sub hilite-themes() is export returns List:D {
    (themes-spec()<themes>.keys.sort).List
}

our &highlight-code-themes is export = &hilite-themes;

sub theme-exists(Str:D $theme-id --> Bool:D) {
    themes-spec()<themes>{$theme-id}:exists
}

sub theme-spec(Str:D $theme-id --> Hash:D) {
    themes-spec()<themes>{$theme-id} // themes-spec()<themes>{ default-theme() }
}

sub color-map(:$theme = default-theme()) returns Hash:D {
    my $theme-id = $theme.Str;
    theme-spec($theme-id)<colors> // theme-spec(default-theme())<colors>
}

sub theme-background(:$theme = default-theme()) returns Str:D {
    my $theme-id = $theme.Str;
    theme-spec($theme-id)<background> // '#ffffff'
}

# -----------------------------
# Public API
# -----------------------------

sub hilite(
        Str:D $source,
        Bool:D :$rakudoc = False,
        :$theme = default-theme(),
        Str :b(:background(:$background-color)),   # overrides theme background when provided
           ) is export {
    my $code;

    if $rakudoc {
        $code = Rainbow::tokenize-rakudoc($source).map(-> $t {
            if $t.type.key ne 'TEXT' {
                qq[<span class="rainbow-{$t.type.key.lc}">{ escape-html($t.text) }\</span>]
            } else {
                $t.text.subst(/ ' ' /, '&nbsp;', :g);
            }
        }).join('');
    } else {
        $code = Rainbow::tokenize($source).map(-> $t {
            if $t.type.key ne 'TEXT' {
                qq[<span class="rainbow-{$t.type.key.lc}">{ escape-html($t.text) }\</span>]
            } else {
                $t.text.subst(/ ' ' /, '&nbsp;', :g);
            }
        }).join('');
    }

    $code .= subst( / \v+ <?before $> /, '');
    $code .= subst( / \v /, '<br>', :g);
    $code .= subst( / "\t" /, '&nbsp;' x 4, :g);
    $code .= trim;

    my $bg = $background-color.defined
            ?? $background-color
            !! theme-background(:$theme);

    my $pre-style = qq:to/END/;
        font-size: 1em;
        font-family: monospace;
        background-color: {$bg};
        padding: 0.75em;
        border-radius: 0.5em;
        overflow-x: auto;
    END
    $pre-style ~~ s:g/\s+/ /;

    $code = qq[<pre class="nohighlights" style="{$pre-style}">{$code}</pre>];
    $code = qq[<div class="raku-code"><div>{$code}</div></div>];

    my $html = style-str(style-templ, :$theme) ~ $code.trim;
    inline-css($html).trim
}

our &highlight-code is export = &hilite ;

# -----------------------------
# CSS templating + inlining
# -----------------------------

sub style-str($templ is copy, :$theme = default-theme()) {
    for color-map(:$theme).kv -> $key, $value {
        $templ .= subst("var(--base-color-$key)", $value, :g);
    }
    $templ
}

sub inline-css(Str $html is copy --> Str) {
    # 1) Extract <style> ... </style>
    my @styles = $html.match(/ '<style>' ( .*? ) '<\/style>' /, :g, :s)>>.[0].Str;

    my %css;

    # 2) Parse CSS into hash: class -> {rule -> value}
    for @styles -> $style {
        for $style.match(/ \. ( <[\w\-]>+ ) \s* \{ ( <-[}]>* ) \} /, :g) -> $m {
            my $class = ~$m[0];
            my $rules = ~$m[1];

            my @pairs = $rules.split(';').map(*.trim).grep(*.chars);
            my %rules = @pairs.map(-> $p {
                my ($k, $v) = $p.split(':', 2).map(*.trim);
                $k => $v
            }).Hash;

            %css{$class} = %rules;
        }
    }

    # 3) Remove all <style> blocks
    $html ~~ s:g/ '<style>' .*? '<\/style>' //;

    # 4) Apply inline styles
    for %css.kv -> $class, %rules {
        my $style-str = %rules.map({ "{.key}: {.value}" }).join('; ');

        $html ~~ s:g/
        'class="' (<-[">]>*?) '"'
        /{
            my $classes = ~$0;
            if $classes.split(/\s+/).grep(* eq $class) {
                qq[style="$style-str" class="$classes"]
            } else {
                qq[class="$classes"]
            }
        }/;
    }

    # Light normalize
    $html .= subst(/\s+/, ' ', :g);
    $html
}

sub style-templ {
    q:to/END/;
    <style>
      .raku-code {
        font-weight: 500;

        .nohighlights { background: none; color: inherit; }

        .rainbow-name_scalar       { color: var(--base-color-scalar); }
        .rainbow-name_array        { color: var(--base-color-array); }
        .rainbow-name_hash         { color: var(--base-color-hash); }
        .rainbow-name_code         { color: var(--base-color-code); }
        .rainbow-keyword           { color: var(--base-color-keyword); }
        .rainbow-operator          { color: var(--base-color-operator); }
        .rainbow-type              { color: var(--base-color-type); }
        .rainbow-routine           { color: var(--base-color-routine); }
        .rainbow-string            { color: var(--base-color-string); }
        .rainbow-string_delimiter  { color: var(--base-color-string-delimiter); }
        .rainbow-escape            { color: var(--base-color-escape); }
        .rainbow-text              { color: var(--base-color-text); }
        .rainbow-comment           { color: var(--base-color-comment); }
        .rainbow-regex_special     { color: var(--base-color-regex-special); }
        .rainbow-regex_literal     { color: var(--base-color-regex-literal); }
        .rainbow-regex_delimiter   { color: var(--base-color-regex-delimiter); }
        .rainbow-rakudoc_text      { color: var(--base-color-doc-text); }
        .rainbow-rakudoc_markup    { color: var(--base-color-doc-markup); }
      }
    </style>
    END
}

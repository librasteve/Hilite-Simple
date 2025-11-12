#!/usr/bin/env raku
use v6.d;
use Rainbow;
use HTML::Escape;

sub hilite(Str $source, Bool :$rakudoc) is export {
    my $code;

    if $rakudoc {
        $code = Rainbow::tokenize-rakudoc($source).map( -> $t {
            if $t.type.key ne 'TEXT' {
                qq[<span class="rainbow-{$t.type.key.lc}">{escape-html($t.text)}\</span>]
            }
            else {
                $t.text.subst(/ ' ' /, '&nbsp;',:g);
            }
        }).join('');
    }
    else {
        $code = Rainbow::tokenize($source).map( -> $t {
            if $t.type.key ne 'TEXT' {
                qq[<span class="rainbow-{$t.type.key.lc}">{escape-html($t.text)}\</span>]
            }
            else {
                $t.text.subst(/ ' ' /, '&nbsp;',:g)
            }
        }).join('');
    }

    $code .= subst( / \v+ <?before $> /, '');
    $code .= subst( / \v /, '<br>', :g);
    $code .= subst( / "\t" /, '&nbsp' x 4, :g );
    $code .= trim;
    $code = '<pre class="nohighlights" style="font-size: 1em; font-family: monospace">' ~ $code ~ '</pre>';
    $code = '<div class="raku-code"><div>' ~ $code ~ '</div></div>';

    my $html = style-str(style-templ) ~ $code.trim;
    return inline-css($html).trim;
}

sub inline-css(Str $html is copy --> Str) {

    # 1. Extract <style> content
    my @styles = $html.match(/ '<style>' (.*?) '</style>' /, :g, :s)>>.[0].Str;
    my %css;

    # 2. Parse CSS into hash
    for @styles -> $style {
        for $style.match(/ \. ( <[\w\-]>+ ) \s*  \{ ( <-[}]>* ) \} /, :g) -> $m {
            my $class = ~$m[0];
            my $rules = ~$m[1];
            my @rules = $rules.split(';');
            my %rules = @rules.split(':')>>.trim.map({ $^k => $^v });
            %css{$class} = %rules;
        }
    }

    # 3. Remove all <style> tags
    $html ~~ s:g/'<style>' .*? '</style>'//;

    # 4. Apply inline styles
    for %css.kv -> $class, %rules {
        my $style-str = %rules.map({ "{.key}: {.value}" }).join('; ');

        # Match both class="foo" or class="foo bar"
        $html ~~ s:g/'class="' (<-[">]>*?) "\""/ {
            my $classes = ~$0;
            if $classes.split(/\s+/).grep(* eq $class) {
                "style=\"$style-str\" class=\"$classes\"";
            }
            else {
                "class=\"$classes\"";
            }
        }/;
        $html.=subst(/\s+/, ' ', :g);
    }

    return $html;
}

# default hilite colours (same as raku.org)

sub color-map { %(
    scalar => '#2458a2',
    array => '#B01030',
    hash => '#00a693',
    code => '#209cee',
    keyword => '#008c7e',
    operator => '#1ca24f',
    type => '#d12c4c',
    routine => '#489fdc',
    string => '#369ec6',
    string-delimiter => '#1d90d2',
    escape => '#2b2b2b',
    text => '#2a2a2a',
    comment => '#4aa36c',
    regex-special => '#00996f',
    regex-literal => '#a52a2a',
    regex-delimiter => '#aa00aa',
    doc-text => '#2b9e71',
    doc-markup => '#d02b4c',
) }

sub style-str($templ is copy) {
    for color-map.kv -> $key, $value {
        $templ.=subst( /'var(--base-color-' $key ')'/, $value );
    }
    $templ
}

sub style-templ { q:to/END/;
    <style>
      .raku-code {
        font-weight: 500;

        .nohighlights {
            background: none;
            color: inherit;
        }
        .rainbow-name_scalar {
            color: var(--base-color-scalar);
        }
        .rainbow-name_array {
            color: var(--base-color-array);
        }
        .rainbow-name_hash {
            color: var(--base-color-hash);
        }
        .rainbow-name_code {
            color: var(--base-color-code);
        }
        .rainbow-keyword {
            color: var(--base-color-keyword);
        }
        .rainbow-operator {
            color: var(--base-color-operator);
        }
        .rainbow-type {
            color: var(--base-color-type);
        }
        .rainbow-routine {
            color: var(--base-color-routine);
        }
        .rainbow-string {
            color: var(--base-color-string);
        }
        .rainbow-string_delimiter {
            color: var(--base-color-string-delimiter);
        }
        .rainbow-escape {
            color: var(--base-color-escape);
        }
        .rainbow-text {
            color: var(--base-color-text);
        }
        .rainbow-comment {
            color: var(--base-color-comment);
        }
        .rainbow-regex_special {
            color: var(--base-color-regex-special);
        }
        .rainbow-regex_literal {
            color: var(--base-color-regex-literal);
        }
        .rainbow-regex_delimiter {
            color: var(--base-color-regex-delimiter);
        }
        .rainbow-rakudoc_text {
            color: var(--base-color-doc-text);
        }
        .rainbow-rakudoc_markup {
            color: var(--base-color-doc-markup);
        }
      }
    </style>
    END
}


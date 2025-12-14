#!/usr/bin/env raku
use v6.d;
use Rainbow;
use HTML::Escape;

enum Theme (
dark             => 'dark',
light            => 'light',
vscode-dark      => 'vscode-dark',
vscode-light     => 'vscode-light',
solarized-dark   => 'solarized-dark',
solarized-light  => 'solarized-light',
);


sub hilite(Str $source, Bool :$rakudoc, :$theme = 'dark' ) is export {
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
    $code .= subst( / "\t" /, '&nbsp;' x 4, :g );
    $code .= trim;
    $code = '<pre class="nohighlights" style="font-size: 1em; font-family: monospace">' ~ $code ~ '</pre>';
    $code = '<div class="raku-code"><div>' ~ $code ~ '</div></div>';

    my $html = style-str(style-templ, :$theme) ~ $code.trim;
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
# Theme enum-ish (string-backed IDs) + palettes
#
# Usage:
#   my %c1 = color-map();                         # default: dark (raku.org-ish)
#   my %c2 = color-map(:theme<light>);
#   my %c3 = color-map(:theme<vscode-dark>);
#   my %c4 = color-map(:theme<solarized-light>);
#
# You can pass Str theme ids; unknown ids fall back to 'dark'.


sub color-map ( :$theme = Theme::dark ) {

    # Accept either Theme or Str
    my $theme-id = $theme ~~ Theme ?? $theme.value !! $theme.Str;

    my %palettes = %(
        'dark' => %(
            scalar            => '#2458a2',
            array             => '#B01030',
            hash              => '#00a693',
            code              => '#209cee',
            keyword            => '#008c7e',
            operator           => '#1ca24f',
            type               => '#d12c4c',
            routine            => '#489fdc',
            string             => '#369ec6',
            string-delimiter   => '#1d90d2',
            escape             => '#2b2b2b',
            text               => '#2a2a2a',
            comment            => '#4aa36c',
            regex-special      => '#00996f',
            regex-literal      => '#a52a2a',
            regex-delimiter    => '#aa00aa',
            doc-text           => '#2b9e71',
            doc-markup         => '#d02b4c',
        ),

        'light' => %(
            scalar            => '#1f4fa3',
            array             => '#9c0d28',
            hash              => '#007f6d',
            code              => '#1c7fd0',
            keyword            => '#006b60',
            operator           => '#168a43',
            type               => '#b01f3e',
            routine            => '#3c7fc0',
            string             => '#2f7fa6',
            string-delimiter   => '#1a6fb8',
            escape             => '#555555',
            text               => '#000000',
            comment            => '#3b7f57',
            regex-special      => '#007a59',
            regex-literal      => '#8b1f1f',
            regex-delimiter    => '#7a007a',
            doc-text           => '#2a7f5c',
            doc-markup         => '#b01f3e',
        ),

        # VS Code-ish (approximate semantic mapping)
        'vscode-dark' => %(
            scalar            => '#569CD6', # Blue
            array             => '#C586C0', # Purple-ish
            hash              => '#4EC9B0', # Teal
            code              => '#DCDCAA', # Yellow-ish
            keyword            => '#C586C0',
            operator           => '#D4D4D4',
            type               => '#4EC9B0',
            routine            => '#DCDCAA',
            string             => '#CE9178', # Orange
            string-delimiter   => '#CE9178',
            escape             => '#D7BA7D',
            text               => '#D4D4D4',
            comment            => '#6A9955', # Green
            regex-special      => '#D16969', # Reddish
            regex-literal      => '#CE9178',
            regex-delimiter    => '#D16969',
            doc-text           => '#6A9955',
            doc-markup         => '#569CD6',
        ),

        'vscode-light' => %(
            scalar            => '#0451A5',
            array             => '#AF00DB',
            hash              => '#267F99',
            code              => '#795E26',
            keyword            => '#0000FF',
            operator           => '#000000',
            type               => '#267F99',
            routine            => '#795E26',
            string             => '#A31515',
            string-delimiter   => '#A31515',
            escape             => '#811F3F',
            text               => '#000000',
            comment            => '#008000',
            regex-special      => '#811F3F',
            regex-literal      => '#A31515',
            regex-delimiter    => '#811F3F',
            doc-text           => '#008000',
            doc-markup         => '#0451A5',
        ),

        # Solarized (canonical palette; semantic mapping)
        # Base03 #002b36  Base02 #073642  Base01 #586e75  Base00 #657b83
        # Base0  #839496  Base1  #93a1a1  Base2  #eee8d5  Base3  #fdf6e3
        # Yellow #b58900  Orange #cb4b16  Red #dc322f  Magenta #d33682
        # Violet #6c71c4  Blue #268bd2  Cyan #2aa198  Green #859900
        'solarized-dark' => %(
            scalar            => '#268bd2', # blue
            array             => '#d33682', # magenta
            hash              => '#2aa198', # cyan
            code              => '#b58900', # yellow
            keyword            => '#859900', # green
            operator           => '#93a1a1', # base1
            type               => '#6c71c4', # violet
            routine            => '#b58900',
            string             => '#2aa198',
            string-delimiter   => '#2aa198',
            escape             => '#cb4b16', # orange
            text               => '#839496', # base0
            comment            => '#586e75', # base01
            regex-special      => '#dc322f', # red
            regex-literal      => '#2aa198',
            regex-delimiter    => '#d33682',
            doc-text           => '#586e75',
            doc-markup         => '#268bd2',
        ),

        'solarized-light' => %(
            scalar            => '#268bd2',
            array             => '#d33682',
            hash              => '#2aa198',
            code              => '#b58900',
            keyword            => '#859900',
            operator           => '#657b83', # base00
            type               => '#6c71c4',
            routine            => '#b58900',
            string             => '#2aa198',
            string-delimiter   => '#2aa198',
            escape             => '#cb4b16',
            text               => '#073642', # base02 (dark text on light bg)
            comment            => '#93a1a1', # base1
            regex-special      => '#dc322f',
            regex-literal      => '#2aa198',
            regex-delimiter    => '#d33682',
            doc-text           => '#93a1a1',
            doc-markup         => '#268bd2',
        ),
    );

    %palettes{$theme-id} // %palettes{Theme::dark.value}
}

sub style-str($templ is copy, :$theme = True) {
    for color-map(:$theme).kv -> $key, $value {
        $templ.=subst( 'var(--base-color-' ~ $key ~ ')', $value );
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


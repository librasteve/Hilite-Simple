#!/usr/bin/env raku
use v6.d;
use Hilite::Simple;

my %*SUB-MAIN-OPTS =
        :named-anywhere,
        # allow named variables at any location
        ;

sub MAIN(
    Str  $source,                            #= input filename
    Str  :$output,                           #= optional output filename
    Bool:D :$rakudoc = False,                #= optional flag
    Str  :$theme = 'dark',                   #= highlight theme
    Str :b(:background(:$background-color)), #= background color
 ) {
    my $input = $source.IO.slurp;
    my $result = hilite($input, :$rakudoc, :$theme, :$background-color);

    if $output {
        $output.IO.spurt($result);
        say "Wrote highlighted output to '$output'";
    } else {
        say $result;
    }
}

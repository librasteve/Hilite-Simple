#!/usr/bin/env raku
use v6.d;
use Hilite::Simple;

sub MAIN(
    Str  $source,                        # input filename
    Str  :$output,                       # optional output filename
    Bool :$rakudoc = False               # optional flag
 ) {
    my $input = $source.IO.slurp;
    my $result = hilite($input, :$rakudoc);

    if $output {
        $output.IO.spurt($result);
        say "Wrote highlighted output to '$output'";
    } else {
        say $result;
    }
}

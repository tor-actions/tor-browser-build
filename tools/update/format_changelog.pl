#!/usr/bin/perl -w

# Read ChangeLog.txt from stdin
#   $ ./format_changelog.pl < ChangeLog.txt

my $once = 0;
my $last_indent=0;

sub finish {
    while ($last_indent > 2) {
        print "</ul>\n";
        # Every entry in the ChangeLog is indented by 2 characters
        # except for the first Platform line
        $last_indent -= 2
    }
    exit;
}

while (<>) {
    #print "$_";
    my $line = "";
    if ($_ =~ /^Tor Browser /) {
        finish() unless $once == 0;
        $once = 1;
        next;
    }
    # Skip empty lines
    if ($_ =~ /^\s*$/) {
        next;
    }
    #print ">>> $_";
    if ($_ =~ /(\s+)\* Bug (\d+):(.*)$/) {
        my $indentation = $1;
        my $bug = $2;
        my $description = $3;
        my $current_indent = length($indentation);
        if ($current_indent > $last_indent) {
            $line = "<ul>";
        } elsif ($current_indent < $last_indent) {
            $line = "</ul>";
        }
        $last_indent = $current_indent;
        if ($bug < 40000) {
            $line.="<li><a href=\"https://bugs.torproject.org/$bug\">Bug $bug</a>:$3</li>";
        } else {
            $description =~ /(.*)\[([a-z-]*)\]$/;
            my $project = "tpo/applications/$2/$bug" // "$bug";
            $line.="<li><a href=\"https://bugs.torproject.org/$project\">Bug $bug</a>:$1</li>";
        }
    } elsif ($_ =~ /(\s+)\* (.*)$/) {
        my $indentation = $1;
        my $current_indent = length($indentation);
        if ($current_indent > $last_indent) {
            $line = "<ul>";
        } elsif ($current_indent < $last_indent) {
            $line = "</ul>";
        }
        $last_indent = $current_indent;
        $line .= "<li>$2";
    } else {
        $line = $_;
    }
    print "$line\n";
}

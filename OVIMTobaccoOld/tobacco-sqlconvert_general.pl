#!/usr/bin/perl -w -CO
use strict;
use utf8;
use Encode;

my %wordMap;
my %word2IdHash;
my $fn_tsi;

$fn_tsi = $ARGV[0] if defined($ARGV[0]);
$fn_tsi = "tsi_punctuation.src" unless defined($ARGV[0]);
shift @ARGV;
die "USAGE: $0 tsi_punctuation.src 1.cin 2.cin ..." if (!@ARGV);
print "begin;\n";

# reading tsi_punctuation.src
open (HNDL, $fn_tsi) or die $!;
while(<HNDL>) {
    chomp;
    if (/#?\s*(\S+)\s+(\d+)\s+(.+)/) {
        my $w=decode("utf8", $1);

        $wordMap{$w} = 1 unless exists $wordMap{$w};
    }
}
close HNDL;

my $idCounter = 0;
my @words = keys(%wordMap);
@words = sort @words;
for(@words) {
    $word2IdHash{$_} = $idCounter;
    $idCounter = $idCounter + 1;
}

# reading xxx.cin
for my $fn_cin (@ARGV) {
    open (HNDL, "<:utf8",$fn_cin) or die $!;
    my $table_prefix; # grep ename, for sqlite
    my %key2charMap; # a for X, b for Y, .... z for Z...
    my %word2keysMap; # abc for XY..etc
    my $keyname_sec = 0;
    my $chardef_sec = 0;
    while(<HNDL>) {
	chomp;
	if ($_ =~ m/^%ename\s+([^\s]+)/) {
	    $table_prefix = $1;
	    printf "CREATE TABLE %s_char2word_table(characters TEXT, wordID INTEGER);\n",
		$table_prefix;
	    printf "CREATE INDEX %s_index_characters ON %s_char2word_table(characters);\n",
		$table_prefix, $table_prefix;
		printf
			"CREATE VIEW %s_view AS SELECT characters, word, freq ".
			"FROM %s_char2word_table, word_table, generic_freq_table ".
			"WHERE %s_char2word_table.wordID = word_table.wordID ".
			"AND %s_char2word_table.wordID = generic_freq_table.wordID ".
			"ORDER BY freq DESC;\n",
			$table_prefix, $table_prefix, $table_prefix, $table_prefix;
	}
	$keyname_sec = 1 if ($_ =~ m/^%keyname\s+begin/);
	$keyname_sec = 0 if ($_ =~ m/^%keyname\s+end/);
	$chardef_sec = 1 if ($_ =~ m/^%chardef\s+begin/);
	$chardef_sec = 0 if ($_ =~ m/^%chardef\s+end/);
	if ($keyname_sec and $_ =~ m/^(\S)\s+(\S+)/) {
	    $key2charMap{$1} = $2;
	}
	if ($chardef_sec and $_ =~ m/^(\S+)\s+(\S+)/) {
	    push @{$word2keysMap{$2}}, $1; # NOTE: reverse...
	}
    }
    close HNDL;

    for(@words) {   # "不好"
	my $wordId = $word2IdHash{$_};
	#print "\ncurrent word: $wordId:$_\n";
	my @wordSequence = split(//, $_);   # {"不","好"}
	my @charSequenceArray = qw//;
	my $flag = 1;
	for(@wordSequence) {	# "不"
	    #print "current token: $_\n";
	    my @charSequence = qw//;
	    if(exists $word2keysMap{$_}) {
		for(@{$word2keysMap{$_}}) { # {"1j4","1j6"}
		    #print "current key: $_\n";
		    my @keySequence = split(//, $_);	# {"1","j","4"}
		    my $currentChars = "";
		    for(@keySequence) {	# "1"
			$currentChars .= $key2charMap{$_}; # "ㄅ"
		    }
		    #print "current chars: $currentChars\n";
		    push @charSequence, $currentChars;	# {"ㄅㄨˋ","ㄅㄨˊ"}
		}
	    }
	    else {
		$flag = 0;
		last;
	    }
	    push @charSequenceArray, \@charSequence;	# {{"ㄅㄨˋ", "ㄅㄨˊ"}, {"ㄏㄠˇ","ㄏㄠˋ"}}
	}

	#do combination here.
	if($flag) {
	    my @combination = qw//;
	    for(@{$charSequenceArray[0]}) {
		#print "initial: $_\n";
		push @combination, $_;
	    }
	    for(1...$#charSequenceArray) {
		my @suffixArray = @{$charSequenceArray[$_]};
		my @newCombination = qw//;
		for(@combination) {
		    my $prefix = $_;
		    for(@suffixArray) {
			my $newPrefix .= $prefix . "\t" . $_;
			#print "new prefix: $newPrefix\n";
			push @newCombination, $newPrefix;
		    }
		}
		@combination = @newCombination;
	    }

	    my %combinationMap;
	    for(@combination) { # {"ㄅㄨˋ\tㄏㄠˇ", "ㄅㄨˋ\tㄏㄠˋ", "ㄅㄨˊ\tㄏㄠˇ", "ㄅㄨˊ\tㄏㄠˋ"}
		#print "combination:$_\n";
		$combinationMap{$_} = 1 unless exists $combinationMap{$_};
	    }

	    for(keys(%combinationMap)) {
		printf "insert into %s_char2word_table values ('%s', %d);\n", $table_prefix, sprintf("%s", $_), $wordId;
	    }
	}
    }
}
print "commit;\n";

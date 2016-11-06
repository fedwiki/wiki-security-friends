# make up names, count how quickly they duplicate
# (most commonly we see duplicates after 800 names)
# usage: perl uniqness.pl

sub v {
  ("a","e","i","o","u")[rand 5]
}

sub c {
  ("b","c","d","f","g","h","j","k","l","m","n","p","r","s","t","v","w","y")[rand 18]
}

$size = 50;
%hist = ();
for $trial (1..2500) {
  %uniq = ();
  for $count (1..10000) {
    $name = c().v().c().v().c().v();
    if ($uniq{$name}++) {
      use integer;
      $hist{$count/$size}++;
      last;
    }
  }
}

for $bin (0..3000/$size) {
  $count = $bin*$size;
  $freq = $hist{$bin};
  $bar = '|' x $freq;
  print "$count\t$freq\t$bar\n"
}
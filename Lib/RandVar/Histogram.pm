=head1 NAME

PDL::Lib::RandVar::Histogram

=head1 VERSION

  Current version is 1.0

=head1 SYNOPSIS

  use PDL::Lib::RandVar::Histogram
  $m = new PDL::Lib::RandVar::Histogram($dist);

=head1 DESCRIPTION

=head2 Overview

Histogram random variables are useful for generating distributions to
match arbitrary vector (N-D) data.  On initialization, you feed in a
clumped array whose value is proportional to the probability of
landing in each bin.   You get back values of indices into
the original vector.  If you ask for it, you can get subsampling
in the mantissa of each index.

=head2 History

  1.0   11-Dec-2001 -- Basic functionality & testing (CED)

=head2 Author, license, no warranty

Copyright 2001, Craig DeForest.

This code may be distributed under the same terms as Perl itself
(license available at http://ww.perl.org).  Copying, reverse
engineering, distribution, and modification are explicitly allowed so
long as this notice is preserved intact and modified versions are
clearly marked as such.

If you modify the code and it's useful, please check it in to the 
PDL source tree or send a copy of the modified version to 
cdeforest@solar.stanford.edu.

This package comes with NO WARRANTY.

=head2 Bugs:

Runs a little slow -- hooking into the gnu package might work better.

=head1 FUNCTIONS

=cut


use RandVar;

package PDL::Lib::RandVar::Histogram;
use PDL;
use PDL::NiceSlice;
use Carp;

BEGIN {
package PDL::Lib::RandVar::Histogram;
$VERSION = 1.0;
@ISA = ('RandVar');
}

use strict;

######################################################################
=pod

=head2 new

=for ref

Construct a new histogram-distribution random variable

=for sig

  Signature: (See PDL::PDL::Lib::RandVar::new)

=for usage
 
  $a = new PDL::Lib::RandVar::Histogram(<size>,<opt>);

=for opt

=over 3

=item seed

A number to use as the seed.

=back

=for example

  $a = new PDL::Lib::RandVar::Histogram($dist);
  $xy = sample $a;

=cut

sub PDL::Lib::RandVar::Histogram::new {
  my($opt);
    for(my $i=0;$i<@_;$i++) {
    if(ref $_[$i] eq 'HASH') {
      $opt = splice(@_,$i,1);
      last;
    }
  }
  my($type,$dist) = @_;

  my($me) = &PDL::Lib::RandVar::new($type,$opt);

  my($test) = eval '$dist->isa("PDL")';
  if($@ || !$test) {
    croak('PDL::Lib::RandVar::Histogram::new needs a PDL histogram argument\n');
  }


  my($boundaries) = $dist->flat->copy->clip(0,undef);
  my($n) = $boundaries->nelem;
  
  ##############################
  ## Accumulate integral values
  ## (slooow -- this could probably be made into a built-in...)

  my($i);
  my($acc);

  for $i(0..$n - 1){
    my($bd) = $boundaries->(($i));
    $bd .= ($acc += $bd);
  }

  
  ##############################
  ## Set some final values
  
  $me->{max} = $acc;
  $me->{boundaries} = $boundaries;
  $me->{n} = $boundaries->nelem;

  return $me;
}


sub PDL::Lib::RandVar::Histogram::sample() {
  my($me,$n,$out) = @_;

  $n=1 unless(defined $n);
  $out = zeroes(pdl($n)->at(0)) unless(defined($out));

  my($o);
  if($out->dims == 0) {
    $o = $out->dummy(0,1) ;
  } else {
    $o = $out;
  }

  my($b) = $me->{boundaries};

  my($j);

##############################
## Do a binary search for the 
## value in the accumulated distribution function.
## This is also slooow -- I'm sure there's a faster 
## way.  At least it scales well with the size of the
## histogram, even if it's really slow per sample.

  my($start) = pdl(($me->{n}/2))->floor;
  my($sst) = $start->copy;
  my($bits);
  for($bits = 0; ($sst >>= 1); $bits++) {}
  my($sstart) = pdl(1 << $bits);
  print "start=$start; sstart=$sstart\n";
  
  for $j(0..$n-1) {
    my($r) = rand () * $me->{max};

    my($i) = $start->copy;
    my($step) = $sstart->copy;

    while($step > 0 && 
	  ! ( ($i==0 || $b->($i-1) <= $r)
	      &&
	      ($b->($i) > $r)
	    )
	  ) {
      if($b->($i) < $r) {
	$i += $step;
      } else {
	$i -= $step;
      }
      $step .= ($step/2)->floor;
    }
    $o->($j) .= $i->clip(0);
  }

  return $out;
}

1;
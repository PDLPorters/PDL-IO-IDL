=head1 NAME

PDL::Graphics::PGPLOT::Window - A OO interface to PGPLOT windows

=head1 SYNOPSIS

 perldl> use PDL::Graphics::PGPLOT::Window
 perldl> $win = PDL::Graphics::PGPLOT::Window->new({Device => '/xs'});
 perldl> $a = pdl [1..100]
 perldl> $b = sqrt($a)
 perldl> $win->line($b)
 perldl> $win->hold()
 perldl> $c = sin($a/10)*2 + 4
 perldl> $win->line($c)

In the following documentation the commands are not shown in their OO
versions. This is for historical reasons and should not cause too much
trouble.

=head1 DESCRIPTION

This package offers a OO interface to the PGPLOT plotting package. This
is intended to replace the traditional interface in L<PDL::Graphics::PGPLOT>
and contains interfaces to a large number of PGPLOT routines. Below the
usage examples for each function tend to be given in the non-OO version for
historical reasons. This will slowly be changed, but in the meantime refer
to the section on OO-interface below to see how to convert the usage
information below to OO usage (it is totally trivial).

PDL::Graphics::PGPLOT::Window is an interface to the PGPLOT graphical
libraries.


The list of currently availably methods:

 imag       -  Display an image (uses pgimag()/pggray() as appropriate)
 ctab       -  Load an image colour table
 ctab_info  -  Get information about currently loaded colour table
 line       -  Plot vector as connected points
 points     -  Plot vector as points
 errb       -  Plot error bars
 cont       -  Display image as contour map
 bin        -  Plot vector as histogram (e.g. bin(hist($data)) )
 hi2d       -  Plot image as 2d histogram (not very good IMHO...)
 poly       -  Draw a polygon
 vect       -  Display 2 images as a vector field
 text       -  Write text in the plot area
 label_axes -  Print axis titles
 legend     -  Create a legend with different texts, linestyles etc.
 cursor     -  Interactively read cursor positions.
 circle     -  Draw a circle
 ellipse    -  Draw an ellipse.

Device manipulation commands:

 new          -  Constructor for a new PGPLOT output device
 close        -  Close a PGPLOT output device
 focus        -  Set focus to the given device. This should normally be
                 done behind the scenes.
 hold         -  Hold current plot window range - allows overlays etc.
 release      -  Release back to autoscaling of new plot window for each 
                 command
 held         -  Returns true if the graphics is held on the current device.
 env          -  Define a plot window, put on 'hold'
 panel        -  Move to a specified plot panel when several panels are defined.
 erase        -  Erase the current window (or panel)

 options      -  Get the options set for the present output device
 id           -  The ID for the device
 device       -  The device type
 name         -  The window name



Notes: C<$transform> for image/cont etc. is used in the same way as the
C<TR()> array in the underlying PGPLOT FORTRAN routine but is, fortunately,
zero-offset.

For completeness: The transformation array connect the pixel index to a
world coordinate such that:

 X = tr[0] + tr[1]*i + tr[2]*j
 Y = tr[3] + tr[4]*i + tr[5]*j

=head2 Variable passing and extensions

In general variables are passed to the pgplot routines by using
C<get_dataref>
to get the reference to the values. Before passing to pgplot routines
however, the data are checked to see if they are in accordance with the
format (typically dimensionality) required by the PGPLOT routines.
This is done using the routine C<checkarg> (internal to PGPLOT). This routine
checks the dimensionality of the input data. If there are superfluous
dimensions of size 1 they will be trimmed away until the dimensionality
is correct. Example:

Assume a piddle with dimensions (1,100,1,1) is passed to C<line>, which
expects its inputs to be vectors. C<checkarg> will then return a piddle
with dimensions (100). If instead the same piddle was passed to C<imag>,
which requires 2D piddles as output, C<checkarg> would return a piddle
with dimensionality (100, 1) (Dimensions are removed from the I<start>)

Thus, if you want to provide support for another PGPLOT function, the
structure currently look like this (there are plans to use the Options
package to simplify the options parsing):

 # Extract the hash(es) on the commandline
 ($arg, $opt)=_extract_hash(@_); 
 <Check the number of input parameters>
 <deal with $arg>
 checkarg($x, 3); # For a hypothetical 3D routine.
 ...
 pgcube($n, $x->get_dataref);
 1;

=head2 Setting options

All routines in this package take a hash with options as an optional
input. This options hash can be used to set parameters for the
subsequent plotting without going via the PGPLOT commands.

This is implemented such that the plotting settings (such as line width,
line style etc.) are affected only for that plot, any global changes made,
say, with C<pgslw()> are preserved. Some modifications apply when using
the OO interface, see below.

=head2 Alphabetical listing of standard options

The following options are always parsed. Whether they have any importance
depend on the routine invoked - e.g. line style is irrelevant for C<imag>, 
or the C<justify> option is irrelevant if the display is on 'hold'.
This is indicated in the help text for the commands below.

The options are not case sensitive and will match for unique substrings,
but this is not encouraged as obscure options might invalidate what
you thought was a unique substring.

In the listing below examples are given of each option. The actual
option can then be used in a plot command by specifying it as an argument
to the function wanted (it can be placed anywhere in the command list).

E.g:

 $opt={COLOR=>2};
 line $x, $y, $opt; # This will plot a line with red color

=over 4

=item arrow

This options allows you to set the arrow shape, and optionally size for
arrows for the vect routine. The arrow shape is specified as a hash
with the key FS to set fill style, ANGLE to set the opening angle of
the arrow head, VENT to set how much of the arrow head is cut out and
SIZE to set the arrowsize.

The following

 $opt = {ARROW => {FS=>1, ANGLE=>60, VENT=>0.3, SIZE=>5}};

will make a broad arrow of five times the normal size.

Alternatively the arrow can be specified as a set of numbers
corresponding to an extention to the syntax for pgsah. The equivalent to
the above is

 $opt = {ARROW => pdl([1, 60, 0.3, 5})};

For the latter the arguments must be in the given order, and if any are
not given the default values of 1, 45, 0.3 and 1.0 respectively will
be used.

=item arrowsize

The arrowsize can be specified separately using this option to the
options hash. It is useful if an arrowstyle has been set up and one
wants to plot the same arrow with several sizes. Please note that it is
B<not> possible to set arrowsize and character size in the same call to
a plotting function. This should not be a problem in most cases.

 $opt = {ARROWSIZE => 2.5};

=item axis

Set the axis value (see L</env>).
It can either be specified as a number, or by one of the following names:

 EMPTY  (-2) draw no box, axes or labels
 BOX    (-1) draw box only
 NORMAL (0)  draw box and label it with coordinates
 AXES   (1)  same as NORMAL, but also draw (X=0,Y=0) axes
 GRID   (2)  same as AXES, but also draw grid lines
 LOGX   (10) draw box and label X-axis logarithmically
 LOGY   (20) draw box and label Y-axis logarithmically
 LOGXY  (30) draw box and label both axes logarithmically

=item border

Normally the limits are
chosen so that the plot just fits; with this option you can increase
(or decrease) the limits by either a relative 
(ie a fraction of the original axis width) or an absolute amount.
Either specify a hash array, where the keys are C<TYPE> (set to 
'relative' or 'absolute') and C<VALUE> (the amount to change the limits
by), or set to 1, which is equivalent to

 BORDER => { TYPE => 'rel', VALUE => 0.05 }

=item charsize

Set the character/symbol size as a multiple of the standard size.

 $opt = {CHARSIZE => 1.5}

=item colour (or color)

Set the colour to be used for the subsequent plotting. This can be
specified as a number, and the most used colours can also be specified
with name, according to the following table (note that this only works for
the default colour map):

  0 - WHITE    1 - BLACK     2 - RED      3 - GREEN    4 - BLUE
  5 - CYAN     6 - MAGENTA   7 - YELLOW   8 - ORANGE  14 - DARKGRAY
 16 - LIGHTGRAY

=item filltype

Set the fill type to be used by L<poly|/poly>. 
The fill can either be specified using numbers or name, according to the 
following table, where the recognised name is shown in capitals - it is 
case-insensitive, but the whole name must be specified.

 1 - SOLID
 2 - OUTLINE
 3 - HATCHED
 4 - CROSS_HATCHED

 $opt = {FILLTYPE => 'SOLID'};

(see below for an example of hatched fill)

=item font

Set the character font. This can either be specified as a number following
the PGPLOT numbering or name as follows (name in capitals):

 1 - NORMAL
 2 - ROMAN
 3 - ITALIC
 4 - SCRIPT

(Note that in a string, the font can be changed using the escape sequences
C<\fn>, C<\fr>, C<\fi> and C<\fs> respectively)

 $opt = {FONT => 'ROMAN'};

gives the same result as

 $opt = {FONT => 2};

=item hatching

Set the hatching to be used if either fillstyle 3 or 4 is selected
(see above) The specification is similar to the one for specifying
arrows.  The arguments for the hatching is either given using a hash
with the key ANGLE to set the angle that the hatch lines will make
with the horizontal, SEPARATION to set the spacing of the hatch lines
in units of 1% of C<min(height, width)> of the view surface, and PHASE to
set the offset the hatching. Alternatively this can be specified as a
1x3 piddle C<$hatch=pdl[$angle, $sep, $phase]>.

 $opt = {FILLTYPE => 'HATCHED', 
         HATCHING => {ANGLE=>30, SEPARATION=>4}};

Can also be specified as

 $opt = {FILL=> 'HATCHED', HATCH => pdl [30,4,0.0]};

For another example of hatching, see L</poly>.

=item justify

A boolean value which, if true, causes both axes to drawn
to the same scale; see
the PGPLOT C<pgenv()> command for more information.

=item linestyle

Set the line style. This can either be specified as a number following
the PGPLOT numbering:

 1 - SOLID line
 2 - DASHED
 3 - DOT-DASH-dot-dash
 4 - DOTTED
 5 - DASH-DOT-DOT-dot

or using name (as given in capitals above).
Thus the following two specifications both specify the line to be dotted:

 $opt = {LINESTYLE => 4};
 $varopt = {LINESTYLE => 'DOTTED'};

The names are not case sensitive, but the full name is required.

=item linewidth

Set the line width. It is specified as a integer multiple of 0.13 mm.

 $opt = {LINEWIDTH => 10}; # A rather fat line

=back

=head1 OBJECT-ORIENTED INTERFACE

This section will briefly describe how the PDL::Graphics::PGPLOT::Window
package can be used in an object-oriented (OO) approach and what the
advantages of this would be. We will start with the latter

=over

=item Multiple windows.

For the common user it is probably most interesting to use the OO interface
when handling several open devices at the same time. If you have one
variable for each plot device it is easier to distribute commands to the
right device at the right time. This is the angle we will take in the rest
of this description.

=item Coding and abstraction

At a more fundamental level it is desirable to approach a situation where
it is possible to have a generic plotting interface which gives access
to several plotting libraries, much as PGPLOT gives access to different
output devices. Thus in such a hypothetical package one would say:

  my $win1 = Graphics::new('PGPLOT', {Device => '/xs'});
  my $win2 = Graphics::new('gnuplot', {Background => 'Gray'};

From a more practical point of of view such abstraction also comes in
handy when you write a large program package and you do not want to import
routines nilly-willy in which case an OO approach with method calls is a
lot cleaner.


=back

Anyway, enough philosophizing, let us get down to Earth and give some
examples of the use of OO PGPLOT. As an example we will take Odd (which
happens to be a common Norwegian name) who is monitoring the birth of
rabbits in O'Fib-o-nachy's farm (alternatively he can of course be
monitoring processes or do something entirely different). Odd wants the
user to be able to monitor both the birth rates and accumulated number
of rabbits and the spatial distribution of the births. Since these are
logically different he chooses to have two windows open:

  $rate_win = PDL::Graphics::PGPLOT::Window->new({Device => '/xw',
              Aspect => 1, WindowWidth => 5, NXPanel => 2});

  $area_win = PDL::Graphics::PGPLOT::Window->new({Device => '/xw',
              Aspect => 1, WindowWidth => 5});

See the documentation for L<new> below for a full overview of the
options you can pass to the constructor.

Next, Odd wants to create plotting areas for subsequent plots and maybe
show the expected theoretical trends

  $rate_win->env(0, 10, 0, 1000, {XTitle => 'Days', YTitle => '#Rabbits'});
  $rate_win->env(0, 10, 0, 100, {Xtitle=>'Days', Ytitle => 'Rabbits/day'});

  $area_win->env(0, 1, 0, 1, {XTitle => 'Km', Ytitle => 'Km'});
  # And theoretical prediction.
  $rate_win->line(sequence(10), fibonacci(10), {Panel => [1, 1]});

That is basically it. The commands should automatically focus the relevant
window. Due to the limitations of PGPLOT this might however lead you to
plot in the wrong panel... The package tries to be smart and do this
correctly, but might get it wrong at times.


=head1 FUNCTIONS

A more detailed listing of the functions and their usage follows. For
all functions we specify which options take effect and what other options
exist for the given function. The function descriptions below are all
given for the non-OO usage for historical reasons, but since the conversion
to an OO method is trivial there is no major need for concern. Whenever you
see a function example of the form

  Usage: a_simple_function($x, $y, $z [, $opt]);

and you wish to use the OO version, just let your mind read the above line
as:

  Usage: $win->a_simple_function($x, $y, $z [, $opt]);

where C<$win> is a PDL::Graphics::PGPLOT::Window object. That is all.


=head2 Window control functions.

=head2 new

=for ref

Constructor for PGPLOT object/device/plot window.

=for usage

Usage: PDL::Graphics::PGPLOT::Window->new($opt);

C<$opt> is a reference to a hash with options for the new device. The options
recognised are the following:

=over

=item AspectRatio

The aspect ratio of the image, in the sense vertical/horisontal.

=item Device

The type of device to use. The syntax of this is the one used by PGPLOT.

=item Hold

Hold the plot window so that subsequent plots can plot over existing plots.
This can be adjusted with the C<hold()> and C<release()> methods.

=item NXPanel

The number of panels in the X-direction

=item NYPanel

The number of panels in the Y-direction

=item WindowName

The name to give to the window. No particular use is made of this at present.
It would be great if it was possible to change the title of the window frame.

=item WindowWidth

The width of the window in inches. If this is set to 0.0, the biggest window
consistent with the AspectRatio setting will be chosen.

=item WindowXSize and WindowYSize

These two options allow an alternative setting of WindowWidth and AspectRatio.
Their values are actually not parsed here, but rather subsequently in the
C<_setup_window> routine below.

=back

An important point to note is that the default values of most options can be
specified by passing these to the constructor. All general options (common to
several functions) can be adjusted in such a way, but function specific
options can not be set in this way (this is a design limitation which is
unlikely to be changed).

Thus the following call will set up a window where the default axis colour
will be yellow and where plot lines normally have red colour and dashed
linestyle.

  $win = PDL::Graphics::PGPLOT::Window->new({Device => '/xs',
          AxisColour => 'Yellow', Colour => 'Red', LineStyle => 'Dashed'});


=head2 close

=for ref

Close a plot window

=for usage

  Usage: $w->close()

Close the current window. This does not necessarily mean that the
window is removed from your screen, but it does ensure that the
device is closed.

=head2 held

=for ref

Check if a window is on hold

=for usage

  $is_held = held();

Function to check whether the window is held or not.


=head2 hold

=for ref

Hold the present window.

=for usage

 Usage: hold()

Holds the present window so that subsequent plot commands overplots.


=head2 panel

=for ref

Switch to a different panel

=for usage

  $w->panel(<num>);

Move to a different panel on the plotting surface. Note that you will need
to erase it manually if that is what you require.

=head2 release

=for ref

Release a plot window.

=for usage

   release()

Release a plot window so that subsequent plot commands move to the next
panel or erase the plot and create a new plot.

=head2 erase

=for ref

Erase plot

=for usage

  Usage: erase($opt);

Erase a plot area. This accepts the option C<Panel> or alternatively a number
or array reference which makes it possible to specify the panel to erase when
working with several panels.



=head2 Plotting functions

=head2 env

=for ref

Define a plot window, and put graphics on 'hold'

=for usage

 Usage: env $xmin, $xmax, $ymin, $ymax, [$justify, $axis];
        env $xmin, $xmax, $ymin, $ymax, [$options];

C<$xmin>, C<$xmax>, C<$ymin>, C<$ymax> are the plot boundaries.  
C<$justify> is a boolean value (default is B<0>);
if true the axes scales will be the same (see L</justify>).
C<$axis> describes how the axes should be drawn (see
L</axis>) and defaults to B<0>.

If the second form is used, $justify and $axis can be set in the options
hash, for example:

 env 0, 100, 0, 50, {JUSTIFY => 1, AXIS => 'GRID', CHARSIZE => 0.7};

In addition the following options can also be set for C<env>:

=over

=item PlotPosition

The position of the plot on the page relative to the view surface in
normalised coordinates as an anonymous array. The array should contain
the lower and upper X-limits and then the lower and upper Y-limits. To
place two plots above each other with no space between them you could do

  env(0, 1, 0, 1, {PlotPosition => [0.1, 0.5, 0.1, 0.5]});
  env(5, 9, 0, 8, {PlotPosition => [0.1, 0.5, 0.5, 0.9]});

=item Axis, Justify, Border

See the description of general options for these options.

=item AxisColour

Set the colour of the coordinate axes.

=item XTitle, YTitle, Title, Font, CharSize

Axes titles and the font and size to print them.

=back


=head2 label_axes

=for ref

Label plot axes

=for usage

  Usage: label_axes(<xtitle>, <ytitle>, <plot title>, $options);

Draw labels for each axis on a plot.

=head2 imag

=for ref

Display an image (uses C<pgimag()>/C<pggray()> as appropriate)

=for usage

 Usage: imag ( $image,  [$min, $max, $transform], [$opt] )

Notes: C<$transform> for image/cont etc. is used in the same way as the
C<TR()> array in the underlying PGPLOT FORTRAN routine but is, 
fortunately, zero-offset.

There are several options related to scaling.  By default, the image
is scaled to fit the PGPLOT default viewport on the screen.  Scaling,
aspect ratio preservation, and 1:1 pixel mapping are available.  
(1:1 pixel mapping GREATLY increases the speed of pgimag, and is useful
for, eg, movie display; but it's not recommended for final output as 
it's not device-independent.)

Options recognised:

       ITF - the image transfer function applied to the pixel values. It
             may be one of 'LINEAR', 'LOG', 'SQRT' (lower case is 
             acceptable). It defaults to 'LINEAR'.
      MIN  - Sets the minimum value to be used for calculation of the
             display stretch
      MAX  - Sets the maximum value for the same
 TRANSFORM - The transform 'matrix' as a 6x1 vector for display
      PIX  - Sets the image pixel aspect ratio.  By default, imag
             stretches the image pixels so that the final image aspect
             ratio fits the viewport exactly.  Setting PIX=>1 causes
             the image aspect ratio to be preserved.  (the image is
             scaled to avoid cropping, unless you specify scaling 
             manually).  Larger numbers yield "landscape mode" pixels.
     PITCH - Sets the number of image pixels per screen unit, in the Y
             direction.  The X direction is determined by PIX, which 
             defaults to 1 if PITCH is specified and PIX is not.  PITCH 
             causes UNIT to default to "inches" so that it is easy to say 
             100dpi by specifying {PITCH=>100}.  Larger numbers yield 
             higher resolution (hence smaller appearing) images.
      UNIT - Sets the screen unit used for scaling.  Must be one of the
             PGPLOT supported units (inch, mm, pixel, normalized).  You
             can refer to them by name or by number.  Defaults to pixels
             if not specified.
     SCALE - Syntactic sugar for the reciprocal of PITCH.  Makes the
             UNIT default to "pixels" so you can say "{SCALE=>1}"
             to see your image in device pixels.   Larger SCALEs lead
             to larger appearing images.

The following standard options influence this command:

 AXIS, BORDER, JUSTIFY

=for example

   To see an image with maximum size in the current window, but square
   pixels, say:
         imag $a,{PIX=>1}
   An alternative approach is to try:
         imag $a,{JUSTIFY=>1}
   To see the same image, scaled 1:1 with device pixels, say:
         imag $a,{SCALE=>1}
   To see an image made on a device with 1:2 pixel aspect ratio, with 
   X pixels the same as original image pixels, say
         imag $a,{PIX=>0.5,SCALE=>2}
   To display an image at 100 dpi on any device, say:
         imag $a,{PITCH=>100}
   To display an image with 100 micron pixels, say:
         imag $a,{PITCH=>10,UNIT=>'mm'}

=head2 imag1

=for ref

Display an image with correct aspect ratio 

=for usage

 Usage:  imag1 ( $image, [$min, $max, $transform], [$opt] )

Notes: This is syntactic sugar for imag({PIX=>1}).

=head2 ctab

=for ref

Load an image colour table. 

Usage:

=for usage

   ctab ( $name, [$contrast, $brightness] ) # Builtin col table
   ctab ( $ctab, [$contrast, $brightness] ) # $ctab is Nx4 array
   ctab ( $levels, $red, $green, $blue, [$contrast, $brightness] )
   ctab ( '', $contrast, $brightness ) # use last color table

Note: See L<PDL::Graphics::LUT|PDL::Graphics::LUT> for access to a large
number of colour tables.

=head2 line

=for ref

Plot vector as connected points

If the 'MISSING' option is specified, those points in the C<$y> vector
which are equal to the MISSING value are not plotted, but are skipped
over.  This allows one to quickly draw multiple lines with one call to
C<line>, for example to draw coastlines for maps.

=for usage

 Usage: line ( [$x,] $y, [$opt] )

The following standard options influence this command:

 AXIS, BORDER, COLO(U)R, JUSTIFY, LINESTYLE, LINEWIDTH, MISSING

=for example

 $x = sequence(10)/10.;
 $y = sin($x)**2;
 # Draw a red dot-dashed line
 line $x, $y, {COLOR => 'RED', LINESTYLE=>3}; 

=head2 points

=for ref

Plot vector as points

=for usage

 Usage: points ( [$x,] $y, [$symbol(s)], [$opt] )

Options recognised:

   SYMBOL - Either a piddle with the same dimensions as $x, containing
            the symbol associated to each point or a number specifying
            the symbol to use for every point, or a name specifying the
            symbol to use according to the following (recognised name in
	     capital letters):
             0 - SQUARE   1 - DOT     2 - PLUS     3 - ASTERISK
             4 - CIRCLE   5 - CROSS   7 - TRIANGLE 8 - EARTH
             9 - SUN     11 - DIAMOND 12- STAR
 PLOTLINE - If this is >0 a line will be drawn through the points.

The following standard options influence this command:

 AXIS, BORDER, CHARSIZE, COLOUR, JUSTIFY, LINESTYLE, LINEWIDTH

=for example

 $y = sequence(10)**2+random(10);
 # Plot blue stars with a solid line through:
 points $y, {PLOTLINE => 1, COLOUR => BLUE, SYMBOL => STAR};

=head2 errb

=for ref

Plot error bars (using C<pgerrb()>)

Usage:

=for usage

 errb ( $y, $yerrors, [$opt] )
 errb ( $x, $y, $yerrors, [$opt] )
 errb ( $x, $y, $xerrors, $yerrors, [$opt] )
 errb ( $x, $y, $xloerr, $xhierr, $yloerr, $yhierr, [$opt])

Options recognised:

   TERM - Length of terminals in multiples of the default length
 SYMBOL - Plot the datapoints using the symbol value given, either
          as name or number - see documentation for 'points'

The following standard options influence this command:

 AXIS, BORDER, CHARSIZE, COLOUR, JUSTIFY, LINESTYLE, LINEWIDTH

=for example

 $y = sequence(10)**2+random(10);
 $sigma=0.5*sqrt($y);
 errb $y, $sigma, {COLOUR => RED, SYMBOL => 18};

=head2 cont

=for ref

Display image as contour map

=for usage

 Usage: cont ( $image,  [$contours, $transform, $misval], [$opt] )

Notes: C<$transform> for image/cont etc. is used in the same way as the
C<TR()> array in the underlying PGPLOT FORTRAN routine but is, 
fortunately, zero-offset.

Options recognised:

    CONTOURS - A piddle with the contour levels
      FOLLOW - Follow the contour lines around (uses pgcont rather than
               pgcons) If this is set >0 the chosen linestyle will be
               ignored and solid line used for the positive contours
               and dashed line for the negative contours.
      LABELS - An array of strings with labels for each contour
 LABELCOLOUR - The colour of labels if different from the draw colour
               This will not interfere with the setting of draw colour
               using the colour keyword.
     MISSING - The value to ignore for contouring
   NCONTOURS - The number of contours wanted for automatical creation,
               overridden by CONTOURS
   TRANSFORM - The pixel-to-world coordinate transform vector

The following standard options influence this command:

 AXIS, BORDER, COLOUR, JUSTIFY, LINESTYLE, LINEWIDTH

=for example

 $x=sequence(10,10);
 $ncont = 4;
 $labels= ['COLD', 'COLDER', 'FREEZING', 'NORWAY']
 # This will give four blue contour lines labelled in red.
 cont $x, {NCONT => $ncont, LABELS => $labels, LABELCOLOR => RED,
           COLOR => BLUE}

=head2 bin

=for ref

Plot vector as histogram (e.g. C<bin(hist($data))>)

=for usage

 Usage: bin ( [$x,] $data )

Options recognised:

 CENTRE - if true, the x values denote the centre of the bin 
          otherwise they give the lower-edge (in x) of the bin
 CENTER - as CENTRE

The following standard options influence this command:

 AXIS, BORDER, COLOUR, JUSTIFY, LINESTYLE, LINEWIDTH

=head2 hi2d

=for ref

Plot image as 2d histogram (not very good IMHO...)

=for usage

 Usage: hi2d ( $image, [$x, $ioff, $bias], [$opt] )

Options recognised:

 IOFFSET - The offset for each array slice. >0 slants to the right
                                            <0 to the left.
    BIAS - The bias to shift each array slice up by.

The following standard options influence this command:

 AXIS, BORDER, JUSTIFY

Note that meddling with the C<ioffset> and C<bias> often will require you to
change the default plot range somewhat. It is also worth noting that if
you have TriD working you will probably be better off using 
L<mesh3d|PDL::Graphics::TriD/mesh3d> or
a similar command - see L<PDL::Graphics::TriD>.

=for example

 $r=sequence(100)/50-1.0;
 $y=exp(-$r**2)*transpose(exp(-$r**2))
 hi2d $y, {IOFF => 1.5, BIAS => 0.07};

=head2 arrow

=for ref

Plot an arrow

=for usage

 Usage: arrow($x1, $y1, $x2, $y2, [, $opt]);

Plot an arrow from C<$x1, $y1> to C<$x2, $y2>. The arrow shape can be
set using the option C<Arrow>. See the documentation for general options
for details about this option (and the example below):

=for example

Example:

  arrow(0, 1, 1, 2, {Arrow => {FS => 1, Angle => 60, Vent => 0.3, Size => 5}});

which draws a broad, large arrow from (0, 1) to (1, 2).


=head2 poly

=for ref

Draw a polygon

=for usage

 Usage: poly ( $x, $y )

Options recognised:

The following standard options influence this command:

 AXIS, BORDER, COLOUR, FILLTYPE, HATCHING, JUSTIFY, LINESTYLE, 
 LINEWIDTH

=for example

 # Fill with hatching in two different colours
 $x=sequence(10)/10;
 # First fill with cyan hatching
 poly $x, $x**2, {COLOR=>5, FILL=>3};
 hold;
 # Then do it over again with the hatching offset in phase:
 poly $x, $x**2, {COLOR=>6, FILL=>3, HATCH=>{PHASE=>0.5}};
 release;

=head2 circle

=for ref

Plot a circle on the display using the fill setting.

=for usage

 Usage: circle($x, $y, $radius [, $opt]);

All arguments can alternatively be given in the options hash using the
following options:

=over

=item XCenter and YCenter

The position of the center of the circle

=item Radius

The radius of the circle.


=back

=head2 ellipse

=for ref

Plot an ellipse, optionally using fill style.

=for usage

 Usage: ellipse($x, $y, $a, $b, $theta [, $opt]);

All arguments can alternatively be given in the options hash using the
following options:

=over

=item MajorAxis

The major axis of the ellipse - this must be defined or C<$a> must be given.

=item MinorAxis

The minor axis, like A this is required.

=item Theta (synonym Angle)

The orientation of the ellipse - defaults to 0.0. This is given in
radians.

=item XCenter and YCenter

The coordinates of the center of the ellipse. These must be specified or
C<$x> and C<$y> must be given.

=item NPoints

The number of points used to draw the ellipse. This defaults to 100 and
might need changing in the case of very large ellipses.


=back


=head2 rectangle

=for ref

Draw a rectangle.

=for usage

 Usage: rectangle($xcenter, $ycenter, $xside, $yside, [, $angle, $opt]);

This routine draws a rectangle with the chosen fill style. Internally
it calls L<poly> which is somewhat slower than C<pgrect> but which
allows for rotated rectangles as well. The routine recognises the same
options as poly and in addition the following

=over

=item XCenter and YCenter

The position of the center of the rectangle. XCentre and YCentre are
valid synonyms.

=item XSide and YSide

The length of the X and Y sides. If only one is specified the
shape is taken to be square with that as the side-length, alternatively
the user can set Side

=item Side

The length of the sides of the rectangle (in this case a square) - syntactic
sugar for setting XSide and YSide identical. This is overridden by XSide
or YSide if any of those are set.

=item Angle (synonym Theta)

The angle at which the rectangle is to be drawn. This defaults to 0.0 and
is given in radians.


=back


=head2 vect

=for ref

Display 2 images as a vector field

=for usage

 Usage: vect ( $a, $b, [$scale, $pos, $transform, $misval] )

Notes: C<$transform> for image/cont etc. is used in the same way as the
C<TR()> array in the underlying PGPLOT FORTRAN routine but is, 
fortunately, zero-offset.

This routine will plot a vector field. C<$a> is the horizontal component
and C<$b> the vertical component.

Options recognised:

     SCALE - Set the scale factor for vector lengths.
       POS - Set the position of vectors.
             <0 - vector head at coordinate
             >0 - vector base at coordinate
             =0 - vector centered on the coordinate
 TRANSFORM - The pixel-to-world coordinate transform vector
   MISSING - Elements with this value are ignored.

The following standard options influence this command:

 ARROW, ARROWSIZE, AXIS, BORDER, CHARSIZE, COLOUR, JUSTIFY, 
 LINESTYLE, LINEWIDTH

=for example

 $a=rvals(11,11,{Centre=>[5,5]});
 $b=rvals(11,11,{Centre=>[0,0]});
 vect $a, $b, {COLOR=>YELLOW, ARROWSIZE=>0.5, LINESTYLE=>dashed};


=head2 transform

=for ref

Create transform array for contour and image plotting

=for usage

 Usage: transform([$xdim], [$ydim], $options);

This function creates a transform array in the format required by the image
and contouring routines. You must call it with the dimensions of your image
as arguments or pass these as an anonymous hash - see the example below.

=over

=item Angle

The rotation angle of the transform

=item ImageDimensions

The dimensions of the image the transform is required for. The dimensions
should be passed as a reference to an anonymous hash.

=item Pixinc

The increment in output coordinate per pixel.

=item ImageCenter

The centre of the image as an anonymous array  B<or> as a scalar. In the
latter case the x and y value for the center will be set equal to this
scalar. This is particularly useful in the common case  when the center
is (0, 0).

=back

Example:

   $im = rvals(100, 100);
   $w = PDL::Graphics::PGPLOT::Window->new({Device => '/xs'});
   $t = $w->transform(dims($im), {ImageCenter => 0,  Pixinc => 5});
   $w->imag($im, {Transform => $t});

=head2 tline

=for ref

Threaded line plotting

=for usage

 Usage: tline($x, $y, $optionts);

This is a threaded interface to C<line>. This is convenient if you have
a 2D array and want to plot out every line in one go. The routine will
apply any options you apply in a "reasonable" way. In the sense that it
will loop over the options wrapping over if there are less options than
lines.

Example:

  $h={Colour => ['Red', '1', 4], Linestyle => ['Solid' ,'Dashed']};
  $tx=zeroes(100,5)->xlinvals(-5,5);
  $ty = $tx + $tx->yvals;
  tline($tx, $ty, $h);


=head2 tpoints

=for ref

A threaded interface to points

=for usage

 Usage: tpoints($x, $y, $options);

This is a threaded interface to C<points>. This is convenient if you have
a 2D array and want to plot out every line in one go. The routine will
apply any options you apply in a "reasonable" way. In the sense that it
will loop over the options wrapping over if there are less options than
lines.

Example:

  $h={Colour => ['Red', '1', 4], Linestyle => ['Solid' ,'Dashed']};
  $tx=zeroes(100,5)->xlinvals(-5,5);
  $ty = $tx + $tx->yvals;
  tpoints($tx, $ty, $h);


=head2 Text routines


=head2 text

=for ref

Write text in a plot window at a specified position.

=for usage

 Usage: text ($text, $x, $y [, $opt])

Options recognised:

=over

=item C<ANGLE>

The angle in degrees between the baseline of the text and
the horisontal (increasing counter-clockwise). This defaults to 0.

=item C<JUSTIFICATION>

The justification of the text relative to the position specified. It
defaults to 0.0 which gives left-justified text. A value of 0.5 gives
centered text and a value of 1.0 gives right-justified text.

=item C<XPos>, C<YPos>, C<Text>

These gives alternative ways to specify the text and position.

=back

The following standard options influence this command:

   COLOUR

=for example

  line sequence(10), sequence(10)**2;
  text 'A parabola', 3, 9, {Justification => 1, Angle=>atan2(6,1)};


=head2 legend

=for ref

Add a legend to a plot

=for usage

 Usage: legend($text, $x, $y, [, $width], $opt]);

This function adds a legend to an existing plot. The action is primarily
controlled by information in the options hash, and the basic idea is that
C<$x> and C<$y> determines the upper left hand corner of the box in which
the legend goes. If the width is specified either as an argument or as
an option in the option hash this is used to determine the optimal character
size to fit the text into part of this width (defaults to 0.5 - see the
description of C<Fraction> below). The rest of the width is filled out with
either lines or symbols according to the content of the C<LineStyle>,
C<Symbol>, C<Colour> and C<LineWidth> options.

The local options recognised are as follows:

=over

=item C<Text>

An anonymous array of annotations, can also be specified directly.

=item C<XPos> and C<YPos>

The X and Y position of the upper left-hand corner of the text.

=item C<Width> and C<Height>

The width and/or height of each line (including symbol/line). This is
used to determine the character size. If any of these are set to 'Automatic'
the current character size will be used.

=item C<Fraction>

The text and the symbol/line is set inside a box. C<Fraction> determines how
much of this box should be devoted to text. THis defaults to 0.5.

=item C<TextShift>

This option allows for fine control of the spacing between the text and the
start of the line/symbol. It is given in fractions of the total width of the
legend box. The default value is 0.1.

=back

=for example

  line $x, $y, {Color => 'Red', LineStyle => 'Solid'};
  line $x2, $y2, {Color => 'Blue', 'LineStyle' => 'Dashed', LineWidth => 10};

  legend 5, 5, ['A red line', 'A blue line'],
      {LineStyle => ['Solid', 'Dashed'], Colour => ['Red', 'Blue']
       LineWidth => [undef, 10]}; # undef gives default.


=head2 Cursor routines

=head2 cursor

=for ref

Interactively read cursor positions.

=for usage

 Usage: ($x, $y, $ch, $xref, $yref) = cursor($opt)

This routine has no standard input parameters, but the type of cursor
can be set by setting the option C<Type> as a key in the anonymous hash
C<$opt>. The first three return values from the function are always
defined and gives the position selected by the user and the character
pressed.

Depending on the cursor type selected the last two arguments might also
be defined and these give a reference position. For instance if the cursor
is selected to be C<Rectangle> then the reference position gives one of
the corners of the rectangle and C<$x> and C<$y> the diagonally opposite
one.

Options recognised:

=over

=item XRef, YRef

The reference position to be used

=item Type

The type of cursor. This can be selected using a number between 0 and 7 as
in PGPLOT, or alternatively you can specify these as, C<Default> (0),
C<RadialLine> (1), C<Rectangle> (2), C<TwoHorizontalLines> (3),
C<TwoVerticalLines> (4), C<HorizontalLine> (5), C<VerticalLine> (6)
and C<CrossHair> (7) respectively. The default cursor is just the normal
mouse cursor.

For the C<RadialLine> you I<must> specify the reference point, whereas for
the C<Two(Vertical|Horizontal)Lines> cursor the X or Y reference point,
respectively, must be specified.

=back

=for example

To select a region on a plot, use the rectangle cursor:

  ($x, $y, $ch, $xref, $yref) = cursor({Type => 'Rectangle'});
  poly pdl($x, $xref, $xref, $x, $x), pdl($y, $y, $yref, $yref, $y);

To select a region of the X-axis:

  ($x1, $y1, $ch) = cursor({Type => 'VerticalLine'});
  ($x2, $y2, $ch) = cursor({Type => 'TwoVerticalLines', XRef => $x1});


=head2 Internal routines

=cut




#'

package PDL::Graphics::PGPLOT::Window;

use PDL::Core qw/:Func :Internal/; # Grab the Core names
use PDL::Basic;
use PDL::Ufunc;
use PDL::Primitive;
use PDL::Types;
use PDL::Options;
use PDL::Graphics::PGPLOTOptions qw(default_options);
use SelfLoader;
use Exporter;
use PGPLOT;

require DynaLoader;

@ISA = qw( Exporter SelfLoader DynaLoader );

bootstrap PDL::Graphics::PGPLOT::Window;

my ($GeneralOptions, $WindowOptions) = default_options();
# Turn off warnings for missing options...
$GeneralOptions->warnonmissing(0);
$WindowOptions->warnonmissing(0);


my $PREVIOUS_DEVICE = undef;
my $PI = 4*atan2(1,1);


sub new {

  my $type = shift;
  my $u_opt = shift;

  $u_opt={} unless defined($u_opt);
  my $opt = $WindowOptions->options($u_opt);
  $WindowOptions->full_options(0);
  my $user_options = $WindowOptions->current();
  $WindowOptions->full_options(1);

  # If the user set DEVICE then that overrides anything else...
  if (exists $user_options->{Device}) {
    $dev = $opt->{Device}
  } elsif (!defined($dev) || $dev eq "") {
    # Fall back on the default if first time or use $DEV otherwise..
    $dev = $PREVIOUS_DEVICE || $opt->{Device};
  }
  $PREVIOUS_DEVICE = $dev;


  my $this_opt = PDL::Options->new($opt);
  my $t=$WindowOptions->translation();
  $this_opt->translation($t);
  my $s=$WindowOptions->synonyms();
  $this_opt->synonyms($s);
  $this_opt->warnonmissing(0);

  # This is the setup for the plot options - which also can
  # be set on a per-window basis by the user.
  my $popt = $GeneralOptions->options($u_opt);
  my $this_plotopt = PDL::Options->new($popt);
  $t = $GeneralOptions->translation();
  $this_plotopt->translation($t);
  $s = $GeneralOptions->synonyms();
  $this_plotopt->synonyms($s);
  $this_plotopt->warnonmissing(0);

  my $self = {
	      'Options'	      => $this_opt,
	      'PlotOptions'   => $this_plotopt,
	      'Hold'	      => $opt->{Hold}		  || 0,
	      'Name'	      => $opt->{WindowName}	  || '',
	      'ID'	      => undef,
	      'AspectRatio'   => $opt->{AspectRatio}	  || 0.618,
	      'WindowWidth'   => $opt->{WindowWidth}	  || 0.0,
	      'NX'	      => $opt->{NXPanel}	  || 1,
	      'NY'	      => $opt->{NYPanel}	  || 1,
	      'Device'	      => $opt->{Device}		  || $DEV,
	      'CurrentPanel'  => 0,
	      '_env_options'  => undef
	     };

  if (defined($self->{Options})) {
    # Turn off warnings about missing options
    $self->{Options}->warnonmissing(0);
  }

  bless $self, ref($type) || $type;

  $self->_open_new_window($opt);


  return $self;

}


#
# Graphics windows should be closed when they go out of scope.
# Thanks to Doug Burke for pointing this out.
#
sub DESTROY {
  my $self=shift;

  $self->close();
}


=head2 _open_new_window

Open a new window. This sets the window ID, which is the one used when
accessing a window later using C<pgslct>. It also sets the window name
to something easily remembered if it has not been set before.

=cut

sub _open_new_window {

  my $self = shift;

  my $window_nr = pgopen($self->{Device});
  if ($window_nr < 0) {
    barf("Opening new window (pgopen) failed: $window_nr\n");
  }
  $self->{ID} = $window_nr;
  $self->{Name} = "Window$window_nr" if $self->{Name} eq "";

  $self->_setup_window(@_);

}


=head2 _setup_window

This routine sets up a new window with its shape and size. This is also where
the two options C<WindowXSize> and C<WindowYSize> is parsed. These are then
forgotten (well, they are stored in $self->{Options}, but forget that) and
the corresponding aspect ratio and window width is stored.

Finally the subpanels are set up using C<pgsubp> and colours and linewidth
are adjusted according to whether we have a hardcopy device or not.

=cut

sub _setup_window {
  my $self = shift;
  my $opt = shift;

  my $aspect = $self->{AspectRatio};
  my $width = $self->{WindowWidth};

  # Now some error-checking..
  if (defined($opt->{WindowXSize}) && defined($opt->{WindowYSize})) {
    if ($opt->{WindowXSize} == 0 || $opt->{WindowYSize}==0) {
      warn "A window can not have zero size in any direction!\n";
      print "The size options are ignored!\n";
    } else {
      # Check this!
      $aspect = $opt->{WindowXSize}/$opt->{WindowYSize};
      $width = $opt->{WindowXSize};
    }
  }
  $self->{AspectRatio}=$aspect;
  $self->{WindowWidth}=$width;

  # Ok - call pgpap to set the size.
  # print "Window opened with Width=$width and AspectRatio=$aspect\n";
  pgpap($width, $aspect);

  # Now do the sub-division into panels.
  my $nx = $self->{NX};
  my $ny = $self->{NY};
  if ($nx < 0) {
    warn "We do not support the alternative numbering of panels of PGPLOT!\n";
    $nx = abs($nx);
    $self->{NX}=abs($self->{NX});
  }
  pgsubp($nx, $ny);

  # Setup the colours
  my $o = $self->{Options}->current();
  pgask(0);
  pgqinf("HARDCOPY",$hcopy,$len);
  if ($hcopy eq "YES") {
    # This has changed to set the defaults instead.
    pgslw($o->{HardLW});
    pgsch($o->{HardCH});
    pgscf($o->{HardFont});
    # To change defaults you first need to read them out and then
    # adjust them and set them again
    my $temp_wo = $self->{PlotOptions}->defaults();
    $temp_wo->{Font}= $o->{HardFont};
    $temp_wo->{CharSize}= $o->{HardCH};
    $temp_wo->{LineWidth}= $o->{HardLW};
    $self->{PlotOptions}->defaults($temp_wo);
    my $temp_o=$self->{Options}->defaults();
    $temp_o->{AxisColour}=$o->{HardAxisColour};
    $self->{Options}->defaults($temp_o);
  }
  my ($hcopy, $len);
  my $wo = $self->{PlotOptions}->defaults();

  pgsci($wo->{Colour});
  pgask(0);

}

sub _set_defaults {		# Set up defaults

  # Now check if this is a hardcopy device, in which case we
  # set a variety of properties differently.
  my $self = shift;

}




=head2 _status

This routine checks the status of the window. It returns OPEN if the window
is open and CLOSED if it is closed.

=cut

sub _status {

  my $self=shift;
  $self->focus();
  my ($state, $len);
  pgqinf('STATE',$state,$len);

  return $state;

}

=head2 _reopen

This functions reopens a window. Since this is an internal function it does
not have a lot of error-checking. Make sure the device is closed I<before>
calling this routine.

There is an unfortunate problem which pops up viz. that the window name
cannot be changed at this point since we are offering that to the rest of
the world. That might be sensible, but it means that the window name will
not reflect the id of the window - use C<id()> for that (this is also why
we do not call C<open_new_window> )

=cut

sub _reopen {

  my $self = shift;
  my $window_nr = pgopen($self->{Device});
  if ($window_nr < 0) {
    barf("Opening new window (pgopen) failed: $window_nr\n");
  }
  $self->{ID} = $window_nr;

  $self->_setup_window(@_);

}


=head2 _advance_panel

This routine advances one plot panel, updating the CurrentPanel as well.
If the advance will proceed past the page the page will be erased. Also
note that when you advance one panel the hold value will be changed.

=cut

sub _advance_panel {
  my $self = shift;

  my $new_panel = $self->{CurrentPanel}+1;
  if ($new_panel > ($self->{NX}*$self->{NY})) {
    # We are at the end of the page..
    $new_panel = 1;
#    $self->{_env_set}=[];
  }

  $self->panel($new_panel);
  if ($self->held()) {
    $self->{Hold}=0;
    print "Graphic released (panel move)\n" if $PDL::verbose;
  }

}


=head2 _check_move_or_erase

This routine is a utility routine which checks if we need to move panel,
and if so will do this. It also checks if it is necessary to advance panels,
and whether they need to be erased.

=cut

sub _check_move_or_erase {

  my $self=shift;
  my ($panel, $erase)=@_;

  if (defined($panel)) {
    $self->panel($panel);
  } elsif (!$self->held()) {
    # If no hold has been set.
    $self->_advance_panel();
  }

  $self->erase() if $erase;

}


=head2 _thread_options

This function is a cludgy utility function that expands an options hash
to an array of hashes looping over options. This is mainly of use for
"threaded" interfaces to standard plotting routines.

=cut


sub _thread_options {
  my ($n, $h) = @_;

  # Loop over each option.
  my @hashes=(); # One for each option.
  my @keys = keys %$h;
  foreach my $k (@keys) {
    my @vals=();
    my $v=$h->{$k};
    $v = [$v] if ref($v) ne 'ARRAY';
    while ($#vals+1 < $n) {
      splice(@vals, @vals, 0, @$v);
    }
    for (my $i=0; $i<$n; $i++) {
      $hashes[$i]->{$k}=$vals[$i];
    }
  }
  return \@hashes;
}


#####################################
# Window related "public" routines. #
#####################################

sub close {
  my $self=shift;
  pgclos() if $self->_status() eq 'OPEN';
  $self->{ID}=undef;
}

=head2 options

Access the options used when I<originally> opening the window. At the moment
this is not updated when the window is changed later.

=cut

sub options {
  my ($name)=@_;
  return $self->{Options};
}

=head2 id

Access the window ID that PGPLOT uses for the present window.

=cut

sub id {
  return $_[0]->{ID};
}

=head2 device

This function returns the device type of the present window.

=cut

sub device {
  return $_[0]->{Device};
}

=head2 name

Accessor to set and examine the name of a window.

=cut

sub name {
  my $self=shift;
  if ($#_>=0) {
    $self->{Name}=$_[0];
  }
  return $self->{Name};
}

=head2 focus

Set focus for subsequent PGPLOT commands to this window.

=cut

sub focus {

  my $self=shift;
  return if !defined($self->{ID});
  my $sid; pgqid($sid);
  # Only perform a pgslct if necessary.
  pgslct($self->{ID}) unless $sid == $self->{ID};

}


sub hold {
  my $self=shift;
  $self->{Hold}=1;
  return $self->{Hold};
}


sub release {
  my $self=shift;
  $self->{Hold}=0;
  return $self->{Hold};
}


sub held {
  my $self = shift;
  return $self->{Hold};
}




=head2 info

=for ref

Get general information about the PGPLOT environment.

=for usage

 @ans = $self->info( @item );

The valid values of C<@item> are as below, where case is not
important:

  VERSION     - What PGPLOT version is in use
  STATE       - The status of the output device, this is returns 'OPEN'
                if the device is open and 'CLOSED' otherwise.
  USER        - The username of the owner of the spawning program.
  NOW         - The current date and time in the format 'dd-MMM-yyyy hh:mm'.
                Most people are likely to use Perl functions for this.
  DEVICE    * - The current PGPLOT device or file, see also C<device>
  FILE      * - The filename for the current device
  TYPE      * - And the device type for the current device
  DEV/TYPE  * - This combines DEVICE and TYPE in a form that can be used
                as input to C<new>.
  HARDCOPY  * - This is flag which is set to 'YES' if the current device is
                a hardcopy device and 'NO' otherwise.
  TERMINAL  * - This flag is set to 'YES' if the current device is the user's
                terminal and 'NO' otherwise.
  CURSOR    * - A flag ('YES' or 'NO') to inform whether the current device
                has a cursor.

Those items marced with a C<*> only return a valid answer if
the window is open.  A question mark (C<?>) is returned
if the item is not recognised or the information is not available.

=cut

#'

sub info {
    my $self = shift;
    my @inq;
    if ( wantarray() ) { @inq = @_; }
    else               { push @ing, $_[0]; }

    $self->focus();
    my @ans;
    foreach my $inq ( @inq ) {
	my ( $state, $len );
	pgqinf( uc($inq), $state, $len );
	push @ans, $state;
    }
    return wantarray() ? @ans : $ans[0];
} # info()






sub panel {

  my $self = shift;

  $self->focus();
  my ($xpos, $ypos);
  if ($#_ == 1) {
    # We have gotten $x and $y..
    ($xpos, $ypos)=@_;
  } elsif ($#_ == 0 && ref($_[0]) eq 'ARRAY' ) {
    ($xpos, $ypos)=@{$_[0]};
  } elsif ($#_ == 0) {
    # We have been given a single number... This can be converted
    # to a X&Y position with a bit of calculation. The code is taken
    # from one2nd.
    my $i=$_[0]-1;		# The code is 0 offset..
    $xpos = $i % $self->{NX};
    $i = long($i/$self->{NX});
    $ypos=$i % $self->{NY};
    $xpos++; $ypos++;		# Because PGPLOT starts at 1..
  } else {
    barf <<'EOD'
 Usage: panel($xpos, $ypos);   or
        panel([$xpos, $ypos]); or
        panel($index);
EOD
  }

  # We do not subtract 1 from X because we would need to add it again to
  # have a 1-offset numbering scheme.
  $self->{CurrentPanel} = ($ypos-1)*$self->{NX}+($xpos);
  pgpanl($xpos, $ypos);


}


{
  # To save space and time..
  my $erase_options = undef;
  sub erase {
    my $self = shift;

    # Parse options
    my $u_opt = shift;
    if (defined($u_opt) && ref($u_opt) eq 'HASH') {
      $erase_options = PDL::Options->new({Panel => undef}) if
	!defined($erase_options);
      my $o = $erase_options->options($u_opt);
      # Change panel if requested
      $self->panel($o->{Panel}) if defined($o->{Panel});
    } elsif (defined($u_opt)) {
      # The user has passed a number of reference to array..
      $self->panel($u_opt);
    }

    $self->focus();
    pgeras();
    # Remove hold.
    $self->{Hold}=0;
  }

}


##
## Utility functions
##

=head2 _extract_hash

This routine takes and array and returns the first hash reference found as
well as those elements that are I<not> hashes. Note the latter point because
all other references to hashes in the array will be lost.

=cut

sub _extract_hash {
  my @opt=@_;
  #
  # Given a list, returns a list of hash references and all the rest.
  #
  my $count=0;
  my $hashes=[];
  foreach (@opt) {
    push @$hashes, splice(@opt, $count, 1) if ref($_) eq 'HASH';
    $count++
  }
  return (\@opt, $$hashes[0]);
}

=head2 _parse_options

This is a convenience routine for parsing a set of options. It returns
both the full set of options and those that the user has set.

=cut

sub _parse_options {

  my $self=shift;
  my ($opt, $oin)=@_;

  ## Should do something sensible if $opt is no options object f.i.
  if (defined($oin) && ref($oin) ne 'HASH') {
    my ($package, $file, $line, $sub)=caller(1);
    barf "_parse_options called by $sub with non-hash options element!";
  } elsif (!defined($oin)) {
    my ($package, $file, $line, $sub)=caller(1);
    warn "_parse_options called by $sub without an options hash! - continuing\n";
    $oin = {};
  }
  my $o=$opt->options($oin);
  $opt->full_options(0);
  my $uo=$opt->current();
  $opt->full_options(1);

  return ($o, $uo);

}


################################################################
#
#    GRAPHICS FUNCTIONS below!
#
################################################################

############ Local functions #################

=head2 _save_status

Saves the PGPLOT state so that changes to settings can be made and then
the present state restored by C<_restore_status>.

=cut

sub _save_status {
  my $self=shift;
  pgsave if $self->_status() eq 'OPEN';
}

=head2 _restore_status

Restore the PGPLOT state. See L<_save_status>.

=cut

sub _restore_status {
  my $self=shift;
  pgunsa if $self->_status() eq 'OPEN';
}



=head2 _checkarg

This routine checks and optionally alters the arguments given to it.

=cut

sub _checkarg {			# Check/alter arguments utility
  my $self = shift;
  my ($arg,$dims,$type) = @_;
  $type = $PDL_F unless defined $type;
  $arg = topdl($arg);		# Make into a pdl
  $arg = convert($arg,$type) if $arg->get_datatype != $type;
  if (($arg->getndims > $dims)) {
    # Get the dimensions, find out which are == 1. If it helps
    # chuck these off and return trimmed piddle.
    my $n=nelem(which(pdl($arg->dims)==1));
    barf "Data is >".$dims."D" if ($arg->getndims-$n) > $dims;
    my $count=0;      my $qq;
    my $s=join ',',
      map {if ($_ == 1 && $count<$arg->getndims-$dims) {$qq='(0)'; $count++}
	   else {
	     $qq= '';
	   }
	   ; $qq} $arg->dims;
    $arg=$arg->slice($s);
  }
  $_[0] = $arg;			# Alter
  1;
}

##################
# Options parser #
##################

=head2 _standard_options_parser

This internal routine is the default routine for parsing options. This
routine deals with a subset of options that most routines will accept.

=cut

sub _standard_options_parser {
  #
  # Parse the options and act on the values set.
  #
  my $self=shift;
  my ($o)=@_;

#  print "Standard options parser: Font set to: $$o{Font}\n";

  #
  # The input hash has to contain the options _set by the user_
  #
  pgsci($o->{Colour})	  if exists($o->{Colour});
  pgsls($o->{LineStyle})  if exists($o->{LineStyle});
  pgslw($o->{LineWidth})  if exists($o->{LineWidth});
  pgscf($o->{Font})	  if exists($o->{Font});
#  print "The character size is $$o{CharSize}\n";
  pgsch($o->{CharSize})	  if exists($o->{CharSize});
  pgsfs($o->{Fill})	  if exists($o->{Fill});
#  pgsch($o->{ArrowSize})  if exists($o->{ArrowSize});
  # Two new options..


  my $wo = $self->{PlotOptions}->defaults(); # Window defaults - for some routines below

  # We just need special treatment of the Arrow and Hatch options,
  # and they are complex for historical reasons...

  if (exists($o->{Arrow})) {
    #
    # Set the arrow. The size can be set either independently
    # using ARROWSIZE or in the hash
    #
    # Note the use of $wo to get the true default values here!
    my ($fs, $angle, $vent)=($wo->{Arrow}{FS}, $wo->{Arrow}{Angle},
			     $wo->{Arrow}{Vent});
    my $arrowsize = $o->{CharSize}; # Default to the character size..
    if (ref($o->{Arrow}) eq 'HASH') {
      while (my ($var, $value)=each %{$o->{Arrow}}) {
	$fs=$value if $var =~ m/^F/i;
	$angle=$value if $var =~ m/^A/i;
	$vent=$value if $var =~ m/^V/i;
	$arrowsize=$value if $var =~ m/^S/i;
      }
    } else {
      $fs=$o->{Arrow}[0] if defined $o->{Arrow}[0];
      $angle=$o->{Arrow}[1] if defined $o->{Arrow}[1];
      $vent=$o->{Arrow}[2] if defined $o->{Arrow}[2];
      $arrowsize=$o->{Arrow}[3] if defined $o->{Arrow}[3];
    }
    pgsch($arrowsize) if defined($arrowsize);
    pgsah($fs, $angle, $vent);
  }

  if (exists($o->{Hatch})) {
    my $val = $o->{Hatch};
    if (!defined($val) || lc($val) eq 'default') {
      pgshs();			# Default values are either specfied by HATCH=>undef or HATCH=>'default'
    } else {
      #
      # Can either be specified as numbers or as a hash...
      #
      # Note the use of $wo to get the true default values!!
      #
      my ($angle, $separation, $phase)=
	($wo->{Hatch}{Angle}, $wo->{Hatch}{Separation}, $wo->{Hatch}{Phase});

      if (ref($val) eq 'HASH') {
	while (my ($var, $value) = each %{$val}) {
	  $angle=$value if $var =~ m/^A/i;
	  $separation=$value if $var =~ m/^S/i;
	  $phase=$value if $var =~ m/^P/i;
	}
      } else {
	$angle=$$val[0] if defined($$val[0]);
	$separation=$$val[1] if defined($$val[1]);
	$phase=$$val[2] if defined($$val[2]);
      }
      if ($separation==0) {
	warn "The separation of hatch lines cannot be zero, the default of".
	  $wo->{Hatch}{Separation} . " is used!\n";
	$separation=$wo->{Hatch}{Separation};
      }
      pgshs($angle,$separation, $phase);
    }
  }
}



# initenv( $xmin, $xmax, $ymin, $ymax, $just, $axis )
# initenv( $xmin, $xmax, $ymin, $ymax, $just )
# initenv( $xmin, $xmax, $ymin, $ymax, \%opt )
#
# \%opt can be supplied but not be defined
# we parse the JUSTIFY, AXIS, and BORDER options here,
# rather than have a multitude of checks below
#


sub initenv{
  my $self = shift;		# Default box

  # We must check the status of the object, and if not ready it must
  # be re-opened...
  $self->_status();

  my ($in, $u_opt)=_extract_hash(@_);
  my ($xmin, $xmax, $ymin, $ymax, $just, $axis)=@$in;


  # Now parse the input options.
  $u_opt={} unless defined($u_opt);
  my $o = $self->{Options}->options($u_opt); # Merge in user options...

  # Save current colour and set the axis colours
  my ($col);
  pgqci($col);
  pgsci($o->{AxisColour});
  # Save current font size and set the axis character size.
  my ($chsz);
  pgqch($chsz);
  pgsch($o->{CharSize});


  # If the user specifies $just or $axis these values will
  # override any options given. This actually changes the behaviour
  # of the previous initenv() function when $just and/or $axis was
  # specified in conjunction with an options hash.
  $o->{Justify} = $just if defined($just);
  $o->{Axis} = $axis if defined($axis);

  if (ref($o->{Border}) eq 'HASH' || $o->{Border} != 0) {
    my $type  = "REL";
    my $delta = 0.05;
    if ( ref($o->{Border}) eq "HASH" ) {
      while (my ($bkey, $bval) = each %{$o->{Border}}) {
	$bkey = uc($bkey);
	if ($bkey =~ m/^TYP/) {
	  $type = uc $bval;
	} elsif ($bkey =~ m/^VAL/) {
	  $delta = $bval;
	}
      }				# while: (bkey,bval)
    }				# if: ref($val) eq "HASH"

    if ( $type =~ m/^REL/ ) {
      my $sep = ( $xmax - $xmin ) * $delta;
      $xmin -= $sep; $xmax += $sep;
      $sep = ( $ymax - $ymin ) * $delta;
      $ymin -= $sep; $ymax += $sep;
    } elsif ( $type =~ m/^ABS/ ) {
      $xmin -= $delta; $xmax += $delta;
      $ymin -= $delta; $ymax += $delta;
    } else {
      print "Warning: unknown BORDER/TYPE option '$type'.\n";
    }
  }

  #
  # This part of the code has changed from the previous PGPLOT
  # installation. The reason is that when we use several panels
  # and want to jump from one to another we cannot use pgenv since
  # that makes an annoying call to pgpage which we want to have
  # control over....
  #

  # A particular difficulty arises with the use of several panels.
  # It is here hopeless to do a pgpage since that will jump to the
  # next panel and that was exactly the reason why I have scrapped
  # pgenv.
  #
  # To give a consistent system and to tidy up we will call
  # erase if there are several panels, and pgpage otherwise.
  if (!defined($o->{NoErase}) || $o->{NoErase} == 0) {
    if ($self->{NX}*$self->{NY} > 1) {
      pgeras();
    } else {
      pgpage();
    }
  }

  if (!defined($o->{PlotPosition}) || $o->{PlotPosition} eq 'Default') {
    # Set standard viewport
    pgvstd();
  } else {
    barf "The PlotPosition must be given as an array reference!" unless
      ref($o->{PlotPosition}) eq 'ARRAY';
    my ($x1, $x2, $y1, $y2)=@{$o->{PlotPosition}};
    pgsvp ($x1, $x2, $y1, $y2);
  }

  # This behaviour is taken from the PGPLOT manual.
  if ($o->{Justify} == 1) {
    pgwnad($xmin, $xmax, $ymin, $ymax);
  } else {
    pgswin($xmin, $xmax, $ymin, $ymax);
    if (ref($o->{Axis}) eq 'ARRAY') {
      pgbox($o->{Axis}[0], 0.0, 0, $o->{Axis}[1], 0.0, 0);
    } else {
      pgbox($o->{Axis}, 0.0, 0, $o->{Axis}, 0.0, 0);
    }
  }
  $self->label_axes($u_opt);

  #  pgenv($xmin, $xmax, $ymin, $ymax, $o->{Justify}, $o->{Axis});
  pgsci($col);
  pgsch($chsz);
  $self->{_env_options} = [$xmin, $xmax, $ymin, $ymax, $o];
#  $self->{_env_set}[$self->{CurrentPanel}]=1;
  1;
}

sub redraw_axes {
  my $self = shift;
  my $col;
  pgqci($col);
  my $o;
  if (defined($self->{_env_options})) {
    # Use the previous settings for the plot box.
    my $e = $self->{_env_options};
    $o=$$e[4];
  } else {
    $o=$self->{Options}->defaults();
  }
  pgsci($o->{AxisColour});
  my ($chsz);
  pgqch($chsz);
  pgsch($o->{CharSize});
  my $axval = $o->{Axis};	# Using the last for this window...
  $axval = 0 unless defined $axval; # safety check
  unless ( $self->{Hold} ) {
    if ( ref($axval) ) {
      pgbox($$axval[0],0,0,$$axval[1],0,0);
    } else {
      pgbox($axval,0,0,$axval,0,0);
    }
  }
  pgsci($col);
  pgsch($chsz);
}


sub label_axes {

  my $self = shift;
  my ($in, $u_opt)=_extract_hash(@_);

  barf 'Usage: label_axes( [$xtitle, $ytitle, $title], [$opt])' if $#$in > 2;

  my ($xtitle, $ytitle, $title)=@$in;

  $u_opt = {} if !defined($u_opt); # For safety.

  # Now the titles are set per plot so we use the general options to
  # parse the options (if they were set per window we would use
  # $self->{Options}
  my $o = $self->{PlotOptions}->options($u_opt);

  $self->_save_status();
  $self->_standard_options_parser($o);
  $o->{Title}=$title if defined($title);
  $o->{XTitle}=$xtitle if defined($xtitle);
  $o->{YTitle}=$ytitle if defined($ytitle);
  pglab($o->{XTitle}, $o->{YTitle}, $o->{Title});
  $self->_restore_status;
}



############ Exported functions #################

# Open/reopen the graphics device

################ Supports two new options::
## NewWindow and WindowName


sub CtoF77coords{		# convert a transform array from zero-offset to unit-offset images
  my $self = shift;
  my $tr = pdl(shift);		# Copy
  set($tr, 0, at($tr,0)-at($tr,1)-at($tr,2));
  set($tr, 3, at($tr,3)-at($tr,4)-at($tr,5));
  return $tr;
}



# set the envelope for plots and put auto-axes on hold


sub env {
  my $self=shift;

  # The following is necessary to advance the panel if wanted...
  my ($in, $opt)=_extract_hash(@_);
  $opt = {} if !defined($opt);
  my $o = $self->{PlotOptions}->options($opt);
  $self->_check_move_or_erase($o->{Panel}, $o->{Erase});

  barf 'Usage: env ( $xmin, $xmax, $ymin, $ymax, [$just, $axis, $opt] )'
    if ($#_==-1 && !defined($self->{_env_options})) || 
      ($#_>=0 && $#_<=2) || $#_>6;
  my(@args);
  @args = $#_==-1 ? @{$self->{_env_options}} : @_;     # No args - use previous
  $self->initenv( @args );
  $self->hold();
  1;
}
# Plot a histogram with pgbin()

{
  my $bin_options = undef;


  sub bin {
    my $self = shift;
    if (!defined($bin_options)) {
      $bin_options = $self->{PlotOptions}->extend({Centre => 1});
      $bin_options->add_synonym({Center => 'Centre'});
    }
    my ($in, $opt)=_extract_hash(@_);
    barf 'Usage: bin ( [$x,] $data, [$options] )' if $#$in<0 || $#$in>2;
    my ($x, $data)=@$in;

    $self->_checkarg($x,1);

    my $n = nelem($x);
    if ($#$in==1) {
      $self->_checkarg($data,1); barf '$x and $y must be same size' if $n!=nelem($data);
    } else {
      $data = $x; $x = float(sequence($n));
    }

    # Parse options
    $opt={} unless defined($opt);
    my $o = $bin_options->options($opt);

    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});
    unless ( $self->held() ) {
      my ($xmin, $xmax)=minmax($x); my ($ymin, $ymax)=minmax($data);
      $self->initenv( $xmin, $xmax, $ymin, $ymax, $opt );
    }
    $self->_save_status();

    my $centre = $o->{Centre};

    # For the standard parser we only want the options that the user set!
    # $bin_options->full_options(0);
    # my $u_opt = $bin_options->current();
    # $bin_options->full_options(1);

    # Let's also parse the options if any.
    $self->_standard_options_parser($o);
    pgbin($n, $x->get_dataref, $data->get_dataref, $centre);
    $self->_restore_status();
    1;
  }
}




{
    my $transform_options = undef;

    sub transform {
	# Compute the transform array needed in contour and image plotting
	my $self = shift;
	my ($xpix, $ypix)=@_;
	if (!defined($transform_options)) {
	  $transform_options = 
	    $self->{PlotOptions}->extend({Angle => undef,
					  ImageDims => undef,
					  Pixinc => undef,
					  ImageCenter => undef});
	  $transform_options->synonyms({ImageDimensions => 'ImageDims',
					ImageCentre => 'ImageCenter'});
	}

	my ($in, $opt)=_extract_hash(@_);
	$opt = {} if !defined($opt);
	my ($o, $u_opt) = $self->_parse_options($transform_options, $opt);
	$self->_standard_options_parser($o);

	my ($angle, $x_pixinc, $y_pixinc, $x_cen, $y_cen);
	if (defined($o->{Angle})) {
	    $angle = $o->{Angle};
	}
	else {
	    $angle = 0;
	}

	if (defined($o->{Pixinc})) {
	    if (ref($o->{Pixinc}) eq 'ARRAY') {
		($x_pixinc, $y_pixinc) = @{$o->{Pixinc}};
	    }
	    else {
		$x_pixinc = $y_pixinc = $o->{Pixinc};
	    }
	}
	else {
	    $x_pixinc = $y_pixinc = 1;
	}

	if (defined $o->{ImageDims} && ref($o->{ImageDims}) eq 'ARRAY') {
	    ($x_pix, $y_pix) = @{$o->{ImageDims}};
	}
	else {
	    barf "Image dimensions must be given as an array reference!";
	}
	
	# The user has to pass the dimensions of the image somehow, so this
	# is a good point to check whether he/she/it has done so.
	unless (defined($x_pix) && defined($y_pix)) {
	  barf "You must pass the image dimensions to the transform routine\n";
	}

	if (defined $o->{ImageCenter}) {
	    if (ref($o->{ImageCenter}) eq 'ARRAY') {
	        ($x_cen, $y_cen) = @{$o->{ImageCenter}};
	    }
	    else {
		$x_cen = $y_cen = $o->{ImageCenter};
	    }
	}
	else {
	    $x_cen = $y_cen = 0;
	}
	$tr = pdl(-($x_pix - 1)/2*$x_pixinc*cos($angle) -
		  ($y_pix - 1)/2*$y_pixinc*sin($angle) + $x_cen,
		  $x_pixinc*cos($angle),
		  $y_pixinc*sin($angle),
		  ($x_pix - 1)/2*$x_pixinc*sin($angle) -
		  ($y_pix - 1)/2*$y_pixinc*cos($angle) + $y_cen,
		  -$x_pixinc*sin($angle),
		  $y_pixinc*cos($angle))
    }
}



# display a contour map of an image using pgconb()


{

  my $cont_options = undef;


  sub cont {
    my $self=shift;
    if (!defined($cont_options)) {
      $cont_options = $self->{PlotOptions}->extend({Contours => undef,
						    Follow => 0,
						    Labels => undef,
						    LabelColour => undef,
						    Missing => undef,
						    NContours => undef,
						    FillContours => undef});
      my $t = {
	       LabelColour => {
			       'White' => 0, 'Black' => 1, 'Red' => 2,
			       'Green' => 3, 'Blue' => 4, 'Cyan' => 5,
			       'Magenta' => 6, 'Yellow' => 7, 'Orange' => 8,
			       'DarkGray' => 14, 'DarkGrey' => 14,
			       'LightGray' => 15, 'LightGrey' => 15
			      }
	      };
      $cont_options->add_translation($t);
    }

    my ($in, $opt)=_extract_hash(@_);
    barf 'Usage: cont ( $image, %options )' if $#$in<0;

    # Parse input
    my ($image, $contours, $tr, $misval) = @$in;
    $self->_checkarg($image,2);
    my($nx,$ny) = $image->dims;
    my ($ncont)=9;		# The number of contours by default

    # First save the present status
    $self->_save_status();


    # Then parse the common options
    #
    # These will be all options.
    $opt = {} if !defined($opt);
    my ($o, $u_opt) = $self->_parse_options($cont_options, $opt);
    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});


    $self->_standard_options_parser($o);
    my ($labelcolour);
    pgqci($labelcolour);	# Default let the labels have the chosen colour.


    my ($labels, $fillcontours, $angle);
    my $usepgcont = 0;

    $contours = $o->{Contours} if defined($o->{Contours});
    $ncont = $o->{NContours} if defined($o->{NContours});
    $misval = $o->{Missing} if defined($o->{Missing});
    $tr = $o->{Transform} if defined($o->{Transform});
    $labelcolour = $o->{LabelColour} if defined($o->{LabelColour});
    $labels = $o->{Labels} if defined($o->{Labels});
    $usepgcont = $o->{Follow} if defined($o->{Follow});
    $fillcontours = $o->{FillContours} if defined($o->{FillContours});

    if (defined($tr)) {
      $self->_checkarg($tr,1);
      barf '$transform incorrect' if nelem($tr)!=6;
    } else {
      $tr = float [0,1,0, 0,0,1];
    }

    $tr = $self->CtoF77coords($tr);

    if (!$self->held()) {
	# Scale the image correctly even with rotation by calculating the new 
	# corner points
	$self->initenv(($tr->slice("0:2")*pdl[
					      [1, 0, 0],
					      [1, 0, $nx],
					      [1, $nx, 0],
					      [1, $nx, $nx]])->sumover->minmax,
		       ($tr->slice("3:5")*pdl[
					      [1, 0, 0],
					      [1, 0, $ny],
					      [1, $ny, 0],
					      [1, $ny, $ny]])->sumover->minmax,
		       $opt);
    }

    if (!defined($contours)) {
      my($minim, $maxim)=minmax($image);
      $contours = xlinvals(zeroes($ncont), $minim, $maxim)
    }
    else {
	$ncont = nelem($contours);
    }

    $self->_checkarg($contours,1);

    print "Contouring $nx x $ny image from ",min($contours), " to ",
      max($contours), " in ",nelem($contours)," steps\n" if $PDL::verbose;

    if (defined($fillcontours)) {
      pgbbuf();
      if (ref $fillcontours ne PDL) {
	$fillcontours = zeroes($ncont - 1)->xlinvals(0,1)->dummy(0,3);
      } elsif ($fillcontours->getndims == 1) {
	$fillcontours = $fillcontours->dummy(0,3);
      } elsif (($fillcontours->getdim(1) != $ncont - 1) ||
	       ($fillcontours->getdim(0) != 3)) {
	barf "Argh, wrong dims in filled contours!";
      }
      my ($cr, $cg, $cb, $i);
      pgqcr(16, $cr, $cg, $cb); # Save color index 16
      # Loop over filled contours (perhaps should be done in PP for speed)
      # Do not shade negative and 0-levels
      for ($i = 0; $i < ($ncont - 1); $i++) {
	pgscr(16, list $fillcontours->slice(":,$i"));
	pgsci(16);
	pgconf($image->get_dataref, $nx, $ny,
               1, $nx, 1, $ny,
	       list($contours->slice($i.':'.($i + 1))), $tr->get_dataref);
      }
      pgscr(16, $cr, $cg, $cb); # Restore color index 16
      pgebuf();
    } elsif (defined($misval)) {
      pgconb( $image->get_dataref, $nx,$ny,1,$nx,1,$ny,
	      $contours->get_dataref,
	      nelem($contours), $tr->get_dataref, $misval);
    } elsif (abs($usepgcont) == 1) {
      pgcont( $image->get_dataref, $nx,$ny,1,$nx,1,$ny,
	      $contours->get_dataref,
	      $usepgcont*nelem($contours), $tr->get_dataref);
    } else {
      pgcons( $image->get_dataref, $nx,$ny,1,$nx,1,$ny,
	      $contours->get_dataref, nelem($contours), $tr->get_dataref);
    }

    # Finally label the contours.
    if (defined($labels) && $#$labels+1==nelem($contours)) {

      my $label=undef;
      my $count=0;
      my $minint=long($nx/10)+1; # At least stretch a tenth of the array
      my $intval=long($nx/3)+1;	#

      my $dum;
      pgqci($dum);
      pgsci($labelcolour);
      foreach $label (@{$labels}) {
	pgconl( $image->get_dataref, $nx,$ny,1,$nx,1,$ny,
		$contours->slice("($count)"),
		$tr->get_dataref, $label, $intval, $minint);
	$count++;
      }
      pgsci($dum);
    } elsif (defined($labels)) {
      #
      #  We must have had the wrong number of labels
      #
      warn <<EOD
   You must specify the same number of labels as contours.
   Labelling has been ignored.
EOD

    }

    # Restore attributes
      $self->redraw_axes unless $self->held(); # Redraw box
      $self->_restore_status();
    1;
  }
}

# Plot errors with pgerrb()

{

  my $errb_options = undef;

  sub errb {
    my $self = shift;
    if (!defined($errb_options)) {
      $errb_options = $self->{PlotOptions}->extend({Term => 1});
      $errb_options->add_synonym({Terminator => 'Term'});
    }
    my ($in, $opt)=_extract_hash(@_);
    $opt = {} if !defined($opt);
    barf <<'EOD' if $#$in<1 || $#$in==4 || $#$in>5;
 Usage: errb ( $y, $yerrors [, $options] )
	errb ( $x, $y, $yerrors [, $options] )
	errb ( $x, $y, $xerrors, $yerrors [, $options])
	errb ( $x, $y, $xloerr, $xhierr, $yloerr, $yhierr [, $options])
EOD

    my @t=@$in;
    my $i=0; my $n;
    for (@t) {
      $self->_checkarg($_, 1);
      $n = nelem($_) if $i++ == 0;
      barf "Args must have same size" if nelem($_)!=$n;
    }
    my $x = $#t==1 ? float(sequence($n)) : $t[0];
    my $y = $#t==1 ? $t[0] : $t[1];

    my ($o, $u_opt) = $self->_parse_options($errb_options, $opt);
    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});
    unless( $self->held() ) {
      # Allow for the error bars
      my ( $xmin, $xmax, $ymin, $ymax );

      if ($#t==1) {
	($xmin,$xmax) = $x->minmax($x);
	$ymin = min( $y - $t[1] ); $ymax = max( $y + $t[1] );
      } elsif ($#t==2) {
	($xmin, $xmax ) = $x->minmax($x);
	$ymin = min( $y - $t[2] ); $ymax = max( $y + $t[2] );
      } elsif ($#t==3) {
	$xmin = min( $x - $t[2] ); $xmax = max( $x + $t[2] );
	$ymin = min( $y - $t[3] ); $ymax = max( $y + $t[3] );
      } elsif ($#t==5) {
	$xmin = min( $x - $t[2] ); $xmax = max( $x + $t[3] );
	$ymin = min( $y - $t[4] ); $ymax = max( $y + $t[5] );
      }
      $self->initenv( $xmin, $xmax, $ymin, $ymax, $opt );
    }
    $self->_save_status();
    # Let us parse the options if any.

    my $term=$o->{Term};
    my $symbol;
    my $plot_points=0;		# We won't normally plot the points

    if (defined($u_opt->{Symbol})) {
      $symbol = $u_opt->{Symbol};
      $plot_points=1;
    }

    # Parse other standard options.
    $self->_standard_options_parser($o);
    if ($#t==1) {
      pgerrb(6,$n,$x->get_dataref,$y->get_dataref,$t[1]->get_dataref,$term);
    } elsif ($#t==2) {
      pgerrb(6,$n,$x->get_dataref,$y->get_dataref,$t[2]->get_dataref,$term);
    } elsif ($#t==3) {
      pgerrb(5,$n,$x->get_dataref,$y->get_dataref,$t[2]->get_dataref,$term);
      pgerrb(6,$n,$x->get_dataref,$y->get_dataref,$t[3]->get_dataref,$term);
    } elsif ($#t==5) {
      pgerrb(1,$n,$x->get_dataref,$y->get_dataref,$t[3]->get_dataref,$term);
      pgerrb(2,$n,$x->get_dataref,$y->get_dataref,$t[5]->get_dataref,$term);
      pgerrb(3,$n,$x->get_dataref,$y->get_dataref,$t[2]->get_dataref,$term);
      pgerrb(4,$n,$x->get_dataref,$y->get_dataref,$t[4]->get_dataref,$term);
    }
    if ($plot_points) {
      $symbol=long($symbol);
      my $ns=nelem($symbol);
      pgpnts($n, $x->get_dataref, $y->get_dataref, $symbol->get_dataref, $ns)
    }

    $self->_restore_status();
    1;
  }
}

#
# A "threaded" line - I cannot come up with a more elegant way of doing
# this without re-coding bits of thread_over but it might very well be
# that you may :)
#

sub tline {

  my $self = shift;
  my ($in, $opt)=_extract_hash(@_);
  $opt={} if !defined($opt);

  barf 'Usage tline ([$x], $y, [, $options])' if $#$in < 0 || $#$in > 2;
  my ($x, $y)=@$in;


  if ($#$in==0) {
    $y = $x; $x = $y->xvals();
  }

  # This is very very cludgy, but it was the best way I could find..
  my $o = _thread_options($y->getdim(1), $opt);
  # We need to keep track of the current status of hold or not since
  # the tline function automatically enforces a hold to allow for overplots.
  my $tmp_hold = $self->held();
  _tline($x, $y, $x->yvals, $self, $o);
  $self->release unless $tmp_hold;

}


PDL::thread_define('_tline(a(n);b(n);ind(n)), NOtherPars => 2',
  PDL::over {
    my ($x, $y, $ind, $self, $opt)=@_;
    $self->line($x, $y, $opt->[$ind->at(0)]);
    $self->hold();
});


#
# A "threaded" point - I cannot come up with a more elegant way of doing
# this without re-coding bits of thread_over but it might very well be
# that you may :)
#

sub tpoints {

  my $self = shift;
  my ($in, $opt)=_extract_hash(@_);
  $opt={} if !defined($opt);

  barf 'Usage tpoints ([$x], $y, [, $options])' if $#$in < 0 || $#$in > 2;
  my ($x, $y)=@$in;


  if ($#$in==0) {
    $y = $x; $x = $y->xvals();
  }

  # This is very very cludgy, but it was the best way I could find..
  my $o = _thread_options($y->getdim(1), $opt);
  # We need to keep track of the current status of hold or not since
  # the tline function automatically enforces a hold to allow for overplots.
  my $tmp_hold = $self->held();
  _tpoints($x, $y, $x->yvals, $self, $o);
  $self->release unless $tmp_hold;

}


PDL::thread_define('_tpoints(a(n);b(n);ind(n)), NOtherPars => 2',
  PDL::over {
    my ($x, $y, $ind, $self, $opt)=@_;
    $self->points($x, $y, $opt->[$ind->at(0)]);
    $self->hold();
});



# Plot a line with pgline()

{
  my $line_options = undef;


  sub line {
    my $self = shift;
    if (!defined($line_options)) {
      $line_options=$self->{PlotOptions}->extend({Missing => undef});
    }
    my ($in, $opt)=_extract_hash(@_);
    $opt = {} if !defined($opt);

    barf 'Usage: line ( [$x,] $y, [$options] )' if $#$in<0 || $#$in>2;
    my($x,$y) = @$in;
    $self->_checkarg($x,1);
    my $n = nelem($x);

    if ($#$in==1) {
      $self->_checkarg($y,1); barf '$x and $y must be same size' if $n!=nelem($y);
    } else {
      $y = $x; $x = float(sequence($n));
    }

    # Let us parse the options if any.
    my ($o, $u_opt) = $self->_parse_options($line_options, $opt);
    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});

    unless ( $self->held() ) {

      # Make sure the missing value is used as the min or max value
      my ($ymin, $ymax, $xmin, $xmax);
      if (defined $o->{Missing} ) {
	($ymin, $ymax)=minmax($y->where($y != $o->{Missing}));
	($xmin, $xmax)=minmax($x->where($x != $o->{Missing}));
      } else {
	($ymin, $ymax)=minmax($y);
	($xmin, $xmax)=minmax($x);
      }

      $self->initenv( $xmin, $xmax, $ymin, $ymax, $opt);
    }
    $self->_save_status();
    $self->_standard_options_parser($o);

    # If there is a missing value specified, use pggapline
    # to break the line around missing values.
    if (defined $o->{Missing}) {
      pggapline ($n, $o->{Missing}, $x->get_dataref, $y->get_dataref);
    } else {
      pgline($n, $x->get_dataref, $y->get_dataref);
    }
    $self->_restore_status();
    1;
  }
}
# Plot points with pgpnts()



sub arrow {

  my $self = shift;

  my ($in, $opt)=_extract_hash(@_);
  $opt = {} if !defined($opt);

  barf 'Usage: arrow($x1, $y1, $x2, $y2 [, $options])' if $#$in != 3;

  my ($x1, $y1, $x2, $y2)=@$in;

  my $o = $self->{PlotOptions}->options($opt);
  $self->_check_move_or_erase($o->{Panel}, $o->{Erase});
  unless ($self->held()) {
    $self->initenv($x1, $x2, $y1, $y2, $opt);
  }

  $self->_save_status();
  $self->_standard_options_parser($o);
  pgarro($x1, $y1, $x2, $y2);
  $self->_restore_status();

}



{
  my $points_options = undef;

  sub points {

    my $self = shift;
    if (!defined($points_options)) {
      $points_options = $self->{PlotOptions}->extend({PlotLine => 0});
    }
    my ($in, $opt)=_extract_hash(@_);
    $opt = {} if !defined($opt);
    barf 'Usage: points ( [$x,] $y, $sym, [$options] )' if $#$in<0 || $#$in>2;
    my ($x, $y, $sym)=@$in;
    $self->_checkarg($x,1);
    my $n=nelem($x);

    if ($#$in>=1) {
      $self->_checkarg($y,1); barf '$x and $y must be same size' if $n!=nelem($y);
    } else {
      $y = $x; $x = float(sequence($n));
    }

    # Let us parse the options if any.
    my ($o, $u_opt) = $self->_parse_options($points_options, $opt);
    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});

    #
    # Save some time for large datasets.
    #
    unless ( $self->held() ) {
      my ($xmin, $xmax)=minmax($x); my ($ymin, $ymax)=minmax($y);
      $self->initenv( $xmin, $xmax, $ymin, $ymax, $opt );
    }
    $self->_save_status();
    $self->_standard_options_parser($o);


    # Set symbol if specified in the options hash.
    ## $sym ||= $o->{Symbol};
    $sym = $o->{Symbol} unless defined $sym;

    $self->_checkarg($sym,1); my $ns = nelem($sym); $sym = long($sym);

    pgpnts($n, $x->get_dataref, $y->get_dataref, $sym->get_dataref, $ns);

    #
    # Sometimes you would like to plot a line through the points straight
    # away.
    pgline($n, $x->get_dataref, $y->get_dataref) if $o->{PlotLine}>0;

    $self->_restore_status();
    1;
  }
}

# display an image using pgimag()/pggray() as appropriate


{
  # The ITF is in the general options - since other functions might want
  # it too.
  #
  # There is some repetetiveness in the code, but this is to allow the
  # user to set global defaults when opening a new window.
  #

  my $im_options = undef;


  sub imag1 {
    my $self = shift;
    my ($in,$opt)=_extract_hash(@_);

    if (!defined($im_options)) {
      $im_options = $self->{PlotOptions}->extend({
						  PIX => undef,
						  Min => undef,
						  Max => undef,
						  Scale => undef,
						  Pitch => undef,
						  Unit => undef
						 });
    }

    # Let us parse the options if any.
    $opt = {} if !defined($opt);
    my ($o, $u_opt) = $self->_parse_options($im_options, $opt);

    barf 'Usage: im ( $image, [$min, $max, $transform] )' if $#$in<0 || $#$in>3;
    $u_opt->{'PIX'}=1 unless defined $u_opt->{'PIX'};
    # Note that passing $u_opt is ok here since the two routines accept the
    # same options!
    $self->imag (@$in,$u_opt);
  }

  sub imag {

    my $self = shift;
    if (!defined($im_options)) {
      $im_options = $self->{PlotOptions}->extend({
						  PIX => undef,
						  Min => undef,
						  Max => undef,
						  Scale => undef,
						  Pitch => undef,
						  Unit => undef
						 });
    }

    my ($in, $opt)=_extract_hash(@_);
    # Let us parse the options if any.
    $opt = {} if !defined($opt);
    my ($o, $u_opt) = $self->_parse_options($im_options, $opt);


    barf 'Usage: imag ( $image,  [$min, $max, $transform] )' if $#$in<0 || $#$in>3;
    my ($image,$min,$max,$tr) = @$in;
    $self->_checkarg($image,2);
    my($nx,$ny) = $image->dims;

    my($pix,$pitch,$unit,$scale);
    my $itf = 0;


    $tr = $u_opt->{Transform} if exists($u_opt->{Transform});
    $min = $u_opt->{Min} if exists($u_opt->{Min});
    $max = $u_opt->{Max} if exists($u_opt->{Max});
    $itf = $u_opt->{ITF} if exists($u_opt->{ITF});

    # Check on ITF value hardcoded in.
    barf ( "illegal ITF value `$val'") if $itf > 2 || $itf < 0;

    $min = min($image) unless defined $min;
    $max = max($image) unless defined $max;

    if (defined($tr)) {
      $self->_checkarg($tr,1);
      barf '$transform incorrect' if nelem($tr)!=6;
    } else {
      $tr = float [0,1,0, 0,0,1];
    }
    $tr = $self->CtoF77coords($tr);

    ##############################
    # Set up coordinate transformation in the output window.

    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});
    if (!$self->held()) {
      #########
      # Parse out scaling options - this is pretty long because
      # the defaults for each value change based on the others.
      # (e.g. specifying "SCALE" and no unit gives pixels; but
      # specifying "PITCH" and no unit gives dpi).
      #
      local $_;
      my ($pix,$pitch,$unit);

      if ($u_opt->{'Scale'}) {
	($pix,$pitch,$unit)=(1,1.0/$u_opt->{'Scale'},3);
      }
      if ($u_opt->{'Pitch'}) {
	($pix,$pitch,$unit) = (1,$u_opt->{'Pitch'},1);
      }
      if (defined ($_ = $u_opt->{'Unit'})) {
	undef $unit;
	if (m/^d/ && $_ <= 4) {	# Numeric data type spec
	  $unit = $_;
	} else { 
	  my @c = ('n','i','m','p');
	  my ($i, $c);
	  for ($i=0;defined($c=shift(@c));$i++) {
	    m/^$c/ || next;
	    $unit=$i; 
	    last;
	  }
	}
	barf ('If you specify UNIT, it has to be one of (normal,inches,millimeters,pixels)!') unless defined($unit);
      }

      $pix = $u_opt->{'PIX'} if defined $u_opt->{'PIX'};

      ##############################
      ## Do the initial scaling setup.  If $pix is defined, then
      ## handle the scaling locally, else use initenv.
      ## [ The PIX, SCALE, and UNIT options could in principle be fed to
      ## initenv instead of doing it here... ]

      if (defined $pix) {
	my ( $x0,$x1,$y0,$y1 );

	if (!defined($pitch)) {
	  ## Set scaling parameters automagically.

	  pgqvsz(1,$x0,$x1,$y0,$y1);
	  print "x0=$x0, x1=$x1, y0=$y0, y1=$y1\n" if $PDL::verbose;
	  ($unit,$pitch) = (1, max(pdl( $pix * $nx / ($x1-$x0)  , 
					$ny / ($y1-$y0)   )));
	  print "imag: defined pitch & unit automagically\n" if $PDL::verbose;
	}

	print "imag: unit='$unit', pitch='$pitch'\n" if $PDL::verbose;


	my($col); pgqci($col);
	my $wo = $self->{Options}->options($opt);
	print "Axis colour set to $$wo{AxisColour}\n";
	if ($self->{NX}*$self->{NY} > 1) {
	  pgeras();
	} else {
	  pgpage();
	}
	pgsci($wo->{AxisColour});
	pgvstd;			## Change this to use the margins for display!

	## Set the window to the correct number of pixels for the
	## viewport size and the specified $pitch.
	pgqvsz($unit,$x0,$x1,$y0,$y1);
	pgswin(0,($x1-$x0)*$pitch/$pix,0,($y1-$y0)*$pitch);

	$self->{_env_options} = [0, ($x1-$x0)*$pitch/$pix, 0, 
				 ($y1-$y0)*$pitch, 
				 $self->{Options}->options($opt)];
#	$self->{_env_set}[$self->{CurrentPanel}]=1;
	pgsci($col);
      } else {
	# Scale the image correctly even with rotation by calculating the new
	# corner points
	$self->initenv(($tr->slice("0:2")*pdl[
					      [1, 0, 0],
					      [1, 0, $nx],
					      [1, $nx, 0],
					      [1, $nx, $nx]])->sumover->minmax,
		       ($tr->slice("3:5")*pdl[
					      [1, 0, 0],
					      [1, 0, $ny],
					      [1, $ny, 0],
					      [1, $ny, $ny]])->sumover->minmax,
		       $opt);
      }
    }				# if ! hold

    print "Displaying $nx x $ny image from $min to $max ...\n" if $PDL::verbose;

    pgsitf( $itf );
    my ($i1, $i2);
    pgqcir($i1, $i2);		# Colour range - if too small use pggray dither algorithm
    if ($i2-$i1<16 || $self->{Device} =~ /^v?ps$/i) {
      pggray( $image->get_dataref, $nx,$ny,1,$nx,1,$ny, $min, $max, $tr->get_dataref);
    } else {
      $self->ctab('Grey') unless $self->_ctab_set(); # Start with grey
      pgimag( $image->get_dataref, $nx,$ny,1,$nx,1,$ny, $min, $max, $tr->get_dataref);
    }
    $self->redraw_axes unless $self->held(); # Redraw box
    1;
  }

}

# Load a colour table using pgctab()

{
  # This routine doesn't really have any options at the moment, but
  # it uses the following standard variables
  my %CTAB = ();
  $CTAB{Grey}    = [ pdl([0,1],[0,1],[0,1],[0,1]) ];
  $CTAB{Igrey}   = [ pdl([0,1],[1,0],[1,0],[1,0]) ];
  $CTAB{Fire}    = [ pdl([0,0.33,0.66,1],[0,1,1,1],[0,0,1,1],[0,0,0,1]) ];
  $CTAB{Gray}    = $CTAB{Grey};	# Alias
  $CTAB{Igray}   = $CTAB{Igrey}; # Alias
  my $CTAB        = undef;	# last CTAB used

  # It would be easy to add options though..

  sub _ctab_set {
    return defined($CTAB);
  }

  sub ctab {
    my $self = shift;
    my ($in, $opt)=_extract_hash(@_);

    # No arguments -- print list of tables
    if (scalar(@$in) == 0) {
      print "Available 'standard' color tables are:\n",join(",",sort keys %CTAB)
	,"\n";
      return;
    }
    # No arguments -- print list of tables
    if (scalar(@$in) == 0) {
      print "Available 'standard' color tables are:\n",join(",",sort keys %CTAB)
	,"\n";
      return;
    }

    # First indirect arg list through %CTAB
    my(@arg) = @$in;

    my($ctab, $levels, $red, $green, $blue, $contrast, $brightness, @t, $n);

    if ($#arg>=0 && !ref($arg[0])) {       # First arg is a name not an object
      # if first arg is undef or empty string, means use last CTAB.
      # preload with Grey if no prior CTAB
      $arg[0] = 'Grey' unless $arg[0] || $CTAB;

      # now check if we're using the last one specified
      if ( ! $arg[0] ) {
	shift @arg;
	unshift @arg, @{$CTAB->{ctab}};
	$brightness = $CTAB->{brightness};
	$contrast = $CTAB->{contrast};
      } else {
	my $name = ucfirst(lc(shift @arg)); # My convention is $CTAB{Grey} etc...
	barf "$name is not a standard colour table" unless defined $CTAB{$name};
	unshift @arg, @{$CTAB{$name}};
      }
    }


    if ($#arg<0 || $#arg>5) {
      my @std = keys %CTAB;
      barf <<"EOD";
 Usage: ctab ( \$name, [\$contrast, $\brightness] ) # Builtin col table
	     [Builtins: @std]
	ctab ( \$ctab, [\$contrast, \$brightness] ) # $ctab is Nx4 array
	ctab ( \$levels, \$red, \$green, \$blue, [\$contrast, \$brightness] )
EOD
    }


    if ($#arg<3) {
      ($ctab, $contrast, $brightness) = @arg;
      @t = $ctab->dims; barf 'Must be a Nx4 array' if $#t != 1 || $t[1] != 4;
      $n = $t[0];
      $ctab   = float($ctab) if $ctab->get_datatype != $PDL_F;
      my $nn = $n-1;
      $levels = $ctab->slice("0:$nn,0:0");
      $red    = $ctab->slice("0:$nn,1:1");
      $green  = $ctab->slice("0:$nn,2:2");
      $blue   = $ctab->slice("0:$nn,3:3");
    } else {
      ($levels, $red, $green, $blue, $contrast, $brightness) = @arg;
      $self->_checkarg($levels,1);  $n = nelem($levels);
      for ($red,$green,$blue) {
	$self->_checkarg($_,1); barf 'Arguments must have same size' unless nelem($_) == $n;
      }
    }

    # Now load it

    $contrast   = 1   unless defined $contrast;
    $brightness = 0.5 unless defined $brightness;

    pgctab( $levels->get_dataref, $red->get_dataref, $green->get_dataref,
	    $blue->get_dataref, $n, $contrast, $brightness );
    $CTAB = { ctab => [ $levels, $red, $green, $blue ],
	      brightness => $brightness,
	      contrast => $contrast
	    };			# Loaded
    1;
  }

  # get information on last CTAB load
  sub ctab_info {
    my $self = shift;
    my ($in, $opt)=_extract_hash(@_);
    barf 'Usage: ctab_info( )' if $#$in> -1;

    return () unless $CTAB;
    return @{$CTAB->{ctab}}, $CTAB->{contrast}, $CTAB->{brightness};
  }
}

# display an image using pghi2d()

{

  my $hi2d_options = undef;

  sub hi2d {
    my $self = shift;
    if (!defined($hi2d_options)) {
      $hi2d_options = $self->{PlotOptions}->extend({
					       Ioff => undef,
					       Bias => undef
					      });
    }
    my ($in, $opt)=_extract_hash(@_);
    $opt = {} if !defined($opt);

    barf 'Usage: hi2d ( $image, [$x, $ioff, $bias] [, $options] )' if $#$in<0 || $#$in>3;
    my ($image, $x, $ioff, $bias) = @$in;
    $self->_checkarg($image,2);
    my($nx,$ny) = $image->dims;

    # Let us parse the options if any.
    my ($o, $u_opt) = $self->_parse_options($hi2d_options, $opt);
    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});

    if (defined($x)) {
      $self->_checkarg($x,1);
      barf '$x incorrect' if nelem($x)!=$nx;
    } else {
      $x = float(sequence($nx));
    }

    # Parse for options input instead of calling convention
    $ioff = $o->{Ioff} || 1 unless defined($ioff);
    $bias = $o->{Bias} if defined($o->{Bias});

    $bias = 5*max($image)/$ny unless defined $bias;
    my $work = float(zeroes($nx));

    $self->_save_status();
    $self->_standard_options_parser($o);

    $self->initenv( 0 ,2*($nx-1), 0, 10*max($image), $opt ) unless $self->held();

    pghi2d($image->get_dataref, $nx, $ny, 1,$nx,1,$ny, $x->get_dataref, $ioff,
	   $bias, 1, $work->get_dataref);

    $self->_restore_status();
    1;
  }
}

# Plot a polygon with pgpoly()

sub poly {
  my $self = shift;
  my ($in, $opt)=_extract_hash(@_);
  barf 'Usage: poly ( $x, $y [, $options] )' if $#$in<0 || $#$in>2;
  my($x,$y) = @$in;
  $self->_checkarg($x,1);
  $self->_checkarg($y,1);
  my ($o, $u_opt) = $self->_parse_options($self->{PlotOptions}, $opt);
  $self->_check_move_or_erase($o->{Panel}, $o->{Erase});

  unless ( $self->held() ) {
    my ($xmin, $xmax)=minmax($x); my ($ymin, $ymax)=minmax($y);
    $self->initenv( $xmin, $xmax, $ymin, $ymax, $opt );
  }

  $self->_save_status();
  $self->_standard_options_parser($o);
  my $n = nelem($x);
  pgpoly($n, $x->get_dataref, $y->get_dataref);
  $self->_restore_status();
  1;
}

# Plot a circle using pgcirc




{
  my $circle_options = undef;

  sub circle {
    my $self = shift;
    if (!defined($circle_options)) {
      $circle_options = $self->{PlotOptions}->extend({Radius => undef,
						 XCenter => undef,
						 YCenter => undef});
    }
    my ($in, $opt)=_extract_hash(@_);
    $opt = {} if !defined($opt);
    my ($x, $y, $radius)=@$in;

    my $o = $circle_options->options($opt);
    $o->{XCenter}=$x if defined($x);
    $o->{YCenter}=$y if defined($y);
    $o->{Radius} = $radius if defined($radius);

    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});

    $self->_save_status();
    $self->_standard_options_parser($o);
    pgcirc($o->{XCenter}, $o->{YCenter}, $o->{Radius});
    $self->_restore_status();
  }
}

# Plot an ellipse using poly.





{
  my $ell_options = undef;

  sub ellipse {
    my $self = shift;
    if (!defined($ell_options)) {
      $ell_options = $self->{PlotOptions}->extend({
					      MajorAxis=>undef,
					      MinorAxis=>undef,
					      Theta => 0.0,
					      XCenter => undef,
					      YCenter => undef,
					      NPoints => 100
						  });
      $ell_options->synonyms({Angle => 'Theta'});
    }
    my ($in, $opt)=_extract_hash(@_);
    my ($x, $y, $a, $b, $theta)=@$in;

    my $o = $ell_options->options($opt);
    $o->{XCenter}=$x if defined($x);
    $o->{YCenter}=$y if defined($y);
    $o->{MajorAxis} = $a if defined($a);
    $o->{MinorAxis} = $b if defined($b);
    $o->{Theta}=$theta if defined($theta);

    if (!defined($o->{MajorAxis}) || !defined($o->{MinorAxis}) || !defined($o->{XCenter})
       || !defined($o->{YCenter})) {
      barf "The major and minor axis and the center coordinates must be given!";
    }

    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});

    my $t = 2*$PI*sequence($o->{NPoints})/($o->{NPoints}-1);
    my ($xtmp, $ytmp) = ($o->{MajorAxis}*cos($t), $o->{MinorAxis}*sin($t));

    # Rotate the ellipse and shift it.
    my ($costheta, $sintheta)=(cos($o->{Theta}), sin($o->{Theta}));
    $x = $o->{XCenter}+$xtmp*$costheta-$ytmp*$sintheta;
    $y = $o->{YCenter}+$xtmp*$sintheta+$ytmp*$costheta;

    $self->poly($x, $y, $opt);

  }

}


{
  my $rect_opt = undef;
  sub rectangle {
    my $self = shift;
    my $usage='Usage: rectangle($xcenter, $ycenter, $xside, $yside, [, $angle, $opt])';
    if (!defined($rect_opt)) {
      # No need to use $self->{PlotOptions} here since we
      # pass control to poly below.
      $rect_opt = PDL::Options->new({XCenter => undef, YCenter => undef,
				     XSide => undef, YSide => undef,
				     Angle => 0, Side => undef});
      $rect_opt->synonyms({XCentre => 'XCenter', YCentre => 'YCenter',
			  Theta => 'Angle'});
      $rect_opt->warnonmissing(0);
    }
    my ($in, $opt)=_extract_hash(@_);
    $opt={} if !defined($opt);
    my ($xc, $yc, $xside, $yside, $angle)=@$in;
    my $o=$rect_opt->options($opt);

    $o->{XCenter}=$xc if defined($xc);
    $o->{YCenter}=$yc if defined($yc);
    $o->{XSide}=$xside if defined($xside);
    $o->{YSide}=$yside if defined($yside);
    $o->{Angle}=$angle if defined($angle);

    ##
    # Now do some error checking and checks for squares.
    ##
    if (defined($o->{XSide}) || defined($o->{YSide})) {
      # At least one of these are set - let us ignore Side.
      $o->{XSide}=$o->{YSide} if !defined($o->{XSide});
      $o->{YSide}=$o->{XSide} if !defined($o->{YSide});
    } elsif (defined($o->{Side})) {
      $o->{XSide}=$o->{Side};
      $o->{YSide}=$o->{Side};
    } else {
      print "$usage\n";
      barf 'The sides of the rectangle must be specified!';
    }

    unless (defined($o->{XCenter}) && defined($o->{YCenter})) {
      print "$usage\n";
      barf 'The center of the rectangle must be specified!';
    }

    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});

    # Ok if we got this far it is about time to do something useful,
    # namely construct the piddle that contains the sides of the rectangle.

    # We make it first parallell to the coordinate axes around origo
    # and rotate it subsequently (ala the ellipse routine above).
    my ($dx, $dy)=(0.5*$o->{XSide}, 0.5*$o->{YSide});
    my $xtmp = pdl(-$dx, $dx, $dx, -$dx, -$dx);
    my $ytmp = pdl(-$dy, -$dy, $dy, $dy, -$dy);

    my ($costheta, $sintheta)=(cos($o->{Angle}), sin($o->{Angle}));
    my $x = $o->{XCenter}+$xtmp*$costheta-$ytmp*$sintheta;
    my $y = $o->{YCenter}+$xtmp*$sintheta+$ytmp*$costheta;

    $self->poly($x, $y, $opt);

  }
}


# display a vector map of 2 images using pgvect()

{
  my $vect_options = undef;

  sub vect {
    my $self = shift;
    if (!defined($vect_options)) {
      $vect_options = $self->{PlotOptions}->extend({
					       Scale => 0,
					       Position => 0,
					       Missing => undef
					      });
      $vect_options->add_synonym({Pos => 'Position'});
    }
    my ($in, $opt)=_extract_hash(@_);
    barf 'Usage: vect ( $a, $b, [$scale, $pos, $transform, $misval] )' if $#$in<1 || $#$in>5;
    my ($a, $b, $scale, $pos, $tr, $misval) = @$in;
    $self->_checkarg($a,2); $self->_checkarg($b,2);
    my($nx,$ny) = $a->dims;
    my($n1,$n2) = $b->dims;
    barf 'Dimensions of $a and $b must be the same' unless $n1==$nx && $n2==$ny;

    my ($o, $u_opt) = $self->_parse_options($vect_options, $opt);
    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});

    # Parse for options input instead of calling convention
    $scale = $o->{Scale} if exists($u_opt->{Scale});
    $pos = $o->{Position} if exists($u_opt->{Scale});
    $tr = $o->{Transform} if exists($u_opt->{Transform});
    $misval = $o->{Missing} if exists($u_opt->{Missing});

    $scale = 0 unless defined $scale;
    $pos   = 0 unless defined $pos;

    if (defined($tr)) {
      $self->_checkarg($tr,1);
      barf '$transform incorrect' if nelem($tr)!=6;
    } else {
      $tr = float [0,1,0, 0,0,1];
    }
    $tr = $self->CtoF77coords($tr);

    $self->initenv( 0, $nx-1, 0, $ny-1, $opt ) unless $self->held();
    print "Vectoring $nx x $ny images ...\n" if $PDL::verbose;

    $self->_save_status();
    $self->_standard_options_parser($o); # For arrowtype and arrowhead
    pgvect( $a->get_dataref, $b->get_dataref, $nx,$ny,1,$nx,1,$ny, $scale, $pos,
	    $tr->get_dataref, $misval);
    $self->_restore_status();
    1;
  }
}

# ############ Text routines #############



{
  # Do not create this object unless necessary.
  my $text_options = undef;

  sub text {
    my $self = shift;

    if (!defined($text_options)) {
      # This is the first time this routine is called so we
      # have to initialise the options object.
      $text_options = $self->{PlotOptions}->extend({
					       Angle => 0.0,
					       Justification => 0.0,
					       Text => '',
					       XPos => undef,
					       YPos => undef
					      });
      $text_options->add_synonym({Justify => 'Justification'});
    }

    # Extract the options hash and separate it from the other input
    my ($in, $opt)=_extract_hash(@_);
    $opt = {} if !defined($opt);
    barf 'Usage: text ($text, $x, $y, [,$opt])' if 
      (!defined($opt) && $#$in < 2) || ($#$in > 3) || ($#$in < 0);
    my ($text, $x, $y)=@$in;

    # Next - parse options
    my $o = $text_options->options($opt);
    # Check for change of panel or request to erase the panel
    $self->_check_move_or_erase($o->{Panel}, $o->{Erase});
    # Parse standard options such as colour
    $self->_save_status();

    $self->_standard_options_parser($o);

    # Finally do what the routine needs to do.
    $o->{Text}=$text if defined($text);
    $o->{XPos}=$x if defined($x);
    $o->{YPos}=$y if defined($y);
    barf "text: You must specify the X-position!\n" if !defined($o->{XPos});
    barf "text: You must specify the Y-position!\n" if !defined($o->{YPos});

    pgptxt($o->{XPos}, $o->{YPos}, $o->{Angle}, $o->{Justification},
	   $o->{Text});
#
    $self->_restore_status();

    1;
  }
}



{
  my $legend_options = undef;

  sub legend {

    my $self = shift;
    if (!defined($legend_options)) {
      $legend_options = $self->{PlotOptions}->extend({
						 Text	   => undef,
						 XPos	   => undef,
						 YPos	   => undef,
						 Width     => 'Automatic',
						 Height    => 'Automatic',
						 Fraction  => 0.5,
						 TextShift => 0.1
						});
    }
    my ($in, $opt)=_extract_hash(@_);
    $opt = {} if !defined($opt);
    my $o = $legend_options->options($opt);

    #
    # In this function there are several options that we do not want
    # parsed by the standard options parsers so we deal with these
    # here - we translate the linestyles, symbols and colours below
    #
    my $linestyle=$o->{LineStyle}; delete $o->{LineStyle};
    $linestyle=[$linestyle] if !ref($linestyle) eq 'ARRAY';
    my $linewidth=$o->{LineWidth}; delete $o->{LineWidth};
    $linewidth=[$linewidth] if !ref($linewidth) eq 'ARRAY';
    my $color = $o->{Colour}; delete $o->{Colour};
    $color=[$color] if !ref($color) eq 'ARRAY';
    my $symbol = $o->{Symbol}; delete $o->{Symbol};
    $symbol=[$symbol] if !ref($symbol) eq 'ARRAY';

    my ($text, $x, $y, $width)=@$in;
    $o->{Text} = $text if defined($text);
    $o->{XPos} = $x if defined($x);
    $o->{YPos} = $y if defined($y);
    $o->{Width} = $width if defined($width);

    if (!defined($o->{XPos}) || !defined($o->{YPos}) || !defined($o->{Text})) {
      barf 'Usage: legend $text, $x, $y [,$width, $opt] (styles are given in $opt)';
    }
    $self->_save_status();
    $self->_standard_options_parser($o); # Set font, charsize, colour etc.

    # Ok, introductory stuff has been done, lets get down to the gritty
    # details. First let us save the current character size.
    my $chsz; pgqch($chsz);

    # In the following we want to deal with an array of text.
    $text = [$text] unless ref($text) eq 'ARRAY';

    # The size of the legend can be specified by giving the width or the
    # height so to calculate the required text size we need to find the
    # minimum required (since text in PGPLOT cannot have variable width
    # and height.
    # Get the window size.
    my ($xmin, $xmax, $ymax, $ymin);
    pgqwin($xmin, $xmax, $ymin, $ymax);

    my $required_charsize=$chsz*9000;
    if ($o->{Width} eq 'Automatic' && $o->{Height} eq 'Automatic') {
      # Ok - we just continue with the given character size.
      $required_charsize = $chsz;
    } else {
      # We have some constraint on the size.
      my ($win_width, $win_height)=($xmax-$xmin, $ymax-$ymin);

      # If either the width or the height is set to automatic we set
      # the width/height here to be 2 times the width/height of the
      # plot window - thus ensuring not too large a text size should the
      # user have done something stupid, but still large enough to
      # detect an error.
      $o->{Width}=2*$win_width/$o->{Fraction} if $o->{Width} eq 'Automatic';
      $o->{Height}=2*$win_height if $o->{Height} eq 'Automatic';

      my $n_lines = $#$text+1; # The number of lines.
      foreach my $t (@$text) {
	# Find the bounding box of left-justified text
	my ($xbox, $ybox);
	pgqtxt($xmin, $ymin, 0.0, 0.0, $t, $xbox, $ybox);
	
	# Find what charactersize is required to fit the height or
	# fraction*width:
	my $t_width= $o->{Fraction}*$o->{Width}/($$xbox[2]-$$xbox[0]);
	my $t_height = $o->{Height}/$n_lines/($$ybox[2]-$$ybox[0]);

	$t_chsz = ($t_width < $t_height ? $t_width*$chsz : $t_height*$chsz);
#	print "For text = $t the optimal size is $t_chsz ($t_width, $t_height)\n";
	$required_charsize = $t_chsz if $t_chsz < $required_charsize;

      }
    }

    #
    # Ok, $required_charsize should now contain the optimal size for the
    # text. The next step is to create the legend. We can set linestyle,
    # linewidth, colour and symbol for each of these texts.
    #
    pgsch($required_charsize*$chsz); # Since we measured relative to $chsz
    my ($xpos, $ypos) = ($o->{XPos}, $o->{YPos});
    my ($xstart, $xend)=($o->{XPos}+$o->{Fraction}*$o->{Width}+
			 $o->{TextShift}*$o->{Width}, $o->{XPos}+$o->{Width});

    foreach (my $i=0; $i<=$#$text; $i++) {
      $self->text($text->[$i], $xpos, $ypos);
      # Since the parsing of options does not go down array references
      # we need to create a temporary PDL::Options object here to do the
      # parsing..
      my $t_o = $self->{PlotOptions}->options({
					Symbol => $symbol->[$i],
					LineStyle => $linestyle->[$i],
					LineWidth => $linewidth->[$i],
					Colour => $color->[$i]
				      });
      my $col; pgqci($col);
      pgsci($t_o->{Colour}) if defined($color->[$i]);
      my ($lw, $ls);
      pgqls($ls); pgqlw($lw);

      # Use the following to get the lines/symbols centered on the
      # text.
      my ($xbox, $ybox);
      pgqtxt($xpos, $ypos, 0.0, 0.0, $text->[$i], $xbox, $ybox);
      if (defined($$symbol[$i])) {
#	print "I will be using symbol $$o{Symbol}\n";
	my ($xsym, $ysym)=(0.5*($xstart+$xend), 0.5*($$ybox[2]+$$ybox[0]));

	pgpt(1, $xsym, $ysym, $t_o->{Symbol});
      } else {
#	print "I will be drawing a line with colour $$o{Colour} and style $$o{LineStyle}\n";
	my $yline=0.5*($$ybox[2]+$$ybox[0]);
	pgsls($t_o->{LineStyle}) if defined($linestyle->[$i]);
	pgslw($t_o->{LineWidth}) if defined($linewidth->[$i]);
	pgline(2, [$xstart, $xend], [$yline, $yline]);
      }
      pgsci($col); # Reset colour after each line so that the text comes
      # in a sensible colour
      pgsls($ls); # And line style
      pgslw($lw); # And line width
#      print "$i: Required charsize=$required_charsize Charsize=$chsz\n";
#      print "$i: Ypos=$ypos\n";
      $ypos -= $required_charsize*$chsz;
    }


    $self->_restore_status();
  }

}





############## Cursor routine ##################



{
  $cursor_options = undef;
  sub cursor {

    my $self = shift;
    # Let us check if this is a hardcopy device, in which case we will return
    # with a warning and undefined values.
    my ($hcopy, $len);
    pgask(0);
    pgqinf("HARDCOPY",$hcopy,$len);
    if ($hcopy eq 'YES') {
      warn "cursor called on a hardcopy device - returning!\n";
      return (undef, undef, undef, undef, undef);
    }

    if (!defined($cursor_options)) {
      $cursor_options = PDL::Options->new(
					  {
					   'XRef' => undef,
					   'YRef' => undef,
					   'Type' => 0
					  });
      $cursor_options->translation({Type=>{
				   'Default'                  => 0,
				   'RadialLine'		      => 1,
				   'Rectangle'		      => 2,
				   'TwoHorizontalLines'	      => 3,
				   'TwoVerticalLines'	      => 4,
				   'HorizontalLine'	      => 5,
				   'VerticalLine'	      => 6,
				   'CrossHair'		      => 7
				  }});
    }

    my ($opt)=@_;
    $opt = {} unless defined($opt);
    my $place_cursor=1; # Since X&Y might be uninitialised.
    my $o = $cursor_options->options($opt);

    my ($x, $y, $ch);

    if ($o->{Type} eq 'Rectangle' && !defined($o->{XRef})) {
      #
      # We use pgcurs to get a first position.
      #
      print "Please select a corner of the rectangle\n";
      pgcurs($x, $y, $ch);
      $o->{XRef}=$x;
      $o->{YRef}=$y;
    }

    if ($o->{Type} > 7 || $o->{Type} < 0) {
      print "Unknown type of cursor $$o{Type} - using Default\n";
      $o->{Type}=0;
    }
    my ($xmin, $xmax, $ymax, $ymin);
    pgqwin($xmin, $xmax, $ymin, $ymax);

    $x = 0.5*($xmin+$xmax) if !defined($x);
    $y = 0.5*($ymin+$ymax) if !defined($y);

    my ($got_xref, $got_yref)=(defined($o->{XRef}), defined($o->{YRef}));
    if (!$got_xref || !$got_yref) {
      # There is a little bit of gritty error-checking
      # for the users convenience here.
      if ($o->{Type}==1 || $o->{Type}==2) {
	barf "When specifying $$o{Type} as cursor you must specify the reference point";
      } elsif ($o->{Type}==3 && !$got_yref) {
	barf "When specifying two horizontal lines you must specify the Y-reference";
      } elsif ($o->{Type}==4 && !$got_xref ) {
	barf "When specifying two vertical lines you must specify the X-reference";
      }

      # Ok so we have some valid combination of type and reference point.
      $o->{XRef}=$xmin if !$got_xref;
      $o->{YRef}=$ymin if !$got_yref;

    }


    $ch = ''; # To silence -w
    my $istat = pgband($o->{Type}, $place_cursor, $o->{XRef},
		       $o->{YRef}, $x, $y, $ch);

    return ($x, $y, $ch, $o->{XRef}, $o->{YRef});

  }
}


=head1 INTERNAL

The coding tries to follow reasonable standards, so that all functions
starting with an underscore should be considered as internal and should
not be called from outside the package. In addition most routines has
a set of options. These are encapsulated and are not accessible outside
the routine. This is to avoid collisions between different variables.


=head1 AUTHOR

Karl Glazebrook [kgb@aaoepp.aao.gov.au] modified by Jarle Brinchmann
(jarle@astro.ox.ac.uk) who is also responsible for the OO interface,
docs mangled by Tuomas J. Lukka (lukka@fas.harvard.edu) and
Christian Soeller (c.soeller@auckland.ac.nz). Further contributions and
bugfixes from Kaj Wiik, Doug Burke and many others.

All rights reserved. There is no warranty. You are allowed
to redistribute this software / documentation under certain
conditions. For details, see the file COPYING in the PDL
distribution. If this file is separated from the PDL distribution,
the copyright notice should be included in the file.

=cut



#

1;

__DATA__

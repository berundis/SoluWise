##############################################################
###   This Code opens and analyzes a XML file to extract   ###
###   the wanted data and create a HTML file with tables   ### 
###   representing this data.                              ###
###   Subroutines used in this code are found at the       ###
###   bottom starting in line 110                          ###
##############################################################

#!/usr/bin/perl
use strict;
use warnings;

### STRING RESULT TO MAKE A HTML FILE
### Each movie table will be added to this string
my $html_result = 
"<!DOCTYPE html>
<html>
<head>
<style>
table {
  width: 75%;
  margin: auto;
}
table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
}
th, td {
    padding: 5px;
    text-align: left;    
}
</style>
</head>
<body>";

### GET DATA FROM XML FILE
open(FILE, "test.xml");
  my $xml = <FILE>;
close(FILE);

### GET DATA FOR EACH MOVIE AND STORE IT IN AN ARRAY 
my @movies = ();
get_movies(split (/<a href="log.php/,$xml));


###################################
######   CREATE MOVIE TABLE  ######
###################################
foreach my $movie (@movies) {
  my $table = "<table>";  ## This is the table string and will be added to $html_result when completed

  ## Devides Data in Array: [Title, Showings] 
  my @movie_details = split(/<br\/>/, $movie);

  # GET TITLE and SHOWINGS
  my $title = get_movie_title($movie_details[0]);
  my @showings = get_movie_showings($movie_details[1]);

  ## Get Max Columns For Table
  # This will be used to colspan the title header and to add blank row for a movie showing if necesary (aesthetic purposes)
  my $max_columns = get_max_columns(@showings);

  ## Add Title To Table
  $table = $table . "<tr><th colspan=\"$max_columns\" style=\"color:blue;\">" . $title . "</th></tr>";
  
  foreach my $showing (@showings) {
    ## Devide Showing by Day(s) and Times
    my @showing_details = split(/ <br \/> /, $showing);

    # Define day(s) of showing and Add to Table
    my $date = $showing_details[0];
    $table = $table . "<tr><td style=\"color:red;\">" . $date . "</td>";
    # Define times of showing 
    my @times = split(/, /, $showing_details[1]);

    # Adds Each Show Time to Table
    for( my $index = 0; $index < $max_columns - 1; $index = $index + 1 ) {
      my $time_table_text = get_show_time_table_html($times[$index], $index);
      $table = $table . $time_table_text
    }
  }
  
  ### Add Closing Tags to Table
  $table = $table . "</tr></table><br>";
  ### Add Table To $html_result 
  $html_result = $html_result . $table;
}
### ADD CLOSING TAGS TO HTML_RESULT
$html_result = $html_result . "</body></html>";


##################################
######   CREATE HTML FILE   ######
##################################
my $movies_file = "movies.html";

# Use the open() function to create the file.
unless(open MOVIE_FILE, '>'.$movies_file) {
    # Die with error message if we can't open it.
    die "\nUnable to create $movies_file\n";
}

# Add HTML (Tables) to movie.html
print MOVIE_FILE $html_result;

# close the file.
close MOVIE_FILE;


###############################
#######   SUBROUTINES   #######
##############################
sub get_movies {
  my @array = @_;
  for( my $index = 1; $index < scalar @array; $index = $index + 1 ) {
    if ($array[$index] =~ /(.*)<p align="center">/){
      push @movies, $1;
    } else {
      push @movies, $array[$index];
    }
  }
}

sub get_movie_title {
  my $movie_title = $_[0];
  $movie_title =~ /\?MovieName=(.*)&referrer=plaza_las_americas.html">/; 
  return $1;
}

sub get_movie_showings {
  my $movie_showings = $_[0];
  $movie_showings =~ s/^\s+|\s+$//g;
  return split(/<br>/, $movie_showings);
}
sub get_max_columns {
    my @array = @_;
    my $max = 0;
    foreach my $showing (@array) {
      my @arr = split (/ <br \/> |, /, $showing);
      if (scalar @arr > $max) {
        $max = scalar @arr;
      }
    }
    return $max;
}

sub get_show_time_table_html {
  my $style = "";
  my $text = ""; 
  my $show_time = $_[0];
  my $index = $_[1];
  # make sure the show time existes (else blank space is inserted to table) (aesthetic purposes)
  if ($show_time) {
    $text = $show_time;
  } 
  # alternate between yellow and green.
  if ($index % 2 == 0) {
    $style = "style=\"color:yellow;\">";
  } else {
    $style = "style=\"color:green;\">";
  }
  ## ADD TIME TO TABLE 
  return "<td " . $style . $text . "</td>";
}

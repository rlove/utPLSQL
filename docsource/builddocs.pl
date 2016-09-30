#!/usr/bin/perl
use strict;
use warnings;
use IPC::System::Simple qw(system);
use MarkDent::Simple::Document;
use File::Map qw(map_file);
use File::Path qw(make_path);

main();

sub main{
    # Create output directories if the don't exists
	make_path("../docs");
	
	# Execute NaturalDocs 
	# -i InputDirectory
	# -o FramedHTML or HTML OutputDirectory  (Using HTML so we can directly link to documenation pages easier.)
	# -p ProectDirectory
	# -xi ExcludeDirFromInput
	# -r RebuildAllFiles	
	my @nd_args = qw(      
		  -i ../ 
		  -o HTML ../docs/ 
		  -p ./project 
		  -xi ../.travis 
		  -xi ../examples 
		  -xi ../lib 
		  -xi ../tools 
		  -xi ../build 
		  -r
		  );	  
    system($^X, "../tools/NaturalDocs/NaturalDocs", @nd_args);
    
	#convert markdown files to html 
    convert_markdown("../CONTRIBUTING.md","../docs/files/docsource/topics/contributing-txt.html","How to contribute to utPLSQL");
	
	#Checking for current/past errors with NaturalDocs
	check_project_file_for_error("project/Menu.txt");		
	check_project_file_for_error("project/Languages.txt");		
    check_project_file_for_error("project/Topics.txt");				
	if (-e "project/LastCrash.txt")	 {
	   die "project/LastCrash.txt found, indicating a prior NaturalDocs problem that should be fixed.  Note: File must be manually removed to continue";
	 }
}

sub check_project_file_for_error {
  my $file_to_check = shift;
  map_file(my $menufile,$file_to_check); 
  if ($menufile =~ /ERROR/) { die "ERROR found $file_to_check" }
}  

sub convert_markdown {
   my $source = shift;
   my $dest = shift;   
   my $title = shift;  

   # memory map input file
   map_file(my $markdown, $source);   
  
   # convert markdown to html
   my $parser = Markdent::Simple::Document->new();
   my $html   = $parser->markdown_to_html(
						  title    => $title,
						  markdown => $markdown);

   # check output file exists, and deletes.		   
   if (-f $dest)  {
	   unlink $dest or die "Cannot delete $dest: $!";								  
   }
   
   # write markdown to file
   my $OUTFILE;
   open $OUTFILE, '>>', $dest or die "Cannot open $dest";
   print { $OUTFILE } $html or die "Cannot write to $dest";
   close $OUTFILE or die "Cannot close $dest";
   
   print "Converted $source to $dest" 
}














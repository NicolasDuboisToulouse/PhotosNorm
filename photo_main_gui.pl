#!/usr/bin/env perl
#
# Simple dialog to run other tools
#
BEGIN {
    my $soft_home = ($0 =~ /(.*)[\\\/]/) ? $1 : '.';
    unshift @INC, "$soft_home/lib";
}

use strict;
use warnings;
use PhotosNorm::GuiLogger;
use PhotosNorm::BasicFix;
use PhotosNorm::Main;
use Wx;

my $title = "PhotosNorm";

package MainDialog;
use File::Basename;
use base 'Wx::Dialog';

use Wx qw(wxVERTICAL wxEXPAND wxALL wxLEFT wxRIGHT wxALIGN_CENTER);
use Wx::Event qw(EVT_BUTTON);

sub new
{
    my ($class, $logger, @files) = @_;
    my $self = $class->SUPER::new(undef, -1, $title);
    $self->SetIcon(Wx::GetWxPerlIcon());

    $self->{logger} = $logger;
    $self->{files} = @files;

    my $sizer = Wx::BoxSizer->new(wxVERTICAL);

    my $text;
    if (@files == 1 && -d $files[0]) {
        $text = "Folder: " . basename($files[0]);
    } else {
        $text = @files . " photos";
    }

    my $static_box_sizer = Wx::StaticBoxSizer->new(Wx::StaticBox->new($self, -1, "Photo selection"), wxVERTICAL);
    $static_box_sizer->Add(Wx::StaticText->new($self, -1, $text), 0, wxEXPAND | wxLEFT | wxRIGHT, 5);
    $sizer->Add($static_box_sizer, 0, wxALL | wxEXPAND, 10);

    my $button_basic_fix = Wx::Button->new($self, -1, "&Quick Fix...");
    EVT_BUTTON($self, $button_basic_fix, \&notYetImplemented);
    $sizer->Add($button_basic_fix, 0, wxALL | wxEXPAND | wxALIGN_CENTER, 10);

    my $button_edit = Wx::Button->new($self, -1, "&Edit metadata...");
    EVT_BUTTON($self, $button_edit, \&notYetImplemented);
    $sizer->Add($button_edit, 0, wxALL | wxEXPAND | wxALIGN_CENTER, 10);

    my $button_auto_rename = Wx::Button->new($self, -1, "&Rename with date and title...");
    EVT_BUTTON($self, $button_auto_rename, \&notYetImplemented);
    $sizer->Add($button_auto_rename, 0, wxALL | wxEXPAND | wxALIGN_CENTER, 10);

    my $button_close = Wx::Button->new($self, -1, "&Close");
    EVT_BUTTON($self, $button_close, \&onButtonClose);
    $sizer->Add($button_close, 0, wxALL | wxEXPAND | wxALIGN_CENTER, 10);

    $self->SetSizer($sizer);

    $button_close->SetDefault();
    $button_close->SetFocus();
    $self->SetAutoLayout(1);
    $self->Fit();
    return $self;
}

sub onButtonClose {
    $_[0]->Close();
}

sub notYetImplemented {
    my ($self) = @_;
    $self->{logger}->msg("Not yet Implemented !");
}


package main;

my $app = Wx::SimpleApp->new();

my $logger = PhotosNorm::GuiLogger->new($title);

PhotosNorm::Main::parse_args($logger, undef, @ARGV);

my $dialog = MainDialog->new($logger, @PhotosNorm::Main::files);
$app->SetTopWindow($dialog);
$dialog->CentreOnScreen();
$dialog->ShowModal();

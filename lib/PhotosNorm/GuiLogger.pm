# Dubois Nicolas (c) 2019
# MIT Licence
# Display a widget logger
use strict;
use warnings;
use threads;
use threads::shared;
use Wx;

#
# Main wx-application class
#
package PhotosNorm::GuiLogger;
use base 'Wx::App';

sub new
{
    my ($class, $title) = @_;
    my $self = $class->SUPER::new();

    $self->{frame} = PhotosNorm::GuiLoggerFrame->new($title);
    $self->{frame}->Show(1);
    $self->SetTopWindow($self->{frame});
    $self->{frame}->CentreOnScreen();
    return $self;
}

sub OnInit { 1 }

sub run
{
    my($self) = @_;
    $self->{frame}->run();
    $self->MainLoop();
}

#
# Single wx-frame class
#
package PhotosNorm::GuiLoggerFrame;
use base 'Wx::Frame';

use Wx qw(wxTE_MULTILINE wxVERTICAL wxID_DEFAULT wxEXPAND wxALL wxALIGN_RIGHT);
use Wx::Event qw(EVT_COMMAND EVT_CLOSE EVT_BUTTON);

my $work_done_event : shared = Wx::NewEventType;

sub new {
    my ($class, $title) = @_;
    my $self = $class->SUPER::new(undef, -1, $title, [-1,-1], [800, 500]);
    $self->{text_ctrl} = Wx::TextCtrl->new($self, -1, "", [-1,-1], [300, 300], wxTE_MULTILINE);
    $self->{button_close} = Wx::Button->new($self, -1, "&Close");

    my $sizer = Wx::BoxSizer->new(wxVERTICAL);
    $sizer->Add($self->{text_ctrl}, 1, wxEXPAND);
    $sizer->Add($self->{button_close}, 0, wxALL | wxALIGN_RIGHT, 10);
    $self->SetSizer($sizer);
    $self->SetAutoLayout(1);

    EVT_CLOSE($self, \&OnClose);
    EVT_BUTTON($self,  $self->{button_close}, \&onButtonClose);
    EVT_COMMAND($self, -1, $work_done_event, \&onWorkDone);

    return $self;
}

sub run
{
    my($self) = @_;
    $self->{button_close}->Enable(0);

    $self->{thread} = threads->create(\&workMain, $self);
}

sub workMain
{
    my($handler) = @_;
    print "Work Start...\n";
    sleep(3);
    print "Work Done\n";

    my $thread_event = Wx::PlThreadEvent->new(-1, $work_done_event, undef);
    Wx::PostEvent($handler, $thread_event);
}

sub onWorkDone
{
    my ($self, $event) = @_;

    print "Done callback\n";
    if ($self->{thread}) {
        $self->{thread}->join();
        $self->{thread} = undef;
    }
    $self->{button_close}->Enable(1);
}


sub onButtonClose
{
    my($self, $event) = @_;
    $self->Close();
}

sub OnClose
{
    my($self, $event) = @_;

    if ($self->{thread}) {
        $self->{thread}->join();
        $self->{thread} = undef;
    }

    $event->Skip();
}



1;


# Dubois Nicolas (c) 2019
# MIT Licence
#
# Display a text widget to show the output of a callback function.
#
# USAGE
#
# # callback function
# # Warn: this function will be called in an other thread.
# sub worker {
#     my ($logger, $arg1, $argn) = @_;
#
#     # do some stuff
#
#     sleep(1);
#     $logger->log($arg1); # display some text
#     sleep(1);
#     $logger->lognl($arg1); # display some text and append a new line
# }
#
# # Create the logger
# my $gui = PhotosNorm::GuiLogger->new("widget title");
#
# # Run our callback
# $gui->run(\&worker, "Hello", "World");
#
use strict;
use warnings;
use threads;
use threads::shared;
use Wx;

# -----------------------------------------------------------------------------
# Main Gui logger class
# -----------------------------------------------------------------------------
package PhotosNorm::GuiLogger;
use base "PhotosNorm::Logger";

sub new
{
    my ($class, $title) = @_;
    my $self = $class->SUPER::new();
    $self->{title} = $title;
    $self->{frame} = PhotosNorm::GuiLoggerFrame->new($title);
    return $self;
}

sub OnInit { 1 }

# Call callback_fun with callback_args and display result in text dialog
# (Will give and back once text dialog closed by user)
sub run
{
    my($self, $callback_fun, @callback_args) = @_;
    $self->{frame}->run($callback_fun, @callback_args);
}

# Logger implementation
sub msg
{
    my($self, $text) = @_;
    Wx::MessageBox($text, $self->{title});
}

sub log
{
    my($self, $text) = @_;
    $self->{frame}->{text_ctrl}->AppendText($text);
}



# -----------------------------------------------------------------------------
# Text dialog class with worker thread and events
# -----------------------------------------------------------------------------
package PhotosNorm::GuiLoggerFrame;
use base 'Wx::Dialog';

use Wx qw(wxTE_MULTILINE wxVERTICAL wxEXPAND wxALL wxALIGN_RIGHT wxDEFAULT_DIALOG_STYLE wxRESIZE_BORDER);
use Wx::Event qw(EVT_COMMAND EVT_CLOSE EVT_BUTTON);

my $work_done_event  : shared = Wx::NewEventType;
my $work_write_event : shared = Wx::NewEventType;
my $work_msg_event   : shared = Wx::NewEventType;

sub new {
    my ($class, $title) = @_;
    my $self = $class->SUPER::new(undef, -1, $title, [-1,-1], [800, 500], wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER);
    $self->{title} = $title;

    $self->{text_ctrl} = Wx::TextCtrl->new($self, -1, "", [-1,-1], [300, 300], wxTE_MULTILINE);
    $self->{button_close} = Wx::Button->new($self, -1, "&Close");
    $self->SetIcon(Wx::GetWxPerlIcon());

    my $sizer = Wx::BoxSizer->new(wxVERTICAL);
    $sizer->Add($self->{text_ctrl}, 1, wxEXPAND);
    $sizer->Add($self->{button_close}, 0, wxALL | wxALIGN_RIGHT, 10);
    $self->SetSizer($sizer);
    $self->SetAutoLayout(1);
    $self->CentreOnScreen();

    EVT_CLOSE($self, \&OnClose);
    EVT_BUTTON($self,  $self->{button_close}, \&onButtonClose);
    EVT_COMMAND($self, -1, $work_done_event, \&onWorkDone);
    EVT_COMMAND($self, -1, $work_write_event, \&onWorkWrite);
    EVT_COMMAND($self, -1, $work_msg_event, \&onWorkMsg);

    return $self;
}

# Launch a new logger thread
sub run
{
    my($self, $callback_fun, @callback_args) = @_;
    $self->{button_close}->Enable(0);

    $self->{thread} = threads->create(\&workMain, $self, $callback_fun, @callback_args);
    $self->ShowModal();
}

# Wrie text
sub onWorkWrite
{
    my ($self, $event) = @_;
    my $text = $event->GetData;
    $self->{text_ctrl}->AppendText($text);
}

# Meessage text
sub onWorkMsg
{
    my ($self, $event) = @_;
    my $text = $event->GetData;
    Wx::MessageBox($text, $self->{title});
}


# Safe close thread
sub onWorkDone
{
    my ($self, $event) = @_;

    if ($self->{thread}) {
        $self->{thread}->join();
        $self->{thread} = undef;
    }
    $self->{button_close}->Enable(1);
    $self->{button_close}->SetFocus();
    $self->{button_close}->SetDefault();
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

# Log thread main
sub workMain
{
    my($handler, $callback_fun, @callback_args) = @_;

    my $logger = PhotosNorm::GuiLoggerFrame::ThreadLogger->new($handler);

    $callback_fun->($logger, @callback_args);

    my $thread_event = Wx::PlThreadEvent->new(-1, $work_done_event, undef);
    Wx::PostEvent($handler, $thread_event);
}


# -----------------------------------------------------------------------------
# Logger class for thread
# -----------------------------------------------------------------------------
package PhotosNorm::GuiLoggerFrame::ThreadLogger;
use base "PhotosNorm::Logger";

sub new
{
    my ($class, $handler) = @_;
    my $self = $class->SUPER::new();
    $self->{handler} = $handler;
    return $self;
}

sub log
{
    my($self, $text) = @_;
    my $write_event = Wx::PlThreadEvent->new(-1, $work_write_event, $text);
    Wx::PostEvent($self->{handler}, $write_event);
}

sub msg
{
    my($self, $text) = @_;
    my $msg_event = Wx::PlThreadEvent->new(-1, $work_msg_event, $text);
    Wx::PostEvent($self->{handler}, $msg_event);
}

1;

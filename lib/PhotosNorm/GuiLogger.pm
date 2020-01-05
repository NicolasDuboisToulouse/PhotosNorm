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
# # Create the widget
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
# Main wx-application class
# -----------------------------------------------------------------------------
package PhotosNorm::GuiLogger;
use base 'Wx::App';

sub new
{
    my ($class, $title) = @_;
    my $self = $class->SUPER::new();

    $self->{title} = $title;

    $self->{frame} = PhotosNorm::GuiLoggerFrame->new($title);
    $self->SetTopWindow($self->{frame});
    $self->{frame}->CentreOnScreen();
    return $self;
}

sub OnInit { 1 }

# Launch a new logger thread
sub run
{
    my($self, $callback_fun, @callback_args) = @_;
    $self->{frame}->run($callback_fun, @callback_args);
    $self->{frame}->ShowModal();
}

sub msg
{
    my($self, $text) = @_;
    Wx::MessageBox($text, $self->{title});
}



# -----------------------------------------------------------------------------
# Single wx-frame class
# -----------------------------------------------------------------------------
package PhotosNorm::GuiLoggerFrame;
use base 'Wx::Dialog';

use Wx qw(wxTE_MULTILINE wxVERTICAL wxID_DEFAULT wxEXPAND wxALL wxALIGN_RIGHT wxDEFAULT_DIALOG_STYLE wxRESIZE_BORDER);
use Wx::Event qw(EVT_COMMAND EVT_CLOSE EVT_BUTTON);

my $work_done_event : shared = Wx::NewEventType;
my $work_write_event : shared = Wx::NewEventType;

sub new {
    my ($class, $title) = @_;
    my $self = $class->SUPER::new(undef, -1, $title, [-1,-1], [800, 500], wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER);
    $self->{text_ctrl} = Wx::TextCtrl->new($self, -1, "", [-1,-1], [300, 300], wxTE_MULTILINE);
    $self->{button_close} = Wx::Button->new($self, -1, "&Close");
    $self->SetIcon(Wx::GetWxPerlIcon());

    my $sizer = Wx::BoxSizer->new(wxVERTICAL);
    $sizer->Add($self->{text_ctrl}, 1, wxEXPAND);
    $sizer->Add($self->{button_close}, 0, wxALL | wxALIGN_RIGHT, 10);
    $self->SetSizer($sizer);
    $self->SetAutoLayout(1);

    EVT_CLOSE($self, \&OnClose);
    EVT_BUTTON($self,  $self->{button_close}, \&onButtonClose);
    EVT_COMMAND($self, -1, $work_done_event, \&onWorkDone);
    EVT_COMMAND($self, -1, $work_write_event, \&onWorkWrite);

    return $self;
}

# Launch a new logger thread
sub run
{
    my($self, $callback_fun, @callback_args) = @_;
    $self->{button_close}->Enable(0);

    $self->{thread} = threads->create(\&workMain, $self, $callback_fun, @callback_args);
}

# Wrie text
sub onWorkWrite
{
    my ($self, $event) = @_;
    my $text = $event->GetData;
    $self->{text_ctrl}->AppendText($text);
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

    my $logger = PhotosNorm::GuiLoggerFrame::logger->new($handler);

    $callback_fun->($logger, @callback_args);

    my $thread_event = Wx::PlThreadEvent->new(-1, $work_done_event, undef);
    Wx::PostEvent($handler, $thread_event);
}


# -----------------------------------------------------------------------------
# logger class
# -----------------------------------------------------------------------------
package PhotosNorm::GuiLoggerFrame::logger;
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

1;

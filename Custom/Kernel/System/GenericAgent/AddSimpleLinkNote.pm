# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Custom::Kernel::System::GenericAgent::AddSimpleLinkNote;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::HTMLUtils',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article::Backend::Internal',
);

sub new {
    my ($Type, %Param) = @_;

    # allocate new hash for object
    my $Self = {};
    bless($Self, $Type);

    # 0=off; 1=on;
    $Self->{Debug} = $Param{Debug} || 0;

    return $Self;
}

sub Run {
    my ($Self, %Param) = @_;

    # write log
    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'debug',
        Message  =>
            'AddSimpleLinkNote: Started (for Ticket: ' . $Param{TicketID} . ')',
    );

    # collect escaped content for Note
    my %Data;

    # check needed param: Subject
    if (!$Param{New}->{'Subject'}) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need Subject param for GenericAgent module!',
        );
        return;
    }

    my %SafetyCheckResultSubject = $Kernel::OM->Get('Kernel::System::HTMLUtils')->Safety(
        String       => $Param{New}->{'Subject'},
        # Disallow potentially unsafe content.
        NoExtSrcLoad => 1,
        NoApplet     => 1,
        NoObject     => 1,
        NoEmbed      => 1,
        NoSVG        => 1,
        NoJavaScript => 1,
    );
    $Data{Subject} = $SafetyCheckResultSubject{String};

    # check needed param: Body
    if (!$Param{New}->{'Body'}) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need Body param for GenericAgent module!',
        );
        return;
    }

    my %SafetyCheckResultBody = $Kernel::OM->Get('Kernel::System::HTMLUtils')->Safety(
        String       => $Param{New}->{'Body'},
        # Disallow potentially unsafe content.
        NoExtSrcLoad => 1,
        NoApplet     => 1,
        NoObject     => 1,
        NoEmbed      => 1,
        NoSVG        => 1,
        NoJavaScript => 1,
    );
    $Data{Body} = $SafetyCheckResultBody{String};


    # check optional param: Link
    # and then set BodyHTML accordingly
    if ($Param{New}->{'Link'}) {
        my %SafetyCheckResultLink = $Kernel::OM->Get('Kernel::System::HTMLUtils')->Safety(
            String       => $Param{New}->{'Link'},
            # Disallow potentially unsafe content.
            NoExtSrcLoad => 1,
            NoApplet     => 1,
            NoObject     => 1,
            NoEmbed      => 1,
            NoSVG        => 1,
            NoJavaScript => 1,
        );
        $Data{Link} = $SafetyCheckResultLink{String};

        $Data{BodyHTML} = '<!DOCTYPE html><html>
            <body style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;">
            <p>' . $Data{Body} . '</p>
            [1] <a href="' . $Data{Link} . '">' . $Data{Link} . '</a></body></html>';
    }
    else {
        $Data{BodyHTML} = '<!DOCTYPE html><html>
            <body style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;">
            <p>' . $Data{Body} . '</p></body></html>';
    }

    # check optional param: SenderType (e.g. system, agent, customer) - if not set default to: system
    $Data{SenderType} = $Param{New}->{'SenderType'} ? $Param{New}->{'SenderType'} : 'system';

    # check optional param: From - if not set default to: System <root@localhost>
    $Data{From} = $Param{New}->{'From'} ? $Param{New}->{'From'} : 'System <root@localhost>';

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # get ticket data
    my %Ticket = $TicketObject->TicketGet(
        %Param,
        DynamicFields => 0,
    );

    my $ArticleID = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
        TicketID             => $Param{TicketID},
        IsVisibleForCustomer => 0,
        SenderType           => $Data{SenderType},
        From                 => $Data{From},
        Subject              => $Data{Subject},
        Body                 => $Data{BodyHTML},
        ContentType          => 'text/html; charset="utf-8"',
        HistoryType          => 'OwnerUpdate',
        HistoryComment       => 'Note added by GenericAgent module AddSimpleLinkNote',
        UserID               => 1,
        NoAgentNotify        => 1, # if you don't want to send agent notifications
    );

    # write log
    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'debug',
        Message  =>
            'AddSimpleLinkNote: Finished (created Article: ' . $ArticleID . ')',
    );

    return 1;
}

1;

use Modern::Perl '2012';
use MooseX::Declare;

class IMAP::Tools {
    use Config::Std;
    use Net::IMAP::Client;

    has 'client' => (
        is  => 'rw',
        isa => 'Net::IMAP::Client',
    );
    has 'config' => (
        is      => 'rw',
        isa     => 'Config::Std::Hash',
        builder => 'build_config',
        lazy    => 1,
    );
    has 'config_file' => (
        is      => 'ro',
        isa     => 'Str',
        default => $ENV{'IMAP_TOOLS_CONFIG'}
                    // "$ENV{'HOME'}/etc/imap.conf",
    );

    use constant DELETED_FLAG   => '\\Deleted';
    use constant SEEN_FLAG      => '\\Seen';
    use constant ANSWERED_FLAG  => '\\Answered';
    use constant DRAFT_FLAG     => '\\Draft';
    use constant RECENT_FLAG    => '\\Recent';
    use constant FLAGGED_FLAG   => '\\Flagged';

    method build_config {
        read_config $self->config_file => my %config;
        $self->config( \%config );
    }

    method login_to_imap_server ( $account ) {
        my $account_config = $self->config->{$account};
        my $host           = $account_config->{'host'} // 'localhost';
        my $client         = Net::IMAP::Client->new(
                server => $host,
                user   => $account_config->{'user'},
                pass   => $account_config->{'pass'},
                ssl    => $account_config->{'ssl'} // 0,
            );

        die "Couldn't connect: $!"
            if !defined $client;

        $client->login
            or die sprintf "Login failed: %s\n", $client->last_error;

        $self->client( $client );

        return $client;
    }

    method imap_folder ( $folder ) {
        my $separator = $self->client->separator;

        $folder =~ s{/}{$separator}g;

        return $folder;
    }

    method get_all_ids {
        my $summaries = $self->get_all_summaries();
        my @ids;

        foreach my $summary ( @$summaries ) {
            push @ids, $summary->uid;
        }

        return @ids;
    }
    method get_all_summaries {
        my $messages = $self->client->search('ALL');
        return $self->client->get_summaries( $messages );
    }
}

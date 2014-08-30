use Modern::Perl '2012';
use MooseX::Declare;

class IMAP::Tools {
    use Config::Std;
    use Date::Manip;
    use List::Util      'shuffle';
    use Memoize;
    use Net::IMAP::Client;

    memoize('date_string_as_int');

    has 'account' => (
        is  => 'rw',
        isa => 'HashRef',
    );
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
        $self->account( $self->config->{$account} );

        my $host   = $self->account->{'host'} // 'localhost';
        my $client = Net::IMAP::Client->new(
                server => $host,
                user   => $self->account->{'user'},
                pass   => $self->account->{'pass'},
                ssl    => $self->account->{'ssl'} // 0,
            );

        die "Couldn't connect: $!"
            if !defined $client;

        $client->login
            or die sprintf "Login failed: %s\n", $client->last_error;

        $self->client( $client );

        return $client;
    }

    method imap_folder ( $folder ) {
        return $folder
            if $folder eq 'INBOX';

        $folder = sprintf '%s/%s', $self->account->{'prefix'}, $folder
            if defined $self->account->{'prefix'};

        my $separator = $self->client->separator;

        $folder =~ s{/}{$separator}g;

        return $folder;
    }
    method human_folder ( $folder ) {
        my $prefix    = $self->account->{'prefix'};
        my $separator = "\\" . $self->client->separator;

        $folder =~ s{^$prefix$separator}{}
            if defined $prefix;

        $folder =~ s{$separator}{/}g;

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
    method get_newest_ids ( $amount ) {
        $amount = 10 unless defined $amount and int $amount;

        my $summaries = $self->get_all_summaries();
        my @ids;

        foreach my $summary ( sort newest_first @$summaries ) {
            push @ids, $summary->uid;
            last unless --$amount;
        }

        return @ids;
    }
    method get_oldest_ids ( $amount ) {
        $amount = 10 unless defined $amount and int $amount;

        my $summaries = $self->get_all_summaries();
        my @ids;

        foreach my $summary ( sort oldest_first @$summaries ) {
            push @ids, $summary->uid;
            last unless --$amount;
        }

        return @ids;
    }
    method get_random_ids ( $amount ) {
        $amount = 10 unless defined $amount and int $amount;

        my $summaries = $self->get_all_summaries();
        my @ids;

        foreach my $summary ( shuffle @$summaries ) {
            push @ids, $summary->uid;
            last unless --$amount;
        }

        return @ids;
    }
    method get_all_summaries {
        my $messages = $self->client->search('ALL');
        return $self->client->get_summaries( $messages );
    }

    sub newest_first {
        my $a_date = date_string_as_int( $a->internaldate );
        my $b_date = date_string_as_int( $b->internaldate );
        
        return $b_date <=> $a_date;
    }
    sub oldest_first {
        my $a_date = date_string_as_int( $a->internaldate );
        my $b_date = date_string_as_int( $b->internaldate );
        
        return $a_date <=> $b_date;
    }
    sub date_string_as_int {
        my $string = shift;
        
        return UnixDate( $string, '%s' );
    }
}

package Plack::Middleware::Throttle::Lite::Backend::Redis;

# ABSTRACT: Redis-driven storage backend for Throttle-Lite

use strict;
use warnings;
use feature ':5.10';
use Carp ();
use parent 'Plack::Middleware::Throttle::Lite::Backend::Abstract';
use Redis 1.955;

# VERSION
# AUTHORITY

__PACKAGE__->mk_attrs(qw(redis rdb ttl));

sub init {
    my ($self, $args) = @_;

    my $croak = sub { Carp::croak $_[0] };

    if (!defined $args->{server} && !defined $args->{sock}) {
        $croak->("Settings should include either server or sock parameter!");
    }

    my %expire = ('req/hour' => 3600, 'req/day' => 86400);

    my %options = (
        debug     => $args->{debug}     || 0,
        reconnect => $args->{reconnect} || 10,
        every     => $args->{every}     || 100,
    );

    $options{password} = $args->{password} if $args->{password};

    if (defined $args->{sock}) {
        $croak->("Nonexistent redis socket ($args->{sock})!") unless -e $args->{sock} && -S _;
    }

    if (defined $args->{server}) {
        $croak->("Expected 'hostname:port' for parameter server!") unless $args->{server} =~ /(.*)\:(\d+)/;
    }

    if (defined $options{sock}) {
        $options{sock} = $args->{sock};
    }
    else {
        $options{server} = $args->{server};
    }

    $self->rdb($args->{database} || 0);
    $self->ttl($args->{expire} || $expire{$self->units});

    $self->redis(Redis->new(%options));
}

1; # End of Plack::Middleware::Throttle::Lite::Backend::Redis

__END__

=pod

=encoding utf8

=head1 SYNOPSYS

    # inside your app.psgi
    enable 'Throttle::Lite',
        backend => [
            'Redis' => {
                server   => 'redis.example.com:6379',
                database => 1,
                password => 'VaspUtnuNeQuiHesGapbootsewWeonJadacVebEe'
            }
        ];

=head1 DESCRIPTION

=head1 OPTIONS

=head1 METHODS

=head1 BUGS

=head1 SEE ALSO

L<Redis>

L<Plack::Middleware::Throttle::Lite>

L<Plack::Middleware::Throttle::Lite::Backend::Abstract>

=cut

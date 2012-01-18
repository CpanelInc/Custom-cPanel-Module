package Cpanel::CustomModuleExample;

# cpanel - Cpanel/Logaholic.pm                    Copyright(c) 2012 cPanel, Inc.
#                                                           All rights Reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited

##
# Example of Custom cPanel Module
#
# Place this Perl module in /usr/local/cpanel/Cpanel and it will behave like
#  a native cPanel Module, e.g. it exposes local and remote API2 functionality.
#
# Most all the content below is base on official documentation found here:
#  http://docs.cpanel.net/twiki/bin/view/SoftwareDevelopmentKit/WritingCpanelModules
##

our $VERSION = 1.00;

use strict;

###############################################################################
## API2 Setup
###############################################################################
# NOTE: the docs state you must provide a detailed hashref, but that is not
#  necessary except in rare cases. You can return an empty hashref and the API
#  engine will assume reasonable defaults, namely that an inbound request like
#  "module=CustomModuleExample&func=foobar' will invoke the 'api2_foobar'
#   subroutine. This shorthand is available in cPanel 11.28+
sub api2 {
    my ($func) = @_;
    my $api_ref = _get_api2_ref();
    return $api_ref->{$func};
}

# Note: In this example we separate the hashref from the api2() dispatch
#  method.  The only advantage is testibility in your unit tests
sub _get_api2_ref {
    my $api_ref = {
        'foobar'   => {},
        'bazblurg' => {},
        'failme'   => {},
    };
    return $api_ref;
}

###############################################################################
## API2 Functions
###############################################################################

# Example 'foobar' will return one set of data
sub api2_foobar {

    # siphon off the input args into a hash
    my %OPTS = @_;

    # do stuff here; contrived example
    my $data = {
        'name'  => 'blah',
        'key'   => 'value',
        'input' => [],
    };

    foreach my $key ( keys %OPTS ) {
        push @{ $data->{'input'} }, { $key => $OPTS{$key} };
    }

    return $data;
}

# Example 'bazblug' will return multiple data sets
sub api2_bazblurg {

    # siphon off the input args into a hash
    my %OPTS = @_;

    my $datas = [];

    # do stuff here; contrived example
    my $data = {
        'name' => 'blah',
        'key'  => 'value',
    };

    foreach my $key ( keys %OPTS ) {
        my %tmp_data = map { $_ => $data->{$_} } keys %{$data};
        $tmp_data{$key} = $OPTS{$key};
        push @{$datas}, \%tmp_data;
    }

    return $datas;
}

# Example 'failme' illustrates how to set an error using the contextual
#  hash "%Cpanel::CPERROR".  The key of the entry in the hash should be
#  the same as your module name (but all lowercase); the value is a
#  string that you wish to bubble up in the top-most 'error' node of
#  the response.
sub api2_failme {

    my $data_msg;

    # do stuff and notice a problem; contrived example
    if ( 1 != 0 ) {
        my $err_msg = 'A contextual failure has occurred!';
        $Cpanel::CPERROR{'custommoduleexample'} = $err_msg;

        # Usually, you will nothing, i.e., 'return;' which givens an
        #  empty data node in the response.  However, you may return
        #  data if you see fit.
        $data_msg = 'You may relay data in a contextual error scenario';
        return { 'relevant_data' => $data_msg };
    }

    $data_msg = 'never renders due to pre-mature fail/return.';
    return { 'this_will' => $data_msg };
}

1;
__END__

=head1 NAME

CustomModuleExample.pm - Example of a Custom cPanel Module

=head1 VERSION

Version 1.00

=head1 SYNOPSIS

# Using API2 cptag

<?cp CustomModuleExample::foobar( %, return_key, ) api_arg=value, ?>

# Using Remote API to execute API2 (with JSON output)

https://$server:$port/json-api/cpanel?cpanel_jsonapi_user=$some_cpuser&\
cpanel_jsonapi_module=CustomModuleExample&cpanel_jsonapi_func=foobar&\
cpanel_jsonapi_apiversion=2&api_arg=value

=head1 DESCRIPTION

Place this Perl module in F</usr/local/cpanel/Cpanel/> and it will behave like a native cPanel Module, e.g. it exposes local and remote API2 functionality.

This is a simple example of how a developer can author a Perl module that provides API2 functionality, extending the cPanel API.

B<NOTE:> cPanel APIs run as the cPanel user and will only have privilege to information they own.  When the cPanel API is invoked via the Remote API, authenticate as the root user or a reseller, cPanel drops privileges to the specified C<cpanel_[xml|json]api_user>.

Most all the patterns in this module are base on official documentation found at the following

=over

=item * L<Writing cPanel Modules|http://docs.cpanel.net/twiki/bin/view/SoftwareDevelopmentKit/WritingCpanelModules>

=item * L<sdk.cpanel.net|http://sdk.cpanel.net>

=back

=head1 FUNCTIONS

=over

=item * C<foobar>

Receives input key/value pairs and inserts them into the response as an array of hashes.  This illustrates the basics of how an API2 module should receive API call input and how to return a hashref containing arbitrarily deep information.

=item * C<bazblurg>

Receives input key/value pairs and inserts them into the response as one or more hashes.  This illustrates the basics of how an API2 module should receive API call input and how to return a arrayref of hashrefs.  This style of return is used when responding with a list of items, each of which could contain arbitrarily deep information.

=item * C<failme>

Forces a contextual failure within the API call itself.  API errors are set using the C<%Cpanel::CPERROR> hash.  The key of the entry in the hash should be the same as your module name (but all lowercase); the value is a string that you wish to bubble up in the top-most I<error> node of the response.

=back


=head1 EXAMPLES

The follow examples use the Remote API in JSON output format

=over

=item * B<CustomModuleExample::foobar>

    URL: https://$server:$port/json-api/cpanel
    DATA:
     cpanel_jsonapi_user=some_cpuser
     cpanel_jsonapi_module=CustomModuleExample
     cpanel_jsonapi_func=foobar
     cpanel_jsonapi_apiversion=2
     an_input_key=an_input_value
     more_input=more_value
    
    RESPONSE:
    {
        "cpanelresult": {
            "preevent": {
                "result": 1
            },
            "apiversion": 2,
            "postevent": {
                "result": 1
            },
            "data": [
                {
                    "input": [
                        {
                            "more_input": "more_value"
                        },
                        {
                            "an_input_key": "an_input_value"
                        }
                    ],
                    "name": "blah",
                    "key": "value"
                }
            ],
            "func": "foobar",
            "event": {
                "result": 1
            },
            "module": "CustomModuleExample"
        }
    }

=item * B<CustomModuleExample::bazblurg>

    URL: https://$server:$port/json-api/cpanel
    DATA:
     cpanel_jsonapi_user=some_cpuser
     cpanel_jsonapi_module=CustomModuleExample
     cpanel_jsonapi_func=bazblurg
     cpanel_jsonapi_apiversion=2
     an_input_key=an_input_value
     more_input=more_value
    
    RESPONSE:
    {
        "cpanelresult": {
            "preevent": {
                "result": 1
            },
            "apiversion": 2,
            "postevent": {
                "result": 1
            },
            "data": [
                {
                    "more_input": "more_value",
                    "name": "blah",
                    "key": "value"
                },
                {
                    "name": "blah",
                    "an_input_key": "an_input_value",
                    "key": "value"
                }
            ],
            "func": "bazblurg",
            "event": {
                "result": 1
            },
            "module": "CustomModuleExample"
        }
    }

=item * B<CustomModuleExample::failme>

    URL: https://$server:$port/json-api/cpanel
    DATA:
     cpanel_jsonapi_user=some_cpuser
     cpanel_jsonapi_module=CustomModuleExample
     cpanel_jsonapi_func=failme
     cpanel_jsonapi_apiversion=2


    RESPONSE:
    {
        "cpanelresult": {
            "preevent": {
                "result": 1
            },
            "apiversion": 2,
            "postevent": {
                "result": 1
            },
            "error": "A contextual failure has occurred!",
            "data": [
                {
                    "relevant_data": "You may relay data in a contextual error scenario"
                }
            ],
            "func": "failme",
            "event": {
                "result": 1
            },
            "module": "CustomModuleExample"
        }
    }       

=back

=head1 SEE ALSO

=over

=item * L<Calling API2 Functions|http://docs.cpanel.net/twiki/bin/view/SoftwareDevelopmentKit/CallingApiTwo>

=item * L<Calling API1 & API2 via Remote API|http://docs.cpanel.net/twiki/bin/view/SoftwareDevelopmentKit/CallingAPIFunctions>

=back

=head1 AUTHOR

David Neimeyer C<< <davidneimeyer@cpanel.net> >>

=head1 LICENSE & COPYRIGHT

Copyright (c) 2011, cPanel, Inc. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
=cut

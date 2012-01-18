# NAME

CustomModuleExample.pm - Example of a Custom cPanel Module

# VERSION

Version 1.00

# SYNOPSIS

## Using [API2 cptag](http://docs.cpanel.net/twiki/bin/view/SoftwareDevelopmentKit/CallingApiTwo)

    <?cp CustomModuleExample::foobar( %, return_key, ) api_arg=value, ?>

## Using [Remote API to execute API2](http://docs.cpanel.net/twiki/bin/view/SoftwareDevelopmentKit/CallingAPIFunctions) (with JSON output)

    https://$server:$port/json-api/cpanel?cpanel_jsonapi_user=$some_cpuser&cpanel_jsonapi_module=CustomModuleExample&cpanel_jsonapi_func=foobar&cpanel_jsonapi_apiversion=2&api_arg=value

# DESCRIPTION

Place this Perl module in ``/usr/local/cpanel/Cpanel/`` and it will behave like a native cPanel Module, e.g. it exposes local and remote API2 functionality.

This is a simple example of how a developer can author a Perl module that provides API2 functionality, extending the cPanel API.

__NOTE:__ cPanel APIs run as the cPanel user and will only have privilege to information they own.  When the cPanel API is invoked via the Remote API, authenticate as the root user or a reseller, cPanel drops privileges to the specified ``cpanel_[xml|json]api_user``.

Most all the patterns in this module are base on official documentation found here:
[Writing Cpanel Modules](http://docs.cpanel.net/twiki/bin/view/SoftwareDevelopmentKit/WritingCpanelModules)
or generally found on [sdk.cpanel.net](http://sdk.cpanel.net)

# FUNCTIONS

- __foobar__

Receives input key/value pairs and inserts them into the response as an array of hashes.  This illustrates the basics of how an API2 module should receive API call input and how to return a hashref containing arbitrarily deep information.

- __bazblurg__

Receives input key/value pairs and inserts them into the response as one or more hashes.  This illustrates the basics of how an API2 module should receive API call input and how to return a arrayref of hashrefs.  This style of return is used when responding with a list of items, each of which could contain arbitrarily deep information.

- __failme__

Forces a contextual failure within the API call itself.  API errors are set using the ``%Cpanel::CPERROR`` hash.  The key of the entry in the hash should be the same as your module name (but all lowercase); the value is a string that you wish to bubble up in the top-most _error_ node of the response.

# EXAMPLES

The follow examples use the Remote API in JSON output format

    =====================================
    ==== CustomModuleExample::foobar ====
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
    
    =======================================
    ==== CustomModuleExample::bazblurg ====
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
    
    =====================================
    ==== CustomModuleExample::failme ====
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

# AUTHOR

David Neimeyer `<davidneimeyer@cpanel.net>`

# LICENSE & COPYRIGHT

Copyright (c) 2012, cPanel, Inc. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See [perlartistic](http://search.cpan.org/perldoc?perlartistic).

# DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
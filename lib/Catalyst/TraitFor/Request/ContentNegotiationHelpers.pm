package Catalyst::TraitFor::Request::ContentNegotiationHelpers;

use Moose::Role;
use HTTP::Headers::ActionPack;

has content_negotiator => (
  is => 'bare',
  required => 1,
  lazy => 1,
  builder => '_build_content_negotiator',
  handles => +{
    raw_choose_media_type => 'choose_media_type',
    raw_choose_language => 'choose_language',
    raw_choose_charset => 'choose_charset',
    raw_choose_encoding => 'choose_encoding',
  });

  sub _build_content_negotiator {
    return HTTP::Headers::ActionPack->new
      ->get_content_negotiator;
  }

sub choose_media_type {
  my $self = shift;
  return $self->raw_choose_media_type(\@_, $self->header('Accept'));
}

sub choose_language {
  my $self = shift;
  return $self->raw_choose_language(\@_, $self->header('Accept-Language'));
}

sub choose_charset {
  my $self = shift;
  return $self->raw_choose_charset(\@_, $self->header('Accept-Charset'));
}

sub choose_encoding {
  my $self = shift;
  return $self->raw_choose_encoding(\@_, $self->header('Accept-Encoding'));
}

1;

=head1 NAME

Catalyst::Model::HTMLFormhandler - Proxy a directory of HTML::Formhandler forms

=head1 SYNOPSIS

For L<Catalyst> v5.90090+

    package MyApp;

    use Catalyst;

    MyApp->request_class_traits(['Catalyst::TraitFor::Request::ContentNegotiationHelpers']);
    MyApp->setup;

For L<Catalyst> older than v5.90090

    package MyApp;

    use Catalyst;
    use CatalystX::RoleApplicator;

    MyApp->apply_request_class_roles('Catalyst::TraitFor::Request::ContentNegotiationHelpers');
    MyApp->setup;

In a controller:

    package MyApp::Controller::Example;

    use Moose;
    use MooseX::MethodAttributes;

    sub myaction :Local {
      my ($self, $c) = @_;
      my $best_media_type = $c->req->choose_media_type('application/json', 'text/html');
    }

=head1 DESCRIPTION

When using L<Catalyst> and developing web APIs it can be desirable to examine
the state of HTTP Headers of the request to make decisions about what to do,
for example what format to return (HTML, XML, JSON, other).  This role can
be applied to your L<Catalyst::Request> to add some useful helper methods for
the more common types of server side content negotiation.

Most of the real work is done by L<HTTP::Headers::ActionPack::ContentNegotiation>,
this role just seeks to make it easier to use those features.

=head1 ATTRIBUTES

This role defines the following attributes.

=head2 content_negotiator

This is a 'bare' attribute with no direct accessors.  It expose a few methods to
assist in content negotation.

=head1 METHODS

This role defines the following methods:

=head2 choose_media_type (@array_of_types)

Given an array of possible media types ('application/json', 'text/html', etc.)
return the one that is the best match for the current request.

=head2 choose_language (@array_of_langauges)

Given an array of possible media types ('en-US', 'es', etc.)
return the one that is the best match for the current request.

=head2 choose_charset (@array_of_character_sets)

Given an array of possible media types ("UTF-8", "US-ASCII", etc.)
return the one that is the best match for the current request.

=head2 choose_encoding (@array_of_encodings)

Given an array of possible encodings ("gzip", "identity", etc.)
return the one that is the best match for the current request.

=head2 raw_choose_media_type

=head2 raw_choose_language

=head2 raw_choose_charset

=head2 raw_choose_encoding

These are methods that map directly to the underlying L<HTTP::Headers::ActionPack::ContentNegotiation>
object.  The are basicallty the same functionality except they require two arguments
(an additional one to support the HTTP header string).  You generally won't need them unless
you need to compare am HTTP header that is not one that is part of the current request.

=head1 AUTHOR
 
John Napiorkowski L<email:jjnapiork@cpan.org>
  
=head1 SEE ALSO
 
L<Catalyst>, L<Catalyst::Model>, L<HTML::Formhandler>, L<Module::Pluggable>

=head1 COPYRIGHT & LICENSE
 
Copyright 2015, John Napiorkowski L<email:jjnapiork@cpan.org>
 
This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

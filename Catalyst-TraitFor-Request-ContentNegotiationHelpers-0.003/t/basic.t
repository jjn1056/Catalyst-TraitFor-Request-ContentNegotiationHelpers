BEGIN {
  use Test::Most;
  eval "use Catalyst 5.90090; 1" || do {
    plan skip_all => "Need a newer version of Catalyst => $@";
  };
}
{
  package MyApp::Controller::Root;
  use base 'Catalyst::Controller';

  sub test :Local {
    my ($self, $c) = @_;
    $c->res->body('test');
    Test::Most::is($c->req->choose_media_type('text/html','application/json'), undef);

  }

  sub choose_media_type :Local {
    my ($self, $c) = @_;

    Test::Most::is($c->req->choose_media_type('text/html','application/json'), 'application/json');
    Test::Most::ok($c->req->accepts_media_type('application/json'));
    Test::Most::is_deeply([$c->req->accepts_media_type('application/json')], ['application/json'], 'filtered ACCEPT');

    Test::Most::ok(not $c->req->accepts_media_type('text/html'));

    my $body = $c->req->on_best_media_type(
      'no_match' => sub { 'none' },
      'text/html' => sub { 'html' },
      'application/json' => sub { 'json' });

    $c->res->body($body);
  }

  $INC{'MyApp/Controller/Root.pm'} = __FILE__;

  package MyApp;
  use Catalyst;
  
  MyApp->request_class_traits(['Catalyst::TraitFor::Request::ContentNegotiationHelpers']);
  MyApp->setup;
}

use HTTP::Request::Common;
use Catalyst::Test 'MyApp';

{
  ok my $res = request GET '/root/choose_media_type', Accept => 'application/json';
  is $res->content, 'json';
}

ok my ($res, $c) = ctx_request('/root/test');

done_testing;

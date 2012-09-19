package EPrints::NBN::Webservice;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use JSON;
use strict;
# use Data::Dumper;

sub mint {

  my ($url,$metadata) = @_;

  my $ua = LWP::UserAgent->new;
  my $content = '{"action":"nbn_create", "url":"'.$url.'", "metadataURL":"'.$metadata.'"}';
  my $req = POST 'http://nbn.depositolegale.it/api/nbn_generator.pl',
  Content_Type => "application/json",
  Content      => $content;
  $req->authorization_basic( $c->{nbnuser}, $c->{nbnpassword} );

  my $resp         = $ua->request($req);
  my $return_code  = $resp->code;
  my $status       = from_json( $resp->content );

  return $return_code, $status;
}

1;

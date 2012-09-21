EPRINTS NBN
===========

Plugin per [EPrints](http://www.eprints.org) per l'assegnazione automatica di identificatori [urn:nbn](http://www.depositolegale.it/national-bibliography-number/)



Installazione
-------------

copiare il contenuto della directory __EPrints__ in __{ARCHIVE}/cfg/plugins__ (installazione locale al singolo archivio)
oppure in __/perl_lib__ (installazione globale, usabile da tutti gli archivi nella medesima installazione)


Credenziali
-----------
credenziali di autenticazione al webservice, ottenute in seguito all'adesione al servizio

__{ARCHIVE}/cfg/cfg.d/nbn.pl__

```perl
  $c->{nbnuser} = '';
  $c->{nbnpassword} = '';
```

Nuovi fields
------------
gli identificatori urn:nbn saranno salvati in un nuovo field dell'oggetto EPrint (mappato con una nuova colonna della database)


__{ARCHIVE}/cfg/cfg.d/eprint_fields.pl__

```perl
  {
      name => 'nbncheck',
      type => 'boolean',
      input_style => 'checkbox',
  },
  {
      name => 'nbn',
      type => 'text',
  },
  {
      name => 'nbnlog',
      type => 'text',
  }
```

aggiornare la struttura del database

```
  % ./bin/epadmin update_database_structure {ARCHIVE} --verbose
```


Visualizzazione di una checkbox per la generazione dell'nbn
-----------------------------------------------------------
aggiungere la configurazione seguente al workflow (nella posizione più adatta).
verrà visualizzata una checkbox ai soli utenti amministratori

__{ARCHIVE}/cfg/workflows/eprint/default.xml__

```perl
  <epc:if test="$current_user{usertype} = 'admin'">
      <component type="Field::Multi">
              <title>NBN</title>
              <epc:if test="nbncheck != 'TRUE' ">
                      <field ref="nbncheck" required="no" />
              </epc:if>
              <epc:if test="is_set(nbn)">
                      <field ref="nbn" required="no" />
              </epc:if>
      </component>
   </epc:if>
```


Salvataggio dell'nbn
--------------------
al salvataggio dell'EPrints (o dopo un'avanzamento di step nel workflow) verrà chiamato il webservice del registro nbn e in seguito ad una risposta positiva verrà salvato l'identificatore nel database 

__{ARCHIVE}/cfg/cfg.d/eprint_fields_automatic.pl__

```perl
  if ($eprint->is_set("nbncheck")) {
    my $nbncheck = $eprint->get_value("nbncheck");
    if ( $nbncheck eq 'TRUE' && !$eprint->is_set("nbn") )
    {
      my $metadataurl = "http://".$c->{host}.
      "/cgi/oai2?verb=GetRecord&metadataPrefix=oai_dc&identifier=oai:".
      $c->{oai}->{v2}->{archive_id}.":".$eprint->id;
      my ($ret, $status) = EPrints::NBN::Webservice::mint( $eprint->get_url(), $metadataurl );
      if ($ret eq '201') {
        $eprint->set_value("nbn", $status->{'nbn'});
      } else {
        $eprint->set_value("nbnlog", $status->{'status'});
        $eprint->set_value("nbncheck", "FALSE");
      }
    }
  }
```

Visualizzazione dell'nbn nella pagina di dettaglio dell'eprint
--------------------------------------------------------------
modificare __{ARCHIVE}/cfg/citations/eprint/summary_page.xml__ o __{ARCHIVE}/cfg/cfg.d/eprint_render.pl__ per visualizzare il contenuto del field nbn



Licenza
-------

[Public Domain](http://creativecommons.org/publicdomain/zero/1.0/)


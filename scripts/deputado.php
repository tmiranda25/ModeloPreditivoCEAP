<?php

foreach([54, 55, 56] AS $legislatura){
    
    try{
        
        $json = \json_decode(\file_get_contents("https://dadosabertos.camara.leg.br/api/v2/deputados?idLegislatura=$legislatura&ordem=ASC&ordenarPor=nome"));
        
        $csv_filename = "../dados_brutos/deputado_$legislatura.csv";
        
        $handle = \fopen($csv_filename, 'w');
        
        //Colocar a linha de cabeçalho
        \fputcsv($handle, ['iddeputado', 'nome', 'siglapartido', 'siglauf', 'idlegislatura']);

        foreach($json->dados AS $deputado){
            \fputcsv($handle, [
                'iddeputado' => $deputado->id,
                'nome' => $deputado->nome,
                'siglapartido' => $deputado->siglaPartido,
                'siglauf' => $deputado->siglaUf,
                'idlegislatura' => $deputado->idLegislatura,
            ]);
        }
    }
    finally{
        \fclose($handle);
    }
}
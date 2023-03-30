/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Other/SQLTemplate.sql to edit this template
 */
/**
 * Author:  thiago
 * Created: 29 de mar. de 2023
 */

--EXISTE INCONSISTENCIA ENTRE IDECADASTRO - CARTEIRA? O idcadastro não se altera e a carteira repete se o deputado é reeleito. Quando temos somente 2 legislaturas em sequência, não precisamos levar em consideração a legislatura porém nos demais casos é necessário.
select idecadastro, nucarteiraparlamentar, codlegislatura from (select distinct idecadastro, nucarteiraparlamentar, codlegislatura from ceap_stg) foo group by 1, 2, 3 having count(*) > 1;